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

# Deploy configuration
if test -d "$FEDPUNK_PATH"
    cd "$FEDPUNK_PATH"
    run_quiet "Deploying lazygit config" stow --restow -d config -t "$HOME" lazygit
else
    error "FEDPUNK_PATH not set or directory doesn't exist: $FEDPUNK_PATH"
    exit 1
end

success "lazygit setup complete"
