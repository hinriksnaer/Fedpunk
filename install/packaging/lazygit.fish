#!/usr/bin/env fish
# lazygit - Git TUI
# Uses COPR repository for latest version

# Source helper functions
source "$FEDPUNK_INSTALL/helpers/all.fish"

if command -v lazygit >/dev/null 2>&1
    success "lazygit already installed"
else
    step "Enabling lazygit COPR" "$SUDO_CMD dnf install -qy dnf-plugins-core && $SUDO_CMD dnf copr enable -qy atim/lazygit"
    step "Installing lazygit" "$SUDO_CMD dnf install --refresh -qy lazygit"
end
