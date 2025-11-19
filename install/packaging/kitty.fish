#!/usr/bin/env fish
# Kitty - GPU-accelerated terminal emulator
# Pure package installation (configs managed by chezmoi)

# Source helper functions
source "$FEDPUNK_INSTALL/helpers/all.fish"

install_if_missing "kitty" "kitty"
