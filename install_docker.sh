#!/bin/bash
set -e

# Purpose: Install Docker Engine on any Linux instance
# Downloads Docker's official installer and executes it
# Requires: curl, sudo, internet connection

echo "Downloading Docker installer..."
curl -fsSL https://get.docker.com -o get-docker.sh

echo "Executing Docker installer..."
sudo sh get-docker.sh

echo "Cleaning up temporary files..."
rm get-docker.sh

echo "Docker installation complete!"