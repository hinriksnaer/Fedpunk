#!/usr/bin/env fish
# Neovim - Modern text editor
# Pure package installation (configs managed by chezmoi)

# Source helper functions
source "$FEDPUNK_INSTALL/helpers/all.fish"

install_if_missing "nvim" "neovim"
