# GitHub Actions Workflow Security Scanner Extension

This is a Visual Studio Code extension developed to provide security analysis for GitHub Action configuration files.<br>

This extension uses a language server (found [here](https://github.com/hugh-clements/github-actions-sec-lsp)) and the LSP to provide in-line diagnostics for security vulnerabilities inside the YAML workflow files.


## Usage

To use this extension, it can simply be added using the [VSCode extension marketplace](https://marketplace.visualstudio.com/items?itemName=Hugh-Clements.github-actions-workflow-security-scanner), either using the command from the website or directly from inside VSCode.
<br>
This extension requires Java 23 to be installed on the system.


## RULES
The following rules have been implemented as part of the language server. <br>
<br>
To add additional rules, a class implementing the interface `DiagnosticProvider` needs to be created and added to the `DiagnosticService` class constructor. The method `diagnose()` inside the `NewRuleDiagnosticsProvider` performs the diagnostic. The `DiagnosticBuilderService` must also be updated with relevant data to build the diagnostic.

### INCORRECT_LANG
This rule is broken if the file being tracked by the language sever is not in the `YAML` language.<br>
This does not introduce a vulnerability but is a configuration fault.

### INCORRECT_DIRECTORY
This rule is broken if the file being tracked by the language sever is not in the `github/workflows` directory.
This does not introduce a vulnerability but is a configuration fault.

### NOT_VALID_YAML
This rule is broken if the file being tracked by the language sever is not valid `YAML`.<br>
This does not introduce a vulnerability but is a configuration fault.

### COMMAND_EXECUTION
Vulnerability: A value inserted into a `run:` using `${{}}` is not sanitised and can lead to command execution inside the step, such as `echo Printing ${{user_input}}`.

**Mitigation:**
- Pass as an argument through a `with` clause
- Pass through from an `env` variable

Example vulnerable workflow:
```
on:
  workflow_dispatch:
    inputs:
      command:
        description: 'Command to run'
        required: true

jobs:
  execute:
    runs-on: ubuntu-latest
    steps:
      - name: Run user input as command
        run: |
          echo "Running user command: ${{ github.event.inputs.command }}"

```
### CODE_INJECTION
Vulnerability: The actions/github-script action evaluates expressions wrapped in ${{ }} without escaping them. If an attacker can influence these expressions, it may result in unintended command execution during the script’s execution phase.

**Mitigation:**
- Pass the experssion to the action using a `with` clause.

Example vulnerable workflow:
```
on:
  workflow_dispatch:
    inputs:
      cmd:
        description: 'Command to run'
        required: true

jobs:
  code-injection:
    runs-on: ubuntu-latest
    steps:
      - name: Dangerous script execution
        uses: actions/github-script@v6
        with:
          script: |
            const { execSync } = require('child_process');
            execSync('${{ github.event.inputs.cmd }}');
```
### PWN_REQUEST
Vulnerability: An action that uses pull_request_target and checks out the pull request branch can be exploited by untrusted contributors to compromise workflow steps or access secrets. This is because pull_request_target runs in the context of the base repository, granting elevated permissions.

**Mitigation:**
 - Do not perform a checkout when triggered by a `pull_request_target`
 - If required to do so, treat the repository as untrusted

Example vulnerable workflow:
```
on:
  pull_request_target:
    branches:
      - main

jobs:
  insecure-job:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout pull request branch (unsafe)
        uses: actions/checkout@v3
        with:
          ref: ${{ github.event.pull_request.head.ref }}

      - name: Run untrusted PR code
        run: echo "Running code from the PR branch: ${{ github.event.pull_request.head.ref }}"

```
### REPOJACKABLE
Vulnerability: The identified action reference can be repojacked. The organisation/repo has been renamed or doesn't exist.

**Mitigation:**
- Ensure all `uses` refer to up to date existing repositories


Example vulnerable workflow:
```
on:
  push:
    branches:
      - main

jobs:
  example-job:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Use a potentially repojackable action
        uses: some-old-org/deprecated-action@v1

```
### RUNNER_HIJACKER
Vulnerability: Using a self hosted runner can allow attackers to compromise the host machine during a supply chain attack.

**Mitigation:**
- Use GitHub's provided runners

Example vulnerable workflow:
```
jobs:
  build:
    runs-on: self-hosted
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

```

### UNPINNED_ACTION
Vulnerability: An action is references by a version tag or branch inside of a `uses` rather than a fixed commit hash. If the action repository is compromised this action may lead to a supply chain attack.

**Mitigation:**
- Reference all actions by a fixed commit hash

Example vulnerable workflow:
```
jobs:
  unpinned-example:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repository
        uses: actions/checkout@v3  # Unpinned Action

      - name: Set up Node.js
        uses: actions/setup-node@v3  # Unpinned Action

```
### WORKFLOW_RUN
Vulnerability: This workflow is initiated by a separate workflow and includes a step that checks out the same branch responsible for triggering the initial workflow. If that branch is influenced by an untrusted source, it could allow an attacker to manipulate the execution flow, so the chain of actions should be assessed for potential vulnerabilities.

**Mitigation:**
-  Actions triggered indirectly by other workflows should handle input data as untrusted particularly when the source of that data is obscured by the chaining of workflows.

Example vulnerable workflow:
```
on:
  workflow_run:
    workflows: ["Workflow A"]
    types:
      - completed

jobs:
  insecure-checkout:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout triggering branch
        uses: actions/checkout@v3
        with:
          ref: ${{ github.event.workflow_run.head_branch }}  # Unsafe usage

```
### UNSAFE_INPUT_ASSIGNMENT
Vulnerability: Attacker-controlled input may be provided directly to a workflow step through the with clause. If the step processes this input without appropriate validation or sanitization, it may result in unintended behavior, including the execution of arbitrary commands or code.

**Mitigation:**
- Ensure allexternal values are treated as untrusted

Example vulnerable workflow:
```
on:
  workflow_dispatch:
    inputs:
      unsafe_input:
        description: "Possibly unsafe input"
        required: true

jobs:
  insecure-job:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout repo
        uses: actions/checkout@v4

      - name: Use attacker-controlled input unsafely
        uses: actions/github-script@v7
        with:
          script: |
            console.log("Running unsafe command");
            require('child_process').execSync("${{ github.event.inputs.unsafe_input }}");

```
### OUTDATED_REFERENCE
Vulnerability: An action referenced by commit hash is pinned to an outdated commit. Later versions could include vulnerability patching which could leave the repo open to already patched vulnerabilities.

**Mitigation:**
- Periodically update the actions commit reference
