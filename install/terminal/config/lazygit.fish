#!/usr/bin/env fish
# lazygit - Git terminal UI
# End-to-end setup: install package → deploy config

# FEDPUNK_PATH and FEDPUNK_INSTALL should be set by parent install.fish
# Source helper functions
if test -f "$FEDPUNK_INSTALL/helpers/all.fish"
    source "$FEDPUNK_INSTALL/helpers/all.fish"
end

echo ""
info "Setting up lazygit"

# Enable COPR and install
step "Enabling lazygit COPR" "sudo dnf install -qy dnf-plugins-core && sudo dnf copr enable -qy atim/lazygit"
step "Installing lazygit" "sudo dnf install --refresh -qy lazygit"

# Configuration will be deployed by chezmoi at end of installation
info "lazygit config prepared (will be deployed with chezmoi)"

success "lazygit setup complete"
