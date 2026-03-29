#!/bin/bash
set -e
set -o pipefail

# Script: install-nvidia-drivers.sh
# Purpose: Quickly install NVIDIA drivers on Ubuntu/Debian systems (AWS EC2, bare metal)
# Requires: sudo, lspci (pciutils), ubuntu-drivers-common

# Check for NVIDIA GPU
echo "Detecting NVIDIA GPU..."
if ! lspci | grep -i nvidia > /dev/null; then
    echo "Error: No NVIDIA GPU detected on this system" >&2
    exit 1
fi
echo "GPU detected. Proceeding with driver installation..."

# Update package lists
echo "Updating package lists..."
sudo apt update -y

# Upgrade packages
echo "Upgrading packages..."
sudo apt upgrade -y

# Install ubuntu-drivers-common if not present
if ! command -v ubuntu-drivers &> /dev/null; then
    echo "Installing ubuntu-drivers-common..."
    sudo apt install -y ubuntu-drivers-common
fi

# Install NVIDIA drivers using ubuntu-drivers
echo "Installing NVIDIA drivers..."
sudo ubuntu-drivers --gpgpu install

# Installation complete
echo "NVIDIA drivers installation complete."
echo ""
echo "To activate the drivers, manually reboot your system:"
echo "  sudo reboot"
echo ""
echo "After rebooting, verify the installation by running:"
echo "  nvidia-smi"