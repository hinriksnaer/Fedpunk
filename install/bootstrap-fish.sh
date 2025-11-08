#!/usr/bin/env bash
# Bootstrap: Install Fish shell as the very first step
# This is the ONLY bash script needed before switching to fish for everything else
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
echo -e "${C_BLUE}━━━ Installing Fish Shell ━━━${C_RESET}"
echo ""

# Get either /root or /home/USER depending on the user
DIR=$(if [ "$(id -u)" -eq 0 ]; then echo "/root"; else echo "/home/$(whoami)"; fi)

cd "$FEDPUNK_PATH"

run_quiet "Enabling Starship COPR" sudo dnf copr enable -y atim/starship
run_quiet "Upgrading packages" sudo dnf upgrade --refresh -qy
run_quiet "Installing Fish and Starship" sudo dnf install -qy fish starship

# Try lsd via dnf first; fall back to cargo only if needed
if ! command -v lsd >/dev/null 2>&1; then
  if ! sudo dnf install -qy lsd >> "$FEDPUNK_LOG_FILE" 2>&1; then
    run_quiet "Installing cargo for lsd" sudo dnf install -qy cargo
    run_quiet "Installing lsd via cargo" cargo install lsd
  fi
fi

run_quiet "Deploying Fish configuration" stow -d config -t "$DIR" fish

# Install fisher (fish plugin manager)
echo -n "  Installing Fisher plugin manager... "
if fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher" >> "$FEDPUNK_LOG_FILE" 2>&1; then
    echo -e "${C_GREEN}✓${C_RESET}"
else
    echo -e "${C_RED}✗${C_RESET}"
fi

# Install useful fish plugins
echo -n "  Installing fzf.fish plugin... "
if fish -c "fisher install PatrickF1/fzf.fish" >> "$FEDPUNK_LOG_FILE" 2>&1; then
    echo -e "${C_GREEN}✓${C_RESET}"
else
    echo -e "${C_RED}✗${C_RESET}"
fi

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
