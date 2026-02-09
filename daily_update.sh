#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

echo "Updating package lists..."
sudo apt update -y

echo "Upgrading installed packages..."
sudo apt upgrade -y

echo "Performing full system upgrade (if necessary)..."
sudo apt full-upgrade -y

echo "Removing unused packages..."
sudo apt autoremove -y

echo "Cleaning up downloaded package files..."
sudo apt clean

echo "Updating flatpak packages..."
# Check if flatpak is installed before running update
if command -v flatpak &> /dev/null; then
    flatpak update -y
    # Optional: Remove unused flatpak runtimes
    flatpak uninstall --unused -y
else
    echo "Flatpak not found, skipping..."
fi

echo "System update and cleanup complete."