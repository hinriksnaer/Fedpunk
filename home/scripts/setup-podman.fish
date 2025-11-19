#!/usr/bin/env fish
# Setup Podman for development and devcontainers

# Source helper functions (handle both standalone and profile activation modes)
if test -f "$FEDPUNK_INSTALL/helpers/all.fish"
    source "$FEDPUNK_INSTALL/helpers/all.fish"
else if test -f "$HOME/.local/share/fedpunk/install/helpers/all.fish"
    set -gx FEDPUNK_INSTALL "$HOME/.local/share/fedpunk/install"
    source "$FEDPUNK_INSTALL/helpers/all.fish"
end

section "Podman Setup"

subsection "Installing Podman"

install_packages podman podman-compose podman-docker

subsection "Configuring Podman"

# Enable and start podman socket for Docker API compatibility
step "Enabling Podman socket" "systemctl --user enable podman.socket"
info "Starting Podman socket..."
systemctl --user start podman.socket 2>/dev/null || true
if systemctl --user is-active --quiet podman.socket
    success "Podman socket is running"
else
    warning "Podman socket not started (may need manual start after login)"
end

# Add Docker socket alias for compatibility
if not test -S /var/run/docker.sock
    step "Setting up Docker compatibility symlink" "sudo ln -sf /run/user/(id -u)/podman/podman.sock /var/run/docker.sock"
end

# Configure for rootless operation
step "Configuring rootless podman" "sudo usermod --add-subuids 100000-165535 --add-subgids 100000-165535 (whoami)"

# Set Docker host environment variable
if not grep -q "DOCKER_HOST" ~/.config/fish/config.fish
    info "Adding DOCKER_HOST to fish config..."
    printf "\n# Podman Docker compatibility\n" >> ~/.config/fish/config.fish
    printf "set -gx DOCKER_HOST unix:///run/user/%s/podman/podman.sock\n" (id -u) >> ~/.config/fish/config.fish
    success "DOCKER_HOST configured"
else
    success "DOCKER_HOST already configured"
end

echo ""
box "Podman Setup Complete!

✓ Podman installed
✓ Docker compatibility enabled
✓ Rootless configuration complete

⚠️  Note: You may need to log out and back in for
   subuid/subgid changes to take effect

💡 Use podman commands just like docker:
  podman run, podman build, podman-compose, etc." $GUM_SUCCESS
echo ""
