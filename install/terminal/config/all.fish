#!/usr/bin/env fish
# Terminal Configuration Deployment
# Deploy configuration for terminal-only components

# Source helper functions
source "$FEDPUNK_INSTALL/helpers/all.fish"

info "Setting up terminal components"

fish "$FEDPUNK_INSTALL/terminal/config/btop.fish"
fish "$FEDPUNK_INSTALL/terminal/config/neovim.fish"
fish "$FEDPUNK_INSTALL/terminal/config/tmux.fish"
fish "$FEDPUNK_INSTALL/terminal/config/lazygit.fish"
