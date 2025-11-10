#!/usr/bin/env fish

# Source helper functions
# Don't override FEDPUNK_INSTALL if it's already set
if not set -q FEDPUNK_INSTALL
    set -gx FEDPUNK_INSTALL "$HOME/.local/share/fedpunk/install"
end
if test -f "$FEDPUNK_INSTALL/helpers/all.fish"
    source "$FEDPUNK_INSTALL/helpers/all.fish"
end

step "Enabling lazygit COPR" "sudo dnf install -qy dnf-plugins-core && sudo dnf copr enable -qy atim/lazygit"
step "Installing lazygit" "sudo dnf install -qy lazygit"