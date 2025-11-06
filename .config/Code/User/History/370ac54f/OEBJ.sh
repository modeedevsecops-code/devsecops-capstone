#!/bin/bash
set -e
# ==== CONFIG ====
ROOTFS_DIR="/tmp/minimal_rootfs"
DEBIAN_VERSION="stable"
MIRROR_URL="http://deb.debian.org/debian/"

echo "[+] Creating isolated environment at $ROOTFS_DIR"

# Clean old rootfs if it exists
sudo rm -rf "$ROOTFS_DIR"
sudo mkdir -p "$ROOTFS_DIR"

# ==== Step 1: Create minimal Filesystem ====
echo "[+] Bootstrapping minimal Debian filesystem..."
sudo debootstrap --variant=minbase $DEBIAN_VERSION $ROOTFS_DIR $MIRROR_URL

# ==== Step  2: Mount essential directories ====
echo "[+] Mounting /proc, /sys, and /dev..."
sudo mount -t proc /proc "$ROOTFS_DIR/proc"
sudo mount -t sysfs /sys "$ROOTFS_DIR/sys"
sudo mount -o bind /dev "$ROOTFS_DIR/dev"

# ==== Step 3: Network namespace isolation ====
echo "[INFO] Creating isolated network namespace..."
sudo bash -c "echo 'nameserver 8.8.8,8' > $ROOTS_DIR/etc /resolv.conf"

echo "[INFO] minimal filesystem ready at: $ROOTFS_DIR"
echo "[INFO] You can chroot into it with:"
echo "sudo chroot $ROOFTS_DIR /bin/bash"
