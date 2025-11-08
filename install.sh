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

# Log file
export FEDPUNK_LOG_FILE="/tmp/fedpunk-install-$(date +%Y%m%d-%H%M%S).log"
echo "Fedpunk Installation Log - $(date)" > "$FEDPUNK_LOG_FILE"
echo "=================================" >> "$FEDPUNK_LOG_FILE"

# Helper functions
info() { echo -e "${C_BLUE}→${C_RESET} $1"; echo "[INFO] $1" >> "$FEDPUNK_LOG_FILE"; }

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
bash "$FEDPUNK_INSTALL/bootstrap-fish.sh"

# Step 2: Everything else runs in Fish
info "Switching to Fish for remaining installation steps"
echo ""

fish "$FEDPUNK_INSTALL/preflight/all.fish"
fish "$FEDPUNK_INSTALL/packaging/all.fish"
fish "$FEDPUNK_INSTALL/config/all.fish"
fish "$FEDPUNK_INSTALL/post-install/all.fish"

echo ""
echo -e "${C_GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}"
echo -e "${C_GREEN}🎉 Fedpunk installation complete!${C_RESET}"
echo -e "${C_GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}"
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
echo -e "${C_GRAY}Installation log saved to: $FEDPUNK_LOG_FILE${C_RESET}"
echo ""
