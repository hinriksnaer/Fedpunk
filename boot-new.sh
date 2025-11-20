#!/bin/bash
# Fedpunk Bootstrap
# Minimal installer - only installs what's needed to run install.fish

set -eEuo pipefail

ansi_art='
███████╗███████╗██████╗ ██████╗ ██╗   ██╗███╗   ██╗██╗  ██╗
██╔════╝██╔════╝██╔══██╗██╔══██╗██║   ██║████╗  ██║██║ ██╔╝
█████╗  █████╗  ██║  ██║██████╔╝██║   ██║██╔██╗ ██║█████╔╝
██╔══╝  ██╔══╝  ██║  ██║██╔═══╝ ██║   ██║██║╚██╗██║██╔═██╗
██║     ███████╗██████╔╝██║     ╚██████╔╝██║ ╚████║██║  ██╗
╚═╝     ╚══════╝╚═════╝ ╚═╝      ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═╝
'

echo "$ansi_art"
echo ""

# Preflight checks
echo "🔍 Preflight checks..."

# Check internet
echo "→ Internet connectivity..."
if ! ping -c 1 github.com &>/dev/null; then
    echo "❌ No internet connection"
    exit 1
fi

# Check sudo
echo "→ Sudo privileges..."
if ! sudo -n true 2>/dev/null; then
    echo "→ Please enter password:"
    sudo true || exit 1
fi

echo "✅ Preflight passed"
echo ""

# Install ONLY what's needed to run install.fish
echo "→ Installing bootstrap essentials..."
echo "   • git    - clone repository"
echo "   • fish   - run installer"
echo "   • stow   - deploy configs"
echo "   • gum    - UI feedback"
echo ""

sudo dnf install -y git fish stow gum || {
    echo "❌ Failed to install bootstrap packages"
    exit 1
}

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Repository configuration
FEDPUNK_REPO="${FEDPUNK_REPO:-hinriksnaer/Fedpunk}"
FEDPUNK_REF="${FEDPUNK_REF:-custom-dotmanage}"
FEDPUNK_PATH="$HOME/.local/share/fedpunk"

echo "→ Cloning from: https://github.com/${FEDPUNK_REPO}.git"
echo "→ Branch: $FEDPUNK_REF"
echo ""

# Clone (handle existing installation)
if [[ -d "$FEDPUNK_PATH" ]]; then
    echo "⚠️  Existing installation found"
    TEMP_PATH="/tmp/fedpunk-install-$$"
    git clone -b "${FEDPUNK_REF}" "https://github.com/${FEDPUNK_REPO}.git" "$TEMP_PATH"
    FEDPUNK_PATH="$TEMP_PATH"
else
    mkdir -p "$(dirname "$FEDPUNK_PATH")"
    git clone -b "${FEDPUNK_REF}" "https://github.com/${FEDPUNK_REPO}.git" "$FEDPUNK_PATH"
fi

echo ""
echo "→ Starting installation..."
echo ""

# Run installer (pass through any flags)
cd "$FEDPUNK_PATH"
fish install.fish "$@"
