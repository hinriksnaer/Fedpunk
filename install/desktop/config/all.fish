#!/usr/bin/env fish
# Desktop Configuration Deployment
# Deploy configuration for desktop components

# Source helper functions
source "$FEDPUNK_INSTALL/helpers/all.fish"

info "Setting up desktop components"

fish "$FEDPUNK_INSTALL/desktop/config/kitty.fish"
fish "$FEDPUNK_INSTALL/desktop/config/hyprland.fish"
fish "$FEDPUNK_INSTALL/desktop/config/rofi.fish"
