#!/usr/bin/env fish
# Terminal Configuration Deployment
# Deploy configuration for terminal-only components

# Source helper functions
source "$FEDPUNK_INSTALL/helpers/all.fish"

info "Setting up terminal components"

# Source scripts instead of running in new shells to preserve environment variables
source "$FEDPUNK_INSTALL/terminal/config/btop.fish"
source "$FEDPUNK_INSTALL/terminal/config/neovim.fish"
source "$FEDPUNK_INSTALL/terminal/config/tmux.fish"
source "$FEDPUNK_INSTALL/terminal/config/lazygit.fish"
