#!/usr/bin/env fish

# Source helper functions
set -gx FEDPUNK_INSTALL "$HOME/.local/share/fedpunk/install"
if test -f "$FEDPUNK_INSTALL/helpers/all.fish"
    source "$FEDPUNK_INSTALL/helpers/all.fish"
end

step "Installing btop" "sudo dnf install -qy btop"
