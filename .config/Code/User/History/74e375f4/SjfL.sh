#!/bin/bash
# Demonstrates process isolation using linux namespaces
# (PID, USER, MOUNT, NETWORK)

set -e

echo "[*] starting isolated environment..."

# Run bash inside new namespaces
sudo unshare --fork --pid --mount --user --net --uts --mount-proc bash <<'EOF'
echo "[*] Inside isolated environment!"
echo

# USER NAMESPACE
echo "[*] Setting up user namespace..."
# Map your user (usually UID 1000) to root (0) inside the namespace
echo "0 1000 1" > /proc/self/uid_map
echo "0 1000 1" > /proc/self/gid_map

echo "-> Who am I inside namespace?"
whoami
echo

# MOUNT NAMESPACE
echo "[*] Creating an isolated mount..."
mount -t tmpfs /mnt
echo "Hello from inside the namespace!" > /mnt/hello.txt
echo "-> Reading the file from /mnt:"
cat /mnt/hello.txt
echo "(This file doesnt exist on the host!)"
echo

# PID NAMESPACE
echo "[*] Process List inside namespaces:"
ps aux
echo "(Notice: only a few processes are visible here - isolated from host)"
echo

# NETWORK NAMESPACE
echo "[*] Checking network interfaces:"
ip link
echo "Only loopback interface is visible - no internet here!)"
echo

echo "[*] Isolation ended. Everything cleaned up!"