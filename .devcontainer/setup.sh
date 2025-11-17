#!/bin/bash
# Fedpunk Devcontainer Setup Script
# This script sets up a terminal-only Fedpunk environment in a container
set -e

echo "🐟 Setting up Fedpunk in devcontainer..."

# Install sudo, shadow-utils, and util-linux (needed for useradd/su)
echo "→ Installing system utilities..."
dnf install -y sudo shadow-utils util-linux

# Create vscode user if it doesn't exist
if ! id -u vscode &>/dev/null; then
    echo "→ Creating vscode user..."
    useradd -m -s /bin/bash vscode
    echo "vscode ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
fi

# Switch to vscode user for the rest of the setup
su - vscode << 'EOF'
set -e

echo "→ Installing git, fish, and gum (required for installation)..."
sudo dnf install -y git fish gum

echo "→ Symlinking fedpunk repository..."
mkdir -p ~/.local/share
ln -sf /workspaces/fedpunk ~/.local/share/fedpunk

echo "→ Starting Fedpunk terminal-only installation..."
# Export FEDPUNK_PATH to ensure it points to the correct location
export FEDPUNK_PATH=/workspaces/fedpunk
cd /workspaces/fedpunk
fish install.fish --terminal-only --non-interactive

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Fedpunk devcontainer setup complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "🐟 To start using Fish shell, run: exec fish"
echo "📄 Installation log: check /tmp/fedpunk-install-*.log"
echo ""
EOF
