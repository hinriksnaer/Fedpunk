#!/usr/bin/env fish
# btop - Resource monitor
# End-to-end setup: install package → deploy config

# FEDPUNK_PATH and FEDPUNK_INSTALL should be set by parent install.fish
# Source helper functions
if test -f "$FEDPUNK_INSTALL/helpers/all.fish"
    source "$FEDPUNK_INSTALL/helpers/all.fish"
end

echo ""
info "Setting up btop"

# Install package
step "Installing btop package" "sudo dnf install -qy btop"

# Deploy configuration
if test -d "$FEDPUNK_PATH"
    cd "$FEDPUNK_PATH"
    run_quiet "Deploying btop config" stow --restow -d config -t "$HOME" btop
else
    error "FEDPUNK_PATH not set or directory doesn't exist: $FEDPUNK_PATH"
    exit 1
end

success "btop setup complete"
