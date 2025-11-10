#!/usr/bin/env bash
# Bootstrap: Install Fish shell as the very first step
# This is the ONLY bash script - everything else runs in Fish
set -euo pipefail

# Color codes (used before gum is installed)
C_RESET='\033[0m'
C_GREEN='\033[0;32m'
C_BLUE='\033[0;34m'
C_RED='\033[0;31m'

# Helper function for initial install (before gum is available)
run_quiet() {
    local description="$1"
    shift
    local temp_output=$(mktemp)

    echo -n "  ${description}... "
    echo "Running: $@" >> "$FEDPUNK_LOG_FILE"

    if "$@" >> "$temp_output" 2>&1; then
        echo -e "${C_GREEN}✓${C_RESET}"
        cat "$temp_output" >> "$FEDPUNK_LOG_FILE"
        rm -f "$temp_output"
        return 0
    else
        echo -e "${C_RED}✗${C_RESET}"
        echo ""
        echo -e "${C_RED}Error output:${C_RESET}"
        cat "$temp_output"
        cat "$temp_output" >> "$FEDPUNK_LOG_FILE"
        rm -f "$temp_output"
        return 1
    fi
}

# Helper functions using gum (available after initial install)
gum_info() {
    gum style --foreground 33 "→ $1"
    echo "[INFO] $1" >> "$FEDPUNK_LOG_FILE"
}

gum_success() {
    gum style --foreground 35 "✓ $1"
    echo "[SUCCESS] $1" >> "$FEDPUNK_LOG_FILE"
}

gum_error() {
    gum style --foreground 9 --bold "✗ $1"
    echo "[ERROR] $1" >> "$FEDPUNK_LOG_FILE"
}

echo ""
echo -e "${C_BLUE}━━━ Bootstrap: Installing Fish Shell ━━━${C_RESET}"
echo ""

# Get either /root or /home/USER depending on the user
DIR=$(if [ "$(id -u)" -eq 0 ]; then echo "/root"; else echo "/home/$(whoami)"; fi)

cd "$FEDPUNK_PATH"

# Install Fish, stow, and gum (for interactive installation interface)
run_quiet "Installing Fish, stow, and gum" sudo dnf install -qy fish stow gum

echo ""
gum style \
    --foreground 33 \
    --bold \
    "✓ Core tools installed - switching to gum interface"
echo ""

# Deploy Fish configuration using gum
gum spin --spinner dot --title "Deploying Fish configuration..." -- \
    bash -c "stow -d config -t \"$DIR\" fish >> \"$FEDPUNK_LOG_FILE\" 2>&1" && \
    gum_success "Fish configuration deployed" || \
    (gum_error "Failed to deploy Fish configuration" && exit 1)

# Install chsh utility if needed
if ! command -v chsh &>/dev/null; then
    gum spin --spinner dot --title "Installing chsh utility..." -- \
        bash -c "sudo dnf install -qy util-linux-user >> \"$FEDPUNK_LOG_FILE\" 2>&1" && \
        gum_success "chsh utility installed" || \
        (gum_error "Failed to install chsh utility" && exit 1)
fi

# Change shell for the current user
gum spin --spinner dot --title "Setting Fish as default shell..." -- \
    bash -c "if command -v sudo &>/dev/null; then \
        sudo chsh -s /usr/bin/fish \$(whoami); \
    else \
        chsh -s /usr/bin/fish; \
    fi" >> "$FEDPUNK_LOG_FILE" 2>&1 && \
    gum_success "Fish set as default shell" || \
    gum_error "Failed to set Fish as default shell"

# Verify Fish installation
if ! command -v fish >/dev/null 2>&1; then
    gum_error "Fish installation failed!"
    exit 1
fi

echo ""
gum style \
    --foreground 35 \
    --border rounded \
    --border-foreground 35 \
    --padding "1 2" \
    --margin "0 2" \
    "✓ Bootstrap complete! Fish shell ready"
echo ""
gum_info "Handing off to Fish for remaining installation..."
echo ""
