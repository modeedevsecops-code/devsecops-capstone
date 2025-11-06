#!/bin/bash

# === CONFIGURATION ===
ROOTFS="/home/$USER/Devsecops-capstone/rootfs"

# === SCRIPT START ===
echo "[*] Mounting directories into $ROOTFS..."

# Ensure the directories exist inside the rootfs
mkdir -p $ROOTFS/{proc,sys,dev}

# Mount /proc, /sys, and /dev
mount -t proc /proc $ROOTFS/proc
mount --rbind /sys $ROOTFS/sys
mount --rbind /dev $ROOTFS/dev

echo "[*] Successfully mounted /proc, /sys, and /dev inside $ROOTFS"
echo "[*] You can now chroot into it using:"
echo "   sudo chroot $ROOTFS /bin/bash"
