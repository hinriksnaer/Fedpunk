#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -eEo pipefail

# Set install mode to online since boot.sh is used for curl installations
export FEDPUNK_ONLINE_INSTALL=true

ansi_art='
███████╗███████╗██████╗ ██████╗ ██╗   ██╗███╗   ██╗██╗  ██╗
██╔════╝██╔════╝██╔══██╗██╔══██╗██║   ██║████╗  ██║██║ ██╔╝
█████╗  █████╗  ██║  ██║██████╔╝██║   ██║██╔██╗ ██║█████╔╝
██╔══╝  ██╔══╝  ██║  ██║██╔═══╝ ██║   ██║██║╚██╗██║██╔═██╗
██║     ███████╗██████╔╝██║     ╚██████╔╝██║ ╚████║██║  ██╗
╚═╝     ╚══════╝╚═════╝ ╚═╝      ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═╝
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
echo ""

echo "→ Installing git, fish, and gum..."
sudo dnf install -y git fish gum

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Use custom repo if specified, otherwise default to your repo
FEDPUNK_REPO="${FEDPUNK_REPO:-hinriksnaer/Fedpunk}"

echo -e "\nCloning Fedpunk from: https://github.com/${FEDPUNK_REPO}.git"

# Check if existing installation exists and ask for confirmation
if [[ -d ~/.local/share/fedpunk ]]; then
    echo "⚠️  Existing Fedpunk installation found at ~/.local/share/fedpunk"
    read -p "Do you want to remove it and continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Installation cancelled by user."
        exit 1
    fi
    echo "→ Removing existing installation..."
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

echo -e "\nInstallation starting..."

# Pass terminal-only flag if set
if [[ -n "$FEDPUNK_TERMINAL_ONLY" ]]; then
    fish "$FEDPUNK_PATH/install.fish" --terminal-only
else
    fish "$FEDPUNK_PATH/install.fish"
fi
