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
# Note: Mode selection happens during init via .chezmoi.toml.tmpl
fish -c "chezmoi init https://github.com/hinriksnaer/Fedpunk.git"

# Apply dotfiles (run_before scripts copy module configs, then deploy)
# Separate apply ensures module configs are copied before deployment
fish -c "chezmoi apply"

echo ""
echo "✓ Installation complete!"
echo ""
