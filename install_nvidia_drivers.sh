#!/bin/bash
set -e
set -o pipefail

# Script: install-nvidia-drivers.sh
# Purpose: Quickly install NVIDIA drivers on Ubuntu/Debian systems (AWS EC2, bare metal)
# Requires: sudo, lspci (pciutils), ubuntu-drivers-common
# Usage: sudo bash install-nvidia-drivers.sh
#   OR:  DRY_RUN=1 bash install-nvidia-drivers.sh (preview without executing)

# Cleanup on exit
cleanup() {
    return 0
}
trap cleanup EXIT INT TERM

# Check for dry-run mode
DRY_RUN="${DRY_RUN:-0}"
if [[ "$DRY_RUN" == "1" ]]; then
    echo "[DRY RUN] Preview mode enabled. No changes will be made."
fi

# Validate dependencies
if ! command -v lspci &> /dev/null; then
    echo "Error: lspci not found. Install pciutils: sudo apt install pciutils" >&2
    exit 1
fi

if ! command -v sudo &> /dev/null; then
    echo "Error: sudo not found" >&2
    exit 1
fi

# Detect NVIDIA GPU
echo "Detecting NVIDIA GPU..."
if ! lspci | grep -i nvidia > /dev/null; then
    echo "Error: No NVIDIA GPU detected on this system" >&2
    exit 1
fi
echo "✓ NVIDIA GPU detected"

# Update package lists
echo "Updating package lists..."
if [[ "$DRY_RUN" != "1" ]]; then
    sudo apt update -y
else
    echo "[DRY RUN] Would execute: sudo apt update -y"
fi

# Check if ubuntu-drivers-common is installed
echo "Checking for ubuntu-drivers-common..."
if ! dpkg -l | grep ubuntu-drivers-common > /dev/null 2>&1; then
    echo "Installing ubuntu-drivers-common..."
    if [[ "$DRY_RUN" != "1" ]]; then
        sudo apt install -y ubuntu-drivers-common
    else
        echo "[DRY RUN] Would execute: sudo apt install -y ubuntu-drivers-common"
    fi
fi

# Install NVIDIA drivers
echo "Installing latest NVIDIA drivers..."
if [[ "$DRY_RUN" != "1" ]]; then
    sudo ubuntu-drivers autoinstall -y
else
    echo "[DRY RUN] Would execute: sudo ubuntu-drivers autoinstall -y"
fi

# Verify installation
if [[ "$DRY_RUN" != "1" ]]; then
    echo "Verifying driver installation..."
    sleep 2
    if nvidia-smi &> /dev/null; then
        echo "✓ NVIDIA drivers installed successfully"
    else
        echo "Warning: nvidia-smi command not found. Drivers may require reboot to activate." >&2
    fi
fi

# Reboot prompt
if [[ "$DRY_RUN" != "1" ]]; then
    echo ""
    echo "NVIDIA drivers installation complete."
    echo "A system reboot is required to activate the drivers."
    read -p "Reboot now? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Rebooting in 5 seconds. Press Ctrl+C to cancel..."
        sleep 5
        sudo reboot
    else
        echo "Reboot skipped. Remember to reboot later to activate drivers."
    fi
else
    echo "[DRY RUN] Would prompt for reboot confirmation"
fi