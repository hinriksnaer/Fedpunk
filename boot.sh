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

# Check if running on a display server (for Hyprland compatibility)
echo "→ Checking display server compatibility..."
if [[ -z "$DISPLAY" && -z "$WAYLAND_DISPLAY" && -z "$XDG_SESSION_TYPE" ]]; then
    echo "⚠️  Warning: No display server detected. This appears to be a headless server."
    echo "   Hyprland installation will be skipped automatically."
    export FEDPUNK_HEADLESS=true
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

# Installation mode selection (skip if headless detected)
if [[ -n "$FEDPUNK_HEADLESS" ]]; then
    echo "🖥️  Headless server detected - defaulting to Terminal-only mode"
    export FEDPUNK_TERMINAL_ONLY=true
else
    echo "Choose your installation mode:"
    echo ""

    # Check if we have a proper TTY for interactive prompts
    if [[ ! -t 0 ]] || [[ ! -t 1 ]]; then
        echo "⚠️  Warning: No interactive TTY detected"
        echo "   Defaulting to Terminal-only mode"
        echo "   To force desktop mode, set FEDPUNK_TERMINAL_ONLY=false before running"
        export FEDPUNK_TERMINAL_ONLY=true
        echo "📟 Installing: Terminal-only mode"
    else
        # Temporarily disable exit-on-error for interactive prompt
        # Note: Don't redirect stderr (2>&1) as gum needs it for TUI
        set +eEuo pipefail
        INSTALL_MODE=$(gum choose \
            "Desktop (Full: Hyprland + Terminal)" \
            "Terminal-only (Servers/Containers)")
        GUM_EXIT_CODE=$?
        set -eEo pipefail

        echo ""

        # Check if gum failed
        if [[ $GUM_EXIT_CODE -ne 0 ]]; then
            echo "❌ No installation mode selected. Exiting."
            exit 1
        fi

        # Validate selection
        if [[ -z "$INSTALL_MODE" ]]; then
            echo "❌ Empty installation mode. Exiting."
            exit 1
        elif [[ "$INSTALL_MODE" == "Terminal-only (Servers/Containers)" ]]; then
            echo "📟 Installing: Terminal-only mode"
            export FEDPUNK_TERMINAL_ONLY=true
        else
            echo "🖥️  Installing: Full desktop environment"
        fi
    fi
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Profile selection
echo "Choose a profile to activate:"
echo ""

# Check if we have a proper TTY for interactive prompts
if [[ ! -t 0 ]] || [[ ! -t 1 ]]; then
    echo "⚠️  Warning: No interactive TTY detected"
    echo "   Defaulting to 'dev' profile"
    echo "   To skip profile activation, set FEDPUNK_PROFILE=none before running"
    export FEDPUNK_PROFILE="${FEDPUNK_PROFILE:-dev}"
    echo "📦 Profile: $FEDPUNK_PROFILE"
else
    # Temporarily disable ALL error handling for interactive prompt
    # Note: Don't redirect stderr (2>&1) as gum needs it for TUI
    set +eEuo pipefail
    PROFILE=$(gum choose \
        "dev (Development tools + Bitwarden)" \
        "example (Minimal template)" \
        "none (Skip profile activation)")
    GUM_EXIT_CODE=$?
    set -eEo pipefail

    echo ""

    # Check if gum failed
    if [[ $GUM_EXIT_CODE -ne 0 ]]; then
        echo "❌ No profile selected (gum exit code: $GUM_EXIT_CODE). Exiting."
        exit 1
    fi

    # Validate selection
    if [[ -z "$PROFILE" ]]; then
        echo "❌ Empty profile selection. Exiting."
        exit 1
    elif [[ "$PROFILE" == "dev (Development tools + Bitwarden)" ]]; then
        echo "📦 Profile: dev"
        export FEDPUNK_PROFILE="dev"
    elif [[ "$PROFILE" == "example (Minimal template)" ]]; then
        echo "📦 Profile: example"
        export FEDPUNK_PROFILE="example"
    else
        echo "⏭️  Skipping profile activation"
        export FEDPUNK_PROFILE="none"
    fi
fi

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
