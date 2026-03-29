#!/bin/bash
set -e
set -o pipefail

# Purpose: Install Docker Engine and configure for sudo-less access
# Downloads Docker's official installer, executes it, and adds current user to docker group
# Requires: curl, sudo, internet connection
# Note: User must log out/in for permanent docker group membership activation

echo "Downloading Docker installer..."
curl -fsSL https://get.docker.com -o get-docker.sh

echo "Executing Docker installer..."
sudo sh get-docker.sh

echo "Cleaning up temporary files..."
rm get-docker.sh

# Configure docker group for sudo-less access
echo ""
echo "Configuring docker group for sudo-less access..."

# Get the user who ran sudo (handles both 'sudo bash script.sh' and './script.sh')
CURRENT_USER="${SUDO_USER:-$USER}"

# Add user to docker group
sudo usermod -aG docker "$CURRENT_USER"

echo ""
echo "✓ Docker installation complete!"

# Verify docker group access without requiring logout
echo ""
echo "Verifying docker group access..."

if command -v sg &> /dev/null; then
    if sg docker -c 'docker --version' &> /dev/null; then
        echo "✓ Docker group verification successful!"
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "Launching docker-ready shell for immediate testing..."
        echo "Type 'exit' when done to return to this shell."
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        
        # Launch new shell with updated group membership
        exec su - "$CURRENT_USER"
    else
        # Verification failed - provide fallback
        echo "⚠️  Could not immediately verify docker access in current context."
        echo ""
        echo "This is normal - docker group membership requires a new login session."
        echo ""
        echo "Next steps to activate docker for user '$CURRENT_USER':"
        echo ""
        echo "Option 1 - Activate in current shell (temporary, this session only):"
        echo "  newgrp docker"
        echo "  docker --version"
        echo ""
        echo "Option 2 - Permanent activation (recommended):"
        echo "  1. Log out completely"
        echo "  2. Log back in"
        echo "  3. Run: docker --version"
        echo ""
        echo "⚠️  Security: docker group members can run containers with root privileges."
        echo "   Only add trusted users to the docker group."
    fi
else
    # sg command not available - provide manual instructions
    echo "⚠️  Could not verify docker access (sg utility not found)."
    echo ""
    echo "Docker has been installed and user '$CURRENT_USER' added to docker group."
    echo ""
    echo "To activate docker without sudo, choose one option:"
    echo ""
    echo "Option 1 - Activate in current shell (temporary, this session only):"
    echo "  newgrp docker"
    echo "  docker --version"
    echo ""
    echo "Option 2 - Permanent activation (recommended):"
    echo "  1. Log out completely"
    echo "  2. Log back in"
    echo "  3. Run: docker --version"
    echo ""
    echo "⚠️  Security: docker group members can run containers with root privileges."
    echo "   Only add trusted users to the docker group."
fi