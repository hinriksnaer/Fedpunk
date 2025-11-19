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

# Configuration will be deployed by chezmoi at end of installation
info "btop config prepared (will be deployed with chezmoi)"

success "btop setup complete"
