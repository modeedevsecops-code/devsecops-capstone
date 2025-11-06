# Secure Code Review Checklist

## Authentication 
- [ ] No hardcoded credentials or API keys
- [ ] Strong password hashing (bcrypt/argon2)
- [ ] Role-based access controls applied

## Input Validadtion
- [ ] All user input validated and sanitized
- [ ] Parameterized SQL queries only

## Secrets Management
- [ ] Secrets stored in .ev or secret manager
- [ ] No sensitive data commited to git

## Dependencies
- [ ] requirements.txt pinned
- [ ] Trivy / Snyk scan completed

## Logging & Error Handling
- [ ] No sensitive data in logs
- [ ] Generic error messasages to users

## Dockerfile Security
- [ ] Non-root user used
- [ ] Minimal base image (python:3.11-slim)
- [ ] Vulnerability scan passed