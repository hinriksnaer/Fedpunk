#!/usr/bin/env fish
# btop - Resource monitor
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
info "Setting up btop"

# Install package
step "Installing btop package" "sudo dnf install -qy btop"

# Deploy configuration
cd "$FEDPUNK_PATH"
run_quiet "Deploying btop config" stow --restow -d config -t "$HOME" btop

success "btop setup complete"
