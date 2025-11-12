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

# Use custom repo if specified, otherwise default to your repo
FEDPUNK_REPO="${FEDPUNK_REPO:-hinriksnaer/Fedpunk}"

echo -e "\nCloning Fedpunk from: https://github.com/${FEDPUNK_REPO}.git"

# Check if existing installation exists and remove non-interactively
if [[ -d ~/.local/share/fedpunk ]]; then
    echo "→ Removing existing installation at ~/.local/share/fedpunk"
    rm -rf ~/.local/share/fedpunk/
fi

FEDPUNK_PATH="$HOME/.local/share/fedpunk"
git clone "https://github.com/${FEDPUNK_REPO}.git" "$FEDPUNK_PATH"

# Use custom branch if instructed, otherwise default to main
FEDPUNK_REF="${FEDPUNK_REF:-main}"
if [[ $FEDPUNK_REF != "main" ]]; then
  echo -e "\e[32mUsing branch: $FEDPUNK_REF\e[0m"
  cd "$FEDPUNK_PATH"
  git fetch origin "${FEDPUNK_REF}" && git checkout "${FEDPUNK_REF}"
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
