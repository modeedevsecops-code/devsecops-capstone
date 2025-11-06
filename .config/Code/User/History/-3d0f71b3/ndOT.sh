#!/bin/bash

echo "==== Starting system maintainance ===="

# Update system
echo "Updating system..."
sudo apt update -y
sudo apt upgrade -y
echo "System updated successfully!"

# Cleanup system
echo "Cleaning up..."
sudo apt autoremove -y
sudo apt autoclean -y
echo "Cleanup completed!"

# Check system resources
echo "Checking disk space..."
df -h 

echo "Checking memory usage..."
free -h

echo "==== Maintainance complete! ===="