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

# Verify docker access in current session using newgrp subshell
echo ""
echo "Verifying docker access in current session..."

if newgrp docker << 'VERIFY_EOF'
docker ps >/dev/null 2>&1
VERIFY_EOF
then
    echo "✓ Docker verified! You can start using docker now."
    echo ""
    echo "Test it with:"
    echo "  docker ps"
    echo "  docker run hello-world"
else
    echo "ℹ️  Docker configured. Activate with: newgrp docker"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "For permanent activation in all future terminal sessions:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Option 1 - Log out and back in (recommended):"
echo "  logout"
echo "  # Log back in"
echo "  docker ps"
echo ""
echo "Option 2 - Activate in current session only:"
echo "  newgrp docker"
echo "  docker ps"
echo ""
echo "⚠️  Security: docker group members can run containers with root privileges."
echo "   Only add trusted users to the docker group."