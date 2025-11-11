#!/usr/bin/env fish
# Kitty - GPU-accelerated terminal emulator
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
info "Setting up Kitty"

# Install package
step "Installing kitty" "sudo dnf install -qy kitty"

# Deploy configuration
cd "$FEDPUNK_PATH"
run_quiet "Deploying kitty config" stow --restow -d config -t ~ kitty

success "Kitty setup complete"
