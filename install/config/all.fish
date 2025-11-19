#!/usr/bin/env fish
# Configuration Deployment
# Deploy configuration for all components

# Source helper functions
source "$FEDPUNK_INSTALL/helpers/all.fish"

info "Setting up all components"

# Terminal configurations (always run - chezmoi deploys them)
source "$FEDPUNK_INSTALL/config/btop.fish"
source "$FEDPUNK_INSTALL/config/neovim.fish"
source "$FEDPUNK_INSTALL/config/tmux.fish"
source "$FEDPUNK_INSTALL/config/lazygit.fish"

# Desktop configurations (conditional)
if not set -q FEDPUNK_INSTALL_KITTY; or test "$FEDPUNK_INSTALL_KITTY" = "true"
    source "$FEDPUNK_INSTALL/config/kitty.fish"
else
    info "Skipping Kitty configuration"
end

if not set -q FEDPUNK_INSTALL_HYPRLAND; or test "$FEDPUNK_INSTALL_HYPRLAND" = "true"
    source "$FEDPUNK_INSTALL/config/hyprland.fish"
else
    info "Skipping Hyprland configuration"
end

if not set -q FEDPUNK_INSTALL_ROFI; or test "$FEDPUNK_INSTALL_ROFI" = "true"
    source "$FEDPUNK_INSTALL/config/rofi.fish"
else
    info "Skipping Rofi configuration"
end
