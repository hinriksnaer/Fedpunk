#!/usr/bin/env bash
# Bootstrap: Install Fish shell as the very first step
# This is the ONLY bash script - everything else runs in Fish
set -euo pipefail

# Color codes
C_RESET='\033[0m'
C_GREEN='\033[0;32m'
C_BLUE='\033[0;34m'
C_RED='\033[0;31m'

# Helper functions
info() { echo -e "${C_BLUE}→${C_RESET} $1"; echo "[INFO] $1" >> "$FEDPUNK_LOG_FILE"; }
success() { echo -e "${C_GREEN}✓${C_RESET} $1"; echo "[SUCCESS] $1" >> "$FEDPUNK_LOG_FILE"; }
error() { echo -e "${C_RED}✗${C_RESET} $1"; echo "[ERROR] $1" >> "$FEDPUNK_LOG_FILE"; }

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

echo ""
echo -e "${C_BLUE}━━━ Bootstrap: Installing Fish Shell ━━━${C_RESET}"
echo ""

# Get either /root or /home/USER depending on the user
DIR=$(if [ "$(id -u)" -eq 0 ]; then echo "/root"; else echo "/home/$(whoami)"; fi)

cd "$FEDPUNK_PATH"

# Install ONLY Fish and stow - everything else happens in Fish scripts
run_quiet "Installing Fish and stow" sudo dnf install -qy fish stow

# Deploy Fish configuration
run_quiet "Deploying Fish configuration" stow -d config -t "$DIR" fish

# Install chsh utility if needed
if ! command -v chsh &>/dev/null; then
  run_quiet "Installing chsh utility" sudo dnf install -qy util-linux-user
fi

# Change shell for the current user
echo -n "  Setting Fish as default shell... "
if command -v sudo &>/dev/null; then
  if sudo chsh -s /usr/bin/fish "$(whoami)" >> "$FEDPUNK_LOG_FILE" 2>&1; then
      echo -e "${C_GREEN}✓${C_RESET}"
  else
      echo -e "${C_RED}✗${C_RESET}"
  fi
else
  if chsh -s /usr/bin/fish >> "$FEDPUNK_LOG_FILE" 2>&1; then
      echo -e "${C_GREEN}✓${C_RESET}"
  else
      echo -e "${C_RED}✗${C_RESET}"
  fi
fi

# Verify Fish installation
if ! command -v fish >/dev/null 2>&1; then
    error "Fish installation failed!"
    exit 1
fi

success "Fish shell installed successfully"
echo ""
echo -e "${C_BLUE}→${C_RESET} Handing off to Fish for remaining installation..."
echo ""
