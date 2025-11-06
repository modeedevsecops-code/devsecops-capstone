#!/bin/bash
set -e 

# ==== Configuration ====
LOG_FILE="network_setup.log"

# ==== Logging Function ====
log() {
    echo "[INFO] $1 | tee -a "$LOG_FILE"
}

# ==== Error Handling Function ====

handle error() {
    echo "[ERROR] $1" | tee -a "$LOG_FILE
    exit 1
}

# ==== Create network namespace ====
create_namespace() {
    log "[*] Creating network namespaces..."
    sudo ip netns add isolated_ns || handle_error "Failed to create namespace"
}

# ==== Create virtual interfaces ====
create_veth_pair() {
    log "[*] Creating virtual Ethernet pair..."
    ip link add "$VETH_HOST" type veth peer name veth1 || handle_error "Failed to create with pair"
}

# ==== Configure interfaces
configure_interfaces(){ 
    log "Configuring interfaces..."
    ip link set veth0 up || handle_error "Failed to bring up veth0"
    ip link set veth1 netns isolated_ns || handle_error "Failed to move veth1 to namespace"
    ip netns exec isolated_ns ip link set veth1 up || handle_error "Failed to bring up veth1"
}

# ==== Main script flow ====
log "Starting network isolaton setup..."

create_namespace
create_veth_pair
configure_interfaces

log "Network isolation completed successfully!"