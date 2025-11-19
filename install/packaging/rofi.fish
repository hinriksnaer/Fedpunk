#!/usr/bin/env fish
# Rofi - Application launcher
# Pure package installation (configs managed by chezmoi)

# Source helper functions
source "$FEDPUNK_INSTALL/helpers/all.fish"

install_if_missing "rofi" "rofi"
