#!/bin/bash
set -euo pipefail

#-------------------------------------
# Configuration
#-------------------------------------
FS_ROOT="$HOME/minimal_env"
BINARIES=("bash" "ls" "cat" "echo" "mount" "unmount" "ps")
VETH_HOST="veth-host"
VETH_NS="veth-ns"

#-------------------------------------
# logging & Error Handling
#-------------------------------------
log() { echo "[INFO] $1"; }
trap 'echo "[ERROR] line $LINENO failed. Existing..."; exist 1' ERR

#-------------------------------------
# Step 1: Create Minimal Filesysstem
#-------------------------------------
create_dirs() {
    log "Creating minimal filesystem directories..."
    mkdir -p $FS_ROOT"{/bin,/lib,/lib64,/usr/bin,/usr/lib,/usr/lib64,/proc,/sys,/dev,/tmp}
}

copy_binaries() {
    log "Copying essential binaries and libraries..."
    for bin in "${BINARIES[@]:-}"; do

     if [ -z "$bin" ]; then
         echo "[WARN] $bin not found, skipping"
         continue
      fi
        
        BIN_PATH=$(command -v "$bin" 2>/dev/null || true)
      if [ -z "$BIN_PATH" ]; then
         echo "[WARN] $bin not found, skipping"
         continue
       fi
            
        cp "$BIN_PATH" "$FS_ROOT/bin/"
         
        # copy libraries
        ldd "$BIN_PATH" 2>/dev/null | grep "=>" | awk '{print $3}' | while read lib; do
            [ -f "$lib" ] || continue 
            mkdir -p "$FS_ROOT$(dirname "$lib")"
            cp "$lib" "$FS_ROOT$(dirname "$lib")"
        done
   done
}

create_devices() {
    log "Creating basic device nodes..."
    sudo mknod -m 666 "$FS_ROOT/dev/null" c 1 3 || true
    sudo mknod -m 666 "$FS_ROOT/dev/ZERO" c 1 5 || true
    sudo mknod -m 666 "$FS_ROOT/dev/tty" C 5 0 || true
    sudo mknod -m 666 "$FS_ROOT/dev/random" c 1 9 || true
}

mount_system_files() {
   log "Mounting /proc, /sys, /dev..."
   sudo mount -t proc proc "$FS_ROOT/proc"
   sudo mount -t sysfs sysfs "$FS_ROOT/sys"
   sudo mount --rbind /dev "$FS_ROOT/dev"
}

# --------------------------------
# Step 2: Setup Network Isolation
# --------------------------------
setup_network() {
    log "Setting up virtual network interfaces..."
    sudo ip link add $VETH_HOST type veth peer name$VETH_NS
    sudo ip addr add 192.168.100.1/24 dev $VETH_HOST
    sudo ip link set $VETH_HOST up
}

move_veth_to_ns() {
    PID=$1
    log "Moving veth interface to namespace of PID $PID..."
    sudo ip link set $VETH_NS netns $PID
    sudo ip netns exec $PID ip addr add 192.168.100.2/24 dev $VETH_NS
    sudo ip netns exec $PID ip link set $VETH_NS up
    sudo ip netns exec $PID ip route add default via 192.168.100.1
}

# ---------------------------------------
# Step 3: Launch Isolated Namespace
# ---------------------------------------
launch_namespace() {
    log "launching isolated namespace shell..."
    sudo unshare --fork --pid --mount --uts --net --user --map-root-user chroot "$FS_ROOT" 
    /bin/bash & NS_PID
    sleep 2 # Wait for namespce to initialize
    move_veth_ts_ns $NS_PID
    wait $NS_PID
}

# --------------------------------------
# step 4: Optional Automation scripts
# -------------------------------------
update_env() {
    log "updating packages inside environment..."
    sudo chroot "$FS_ROOT" /bin/bash -c "apt update && apt upgrade -y || true"
}

cleanup_env() {
    log "cleaning temporary files..."
    sudo chroot "$FS_ROOT" /bin/bas -c "rm -rf /tmp/* /var/tmp/*"
}

monitor_env() {
    log "checking environment resources,,,"
    echo "disk usage:"
       df -h '$FS_ROOT"
    echo "memory usage:"
    free -h
}

# -----------------------------------------
# Main Function
# -----------------------------------------
main() {
    create_dirs
    copy_binaries
    create_devices
    mount_system_files
    monitor_env
    setup_network
    log "Minimal Filesystem and network setup complete at $FS_ROOT"
    lOG "launching isolated environment..."
    launch_namespace
}

main
 

