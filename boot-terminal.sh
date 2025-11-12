#!/bin/bash

# Fedpunk Terminal-Only Installer
# Run this script from within your cloned Fedpunk repository
# This installs only terminal components (Fish, Neovim, tmux, etc.)
# without the desktop environment (Hyprland, Kitty, Rofi, etc.)

set -eEo pipefail

ansi_art='
███████╗███████╗██████╗ ██████╗ ██╗   ██╗███╗   ██╗██╗  ██╗
██╔════╝██╔════╝██╔══██╗██╔══██╗██║   ██║████╗  ██║██║ ██╔╝
█████╗  █████╗  ██║  ██║██████╔╝██║   ██║██╔██╗ ██║█████╔╝
██╔══╝  ██╔══╝  ██║  ██║██╔═══╝ ██║   ██║██║╚██╗██║██╔═██╗
██║     ███████╗██████╔╝██║     ╚██████╔╝██║ ╚████║██║  ██╗
╚═╝     ╚══════╝╚═════╝ ╚═╝      ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═╝
                    Terminal-Only Installation
'

echo -e "\n$ansi_art\n"

# Verify we're in the repository
if [[ ! -f "$(dirname "$0")/install.fish" ]]; then
    echo "❌ Error: This script must be run from within the Fedpunk repository"
    echo "   Please clone the repository first:"
    echo "   git clone https://github.com/hinriksnaer/Fedpunk.git"
    echo "   cd Fedpunk"
    echo "   bash boot-terminal.sh"
    exit 1
fi

# Get repository root
REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
INSTALL_DIR="$HOME/.local/share/fedpunk"

# Copy repository to installation directory if not already there
if [[ "$REPO_ROOT" != "$INSTALL_DIR" ]]; then
    echo "→ Copying repository to: $INSTALL_DIR"

    # Create parent directory
    mkdir -p "$(dirname "$INSTALL_DIR")"

    # Remove existing installation if present
    if [[ -d "$INSTALL_DIR" ]]; then
        echo "→ Removing existing installation..."
        rm -rf "$INSTALL_DIR"
    fi

    # Copy repository
    cp -r "$REPO_ROOT" "$INSTALL_DIR"

    # Change to installation directory
    cd "$INSTALL_DIR"
    echo "✓ Repository copied to $INSTALL_DIR"
else
    echo "→ Already running from installation directory: $INSTALL_DIR"
fi
echo ""

# Preflight checks
echo "🔍 Running preflight checks..."

# Check internet connectivity
echo "→ Checking internet connectivity..."
if ! ping -c 1 github.com &>/dev/null; then
    echo "❌ No internet connection. Please check your network and try again."
    exit 1
fi

# Check sudo privileges
echo "→ Verifying sudo privileges..."
if ! sudo -n true 2>/dev/null; then
    echo "→ Sudo privileges required. Please enter your password:"
    if ! sudo true; then
        echo "❌ Failed to obtain sudo privileges. Installation cannot continue."
        exit 1
    fi
fi

echo "✅ Preflight checks passed"
echo ""

# Install dependencies
echo "→ Installing git, fish, and gum..."
sudo dnf install -y git fish gum

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🐟 Starting Terminal-Only Installation"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "This will install:"
echo "  • Fish Shell with configuration"
echo "  • Neovim with plugins and LSP"
echo "  • Tmux with plugin manager"
echo "  • Lazygit for git workflows"
echo "  • btop for system monitoring"
echo "  • Claude Code AI assistant"
echo ""
echo "This will NOT install:"
echo "  • Hyprland compositor"
echo "  • Kitty terminal (uses your existing terminal)"
echo "  • Desktop components (Rofi, Mako, etc.)"
echo ""

# Run the Fish installer with terminal-only and non-interactive flags
fish "$INSTALL_DIR/install.fish" --terminal-only --non-interactive
