#!/usr/bin/env fish
# btop - System monitor
# Pure package installation (configs managed by chezmoi)

# Source helper functions
source "$FEDPUNK_INSTALL/helpers/all.fish"

install_if_missing "btop" "btop"
