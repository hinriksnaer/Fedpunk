#!/usr/bin/env fish

# Source helper functions
set -gx FEDPUNK_INSTALL "$HOME/.local/share/fedpunk/install"
if test -f "$FEDPUNK_INSTALL/helpers/all.fish"
    source "$FEDPUNK_INSTALL/helpers/all.fish"
end

step "Enabling lazygit COPR" "sudo dnf install -qy dnf-plugins-core && sudo dnf copr enable -qy atim/lazygit"
step "Installing lazygit" "sudo dnf install -qy lazygit"