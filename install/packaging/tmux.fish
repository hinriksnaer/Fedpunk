#!/usr/bin/env fish
# tmux - Terminal multiplexer
# Pure package installation (configs managed by chezmoi)

# Source helper functions
source "$FEDPUNK_INSTALL/helpers/all.fish"

install_if_missing "tmux" "tmux"
