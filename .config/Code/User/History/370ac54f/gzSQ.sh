#!/bin/bash
set -e
# ==== CONFIG ====
ROOTFS_DIR="/tmp/minimal_rootfs"
DEBIAN_VERSION="bookworm"
MIRROR_URL="https://deb.debian.org/debian"

# ==== Cleanup ====
cleanup() {
   echo "[INFO] Cleaning up mounted directories..."
   sudo unmount -if "$ROOTFS_DIR/proc" 2>/dev/null || true
   sudo unmount -if "$ROOTFS_DIR/sys" 2>/dev/null || true
   sudo unmount -if "$ROOTFS_DIR/dev" 2>/dev/null || true
   echo "[INFO] Cleanup complete."
}
trap cleanup EXIT

echo "[+] Creating isolated environment at $ROOTFS_DIR"

# Clean old rootfs if it exists
sudo rm -rf "$ROOTFS_DIR"
sudo mkdir -p "$ROOTFS_DIR" "$ROOTFS_DIR/proc" "$ROOTFS_DIR/sys" "ROOTFS_DIR/dev"

# ==== Step 1: Create minimal Filesystem ====
echo "[+] Bootstrapping minimal Debian filesystem..."
sudo debootstrap --variant=minbase $DEBIAN_VERSION $ROOTFS_DIR $MIRROR_URL

# ==== Step  2: Mount essential directories ====
echo "[+] Mounting /proc, /sys, and /dev..."
sudo mount -t proc /proc "$ROOTFS_DIR/proc"
sudo mount -t sysfs /sys "$ROOTFS_DIR/sys"
sudo mount --bind /dev "$ROOTFS_DIR/dev"

# ==== Step 3: Network namespace isolation ====
echo "[INFO] Creating isolated network namespace..."
sudo bash -c "echo 'nameserver 8.8.8,8' > $ROOTS_DIR/etc /resolv.conf"

echo "[INFO] minimal filesystem ready at: $ROOTFS_DIR"
echo "[INFO] You can chroot into it with:"
echo "sudo chroot $ROOFTS_DIR /bin/bash"
