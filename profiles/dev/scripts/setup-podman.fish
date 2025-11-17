#!/usr/bin/env fish
# Setup Podman for development and devcontainers

echo "🐳 Setting up Podman for development..."

# Install podman and related tools
echo "→ Installing Podman..."
sudo dnf install -y podman podman-compose podman-docker

# Enable and start podman socket for Docker API compatibility
echo "→ Enabling Podman socket..."
systemctl --user enable --now podman.socket

# Add Docker socket alias for compatibility
echo "→ Setting up Docker compatibility..."
if not test -S /var/run/docker.sock
    sudo ln -sf /run/user/(id -u)/podman/podman.sock /var/run/docker.sock 2>/dev/null || true
end

# Configure for rootless operation
echo "→ Configuring rootless podman..."
sudo usermod --add-subuids 100000-165535 --add-subgids 100000-165535 (whoami)

# Set Docker host environment variable
if not grep -q "DOCKER_HOST" ~/.config/fish/config.fish
    echo "→ Adding DOCKER_HOST to fish config..."
    echo "\n# Podman Docker compatibility" >> ~/.config/fish/config.fish
    echo "set -gx DOCKER_HOST unix:///run/user/(id -u)/podman/podman.sock" >> ~/.config/fish/config.fish
end

echo "✓ Podman setup complete!"
echo ""
echo "Note: You may need to log out and back in for subuid/subgid changes to take effect"
