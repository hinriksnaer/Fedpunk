#!/usr/bin/env fish
# lazygit - Git terminal UI
# End-to-end setup: install package → deploy config

# Source helper functions
if not set -q FEDPUNK_INSTALL
    set -gx FEDPUNK_INSTALL "$HOME/.local/share/fedpunk/install"
end
if not set -q FEDPUNK_PATH
    set -gx FEDPUNK_PATH "$HOME/.local/share/fedpunk"
end
if test -f "$FEDPUNK_INSTALL/helpers/all.fish"
    source "$FEDPUNK_INSTALL/helpers/all.fish"
end

echo ""
info "Setting up lazygit"

# Enable COPR and install
step "Enabling lazygit COPR" "sudo dnf install -qy dnf-plugins-core && sudo dnf copr enable -qy atim/lazygit"
step "Installing lazygit" "sudo dnf install -qy lazygit"

# Deploy configuration
cd "$FEDPUNK_PATH"
run_quiet "Deploying lazygit config" stow --restow -d config -t "$HOME" lazygit

success "lazygit setup complete"
