#!/bin/bash

# Fedpunk Terminal-Only Installer
# This script installs only terminal components (Fish, Neovim, tmux, etc.)
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

# Detect if we're in an existing repo or need to clone
if [[ -f "$(dirname "$0")/install.fish" ]]; then
    FEDPUNK_PATH="$(cd "$(dirname "$0")" && pwd)"
    IN_REPO=true
    echo "→ Running from existing repository: $FEDPUNK_PATH"
else
    FEDPUNK_PATH="$HOME/.local/share/fedpunk"
    IN_REPO=false
fi

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

# Clone repository if not already in it
if [[ "$IN_REPO" = false ]]; then
    FEDPUNK_REPO="${FEDPUNK_REPO:-hinriksnaer/Fedpunk}"
    echo -e "\nCloning Fedpunk from: https://github.com/${FEDPUNK_REPO}.git"

    # Check if existing installation exists and ask for confirmation
    if [[ -d "$FEDPUNK_PATH" ]]; then
        echo "⚠️  Existing Fedpunk installation found at $FEDPUNK_PATH"
        read -p "Do you want to remove it and continue? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "❌ Installation cancelled by user."
            exit 1
        fi
        echo "→ Removing existing installation..."
        rm -rf "$FEDPUNK_PATH"
    fi

    git clone "https://github.com/${FEDPUNK_REPO}.git" "$FEDPUNK_PATH"

    # Use custom branch if instructed
    FEDPUNK_REF="${FEDPUNK_REF:-main}"
    if [[ $FEDPUNK_REF != "main" ]]; then
        echo -e "\e[32mUsing branch: $FEDPUNK_REF\e[0m"
        cd "$FEDPUNK_PATH"
        git fetch origin "${FEDPUNK_REF}" && git checkout "${FEDPUNK_REF}"
    fi
fi

# Export environment variables for terminal-only installation
export FEDPUNK_PATH
export FEDPUNK_TERMINAL_ONLY=true
export FEDPUNK_SKIP_DESKTOP=true

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

# Run the Fish installer
fish "$FEDPUNK_PATH/install.fish"
