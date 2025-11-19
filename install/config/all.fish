#!/usr/bin/env fish
# Configuration Deployment
# Deploy configuration for all components

# Source helper functions
source "$FEDPUNK_INSTALL/helpers/all.fish"

info "Setting up all components"

# Terminal configurations
source "$FEDPUNK_INSTALL/config/btop.fish"
source "$FEDPUNK_INSTALL/config/neovim.fish"
source "$FEDPUNK_INSTALL/config/tmux.fish"
source "$FEDPUNK_INSTALL/config/lazygit.fish"

# Desktop configurations
source "$FEDPUNK_INSTALL/config/kitty.fish"
source "$FEDPUNK_INSTALL/config/hyprland.fish"
source "$FEDPUNK_INSTALL/config/rofi.fish"
