#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -eEo pipefail

# Define Fedpunk locations
export FEDPUNK_PATH="$HOME/.local/share/fedpunk"
export FEDPUNK_INSTALL="$FEDPUNK_PATH/install"
export PATH="$FEDPUNK_PATH/bin:$PATH"

# Color codes
C_RESET='\033[0m'
C_GREEN='\033[0;32m'
C_BLUE='\033[0;34m'
C_GRAY='\033[0;90m'
C_YELLOW='\033[0;33m'
C_RED='\033[0;31m'

# Log file
export FEDPUNK_LOG_FILE="/tmp/fedpunk-install-$(date +%Y%m%d-%H%M%S).log"
echo "Fedpunk Installation Log - $(date)" > "$FEDPUNK_LOG_FILE"
echo "=================================" >> "$FEDPUNK_LOG_FILE"
echo "" >> "$FEDPUNK_LOG_FILE"

# Track installation steps
declare -a INSTALL_STEPS=()
STEP_COUNT=0

# Helper functions
info() {
    echo -e "${C_BLUE}→${C_RESET} $1"
    echo "[INFO] $(date '+%H:%M:%S') $1" >> "$FEDPUNK_LOG_FILE"
}

success() {
    echo -e "${C_GREEN}✓${C_RESET} $1"
    echo "[SUCCESS] $(date '+%H:%M:%S') $1" >> "$FEDPUNK_LOG_FILE"
}

warning() {
    echo -e "${C_YELLOW}⚠${C_RESET} $1"
    echo "[WARNING] $(date '+%H:%M:%S') $1" >> "$FEDPUNK_LOG_FILE"
}

error() {
    echo -e "${C_RED}✗${C_RESET} $1"
    echo "[ERROR] $(date '+%H:%M:%S') $1" >> "$FEDPUNK_LOG_FILE"
}

# Run a fish script with logging
run_fish_script() {
    local script_name="$1"
    local description="$2"

    STEP_COUNT=$((STEP_COUNT + 1))

    echo "" >> "$FEDPUNK_LOG_FILE"
    echo "========================================" >> "$FEDPUNK_LOG_FILE"
    echo "STEP $STEP_COUNT: $description" >> "$FEDPUNK_LOG_FILE"
    echo "Script: $script_name" >> "$FEDPUNK_LOG_FILE"
    echo "Time: $(date)" >> "$FEDPUNK_LOG_FILE"
    echo "========================================" >> "$FEDPUNK_LOG_FILE"
    echo "" >> "$FEDPUNK_LOG_FILE"

    info "Step $STEP_COUNT: $description"

    if fish "$script_name"; then
        INSTALL_STEPS+=("✓ $description")
        success "Completed: $description"
        echo "" >> "$FEDPUNK_LOG_FILE"
        echo "[STEP $STEP_COUNT COMPLETED]" >> "$FEDPUNK_LOG_FILE"
        echo "" >> "$FEDPUNK_LOG_FILE"
        return 0
    else
        local exit_code=$?
        INSTALL_STEPS+=("✗ $description (exit code: $exit_code)")
        error "Failed: $description (exit code: $exit_code)"
        echo "" >> "$FEDPUNK_LOG_FILE"
        echo "[STEP $STEP_COUNT FAILED - EXIT CODE: $exit_code]" >> "$FEDPUNK_LOG_FILE"
        echo "" >> "$FEDPUNK_LOG_FILE"
        return $exit_code
    fi
}

# Clear screen and show banner
clear
echo ""
echo -e "${C_BLUE}███████╗███████╗██████╗ ██████╗ ██╗   ██╗███╗   ██╗██╗  ██╗${C_RESET}"
echo -e "${C_BLUE}██╔════╝██╔════╝██╔══██╗██╔══██╗██║   ██║████╗  ██║██║ ██╔╝${C_RESET}"
echo -e "${C_BLUE}█████╗  █████╗  ██║  ██║██████╔╝██║   ██║██╔██╗ ██║█████╔╝${C_RESET}"
echo -e "${C_BLUE}██╔══╝  ██╔══╝  ██║  ██║██╔═══╝ ██║   ██║██║╚██╗██║██╔═██╗${C_RESET}"
echo -e "${C_BLUE}██║     ███████╗██████╔╝██║     ╚██████╔╝██║ ╚████║██║  ██╗${C_RESET}"
echo -e "${C_BLUE}╚═╝     ╚══════╝╚═════╝ ╚═╝      ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═╝${C_RESET}"
echo ""
info "Installation path: $FEDPUNK_PATH"
info "Log file: $FEDPUNK_LOG_FILE"
echo ""

# Step 1: Bootstrap - Install Fish (the ONLY bash step)
echo "" >> "$FEDPUNK_LOG_FILE"
echo "========================================" >> "$FEDPUNK_LOG_FILE"
echo "BOOTSTRAP: Installing Fish Shell" >> "$FEDPUNK_LOG_FILE"
echo "Time: $(date)" >> "$FEDPUNK_LOG_FILE"
echo "========================================" >> "$FEDPUNK_LOG_FILE"
echo "" >> "$FEDPUNK_LOG_FILE"

info "Bootstrap: Installing Fish Shell"
if bash "$FEDPUNK_INSTALL/bootstrap-fish.sh"; then
    INSTALL_STEPS+=("✓ Bootstrap: Fish Shell")
    success "Bootstrap completed"
else
    error "Bootstrap failed"
    echo ""
    echo -e "${C_RED}Installation cannot continue without Fish shell${C_RESET}"
    echo "Check log file: $FEDPUNK_LOG_FILE"
    exit 1
fi

# Step 2: Everything else runs in Fish
echo ""
info "Switching to Fish for remaining installation steps"
echo ""

# Export log file path for Fish to use
export FEDPUNK_LOG_FILE

# Run each installation phase with proper logging
run_fish_script "$FEDPUNK_INSTALL/preflight/all.fish" "System Setup & Preflight Checks"
run_fish_script "$FEDPUNK_INSTALL/packaging/all.fish" "Package Installation"
run_fish_script "$FEDPUNK_INSTALL/config/all.fish" "Configuration Deployment"
run_fish_script "$FEDPUNK_INSTALL/post-install/all.fish" "Post-Installation Setup"

echo ""
echo "========================================" >> "$FEDPUNK_LOG_FILE"
echo "INSTALLATION SUMMARY" >> "$FEDPUNK_LOG_FILE"
echo "Completed at: $(date)" >> "$FEDPUNK_LOG_FILE"
echo "========================================" >> "$FEDPUNK_LOG_FILE"
echo "" >> "$FEDPUNK_LOG_FILE"
echo "Steps executed:" >> "$FEDPUNK_LOG_FILE"
for step in "${INSTALL_STEPS[@]}"; do
    echo "  $step" >> "$FEDPUNK_LOG_FILE"
done
echo "" >> "$FEDPUNK_LOG_FILE"

echo ""
echo -e "${C_GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}"
echo -e "${C_GREEN}🎉 Fedpunk installation complete!${C_RESET}"
echo -e "${C_GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}"
echo ""
echo -e "${C_BLUE}📋 Installation Summary:${C_RESET}"
for step in "${INSTALL_STEPS[@]}"; do
    echo "  $step"
done
echo ""
echo -e "${C_BLUE}🚀 Next steps:${C_RESET}"
echo "  • Restart your terminal or run: exec fish"
echo "  • Log out and select 'Hyprland' from your display manager"
echo "  • Or run 'Hyprland' from a TTY"
echo ""
echo -e "${C_BLUE}⌨️  Hyprland key bindings:${C_RESET}"
echo "  Super+Return: Terminal    │  Super+Space: Launcher"
echo "  Super+Q: Close window     │  Super+Ctrl+T: Theme selector"
echo "  Super+1-9: Workspaces     │  Print: Screenshot"
echo ""
echo -e "${C_GRAY}📄 Full installation log saved to: $FEDPUNK_LOG_FILE${C_RESET}"
echo ""
