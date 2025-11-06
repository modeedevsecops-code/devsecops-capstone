#!bin/bash

set -e

echo "[*] Starting isolated environment..."

# Start new namespaces
sudo unshare --fork --pid --mount --user --net --uts --mount-proc