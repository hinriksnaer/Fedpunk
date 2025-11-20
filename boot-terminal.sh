#!/bin/bash

# Fedpunk Terminal-Only Bootstrap
# Downloads and installs terminal-only components to ~/.local/share/fedpunk
# This installs only terminal components (Fish, Neovim, tmux, etc.)
# without the desktop environment (Hyprland, Kitty, Rofi, etc.)
#
# Usage:
#   bash <(wget -qO- https://raw.githubusercontent.com/hinriksnaer/Fedpunk/main/boot-terminal.sh)
#   bash <(curl -fsSL https://raw.githubusercontent.com/hinriksnaer/Fedpunk/main/boot-terminal.sh)

set -eEo pipefail

# Set install mode to online
export FEDPUNK_ONLINE_INSTALL=true

ansi_art='
███████╗███████╗██████╗ ██████╗ ██╗   ██╗███╗   ██╗██╗  ██╗
██╔════╝██╔════╝██╔══██╗██╔══██╗██║   ██║████╗  ██║██║ ██╔╝
█████╗  █████╗  ██║  ██║██████╔╝██║   ██║██╔██╗ ██║█████╔╝
██╔══╝  ██╔══╝  ██║  ██║██╔═══╝ ██║   ██║██║╚██╗██║██╔═██╗
██║     ███████╗██████╔╝██║     ╚██████╔╝██║ ╚████║██║  ██╗
╚═╝     ╚══════╝╚═════╝ ╚═╝      ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═╝
                    Terminal-Only Installation
'

# Detect if running from cloned repo or downloaded via wget/curl
RUNNING_FROM_REPO=false
if [[ -f "$(dirname "$0")/install.fish" ]]; then
    RUNNING_FROM_REPO=true
    REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
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

clear
echo -e "\n$ansi_art\n"
echo "✅ Preflight checks passed"

echo "→ Installing git, fish, and gum..."
sudo dnf install -y git fish gum

FEDPUNK_PATH="$HOME/.local/share/fedpunk"

if [[ "$RUNNING_FROM_REPO" == "true" ]]; then
    # Running from cloned repo - copy it to install location
    echo -e "\n→ Copying repository to: $FEDPUNK_PATH"

    # Remove existing installation if present
    if [[ -d "$FEDPUNK_PATH" ]]; then
        echo "→ Removing existing installation..."
        rm -rf "$FEDPUNK_PATH"
    fi

    # Copy repository
    mkdir -p "$(dirname "$FEDPUNK_PATH")"
    cp -r "$REPO_ROOT" "$FEDPUNK_PATH"
    echo "✓ Repository copied"
else
    # Downloaded via wget/curl - clone the repo
    FEDPUNK_REPO="${FEDPUNK_REPO:-hinriksnaer/Fedpunk}"

    echo -e "\n→ Cloning Fedpunk from: https://github.com/${FEDPUNK_REPO}.git"

    # Remove existing installation if present
    if [[ -d "$FEDPUNK_PATH" ]]; then
        echo "→ Removing existing installation..."
        rm -rf "$FEDPUNK_PATH"
    fi

    # Use custom branch if instructed, otherwise default to main
    FEDPUNK_REF="${FEDPUNK_REF:-main}"
    echo -e "\e[32mUsing branch: $FEDPUNK_REF\e[0m"

    git clone -b "${FEDPUNK_REF}" "https://github.com/${FEDPUNK_REPO}.git" "$FEDPUNK_PATH"
    echo "✓ Repository cloned"
fi

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
fish "$FEDPUNK_PATH/install.fish" --terminal-only --non-interactive
