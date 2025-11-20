#!/bin/bash
# ============================================================================
# Fedpunk Bootstrap Script
# ============================================================================
# Installs chezmoi, fish, and gum, then launches Fedpunk installation
# Usage: curl -fsSL https://raw.githubusercontent.com/hinriksnaer/Fedpunk/main/bootstrap.sh | bash
# ============================================================================

set -e

echo "Fedpunk Bootstrap Installer"
echo ""

# Check if running on Fedora
if [ ! -f /etc/fedora-release ]; then
    echo "Error: This script is designed for Fedora Linux"
    exit 1
fi

echo "✓ Detected: $(cat /etc/fedora-release)"

# Install chezmoi
if ! command -v chezmoi >/dev/null 2>&1; then
    echo "Installing chezmoi..."
    sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"

    # Add to PATH if not already there
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        export PATH="$HOME/.local/bin:$PATH"
    fi

    echo "✓ Chezmoi installed"
else
    echo "✓ Chezmoi already installed"
fi

# Install fish
if ! command -v fish >/dev/null 2>&1; then
    echo "Installing fish shell..."
    sudo dnf install -y fish >/dev/null 2>&1
    echo "✓ Fish installed"
else
    echo "✓ Fish already installed"
fi

# Install gum
if ! command -v gum >/dev/null 2>&1; then
    echo "Installing gum..."
    sudo dnf install -y gum >/dev/null 2>&1
    echo "✓ Gum installed"
else
    echo "✓ Gum already installed"
fi

# Launch Fedpunk installation via chezmoi in fish
echo ""
echo "Launching Fedpunk installation..."
echo ""

# Initialize chezmoi (clones repo, runs templates)
# Mode is auto-detected:
#   - Container: if CONTAINER env var, /.dockerenv, or /run/.containerenv exists
#   - Laptop: if /sys/class/power_supply/BAT0 exists
#   - Desktop: default
# Override with: FEDPUNK_MODE=container (or laptop/desktop)
fish -c "chezmoi init https://github.com/hinriksnaer/Fedpunk.git"

# Apply dotfiles and run installation scripts
fish -c "chezmoi apply"

echo ""
echo "✓ Installation complete!"
echo ""
