#!/bin/bash

set -e

NS_NAME="isolated_ns"
VETH_HOST="veth-host"
VETH_NS="veth-ns"

echo "[1] Creating network namespace..."
sudo ip netns add $NS_NAME

echo "[2] Creating virtual Ethernet pair..."
sudo ip link add $VETH_NS type veth peer name $VETH_NS

echo "[3] Moving one end into the namespaces..."
sudo ip link set $VETH_NS netns $NS_NAME

echo "[4] Assigning IP adresses.."
sudo ip addr add 192.168.10.1/24 dev $VETH_HOST
sudo ip netns exec $NS_NAME ip addr add 192.168

echo "[5] Bringing interfaces up..."
sudo ip link set $VETH_HOST up
sudo ip netns exec $NS_NAME ip link set $VETH_NS up
sudo ip netns exec $NS_NAME ip link set lo up

echo "[6] Testing connectivity..."
sudo ip netns exec $NS_NAME ping -c 3 192.168.10.1
