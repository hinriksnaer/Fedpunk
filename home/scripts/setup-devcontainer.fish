#!/usr/bin/env fish
# Setup Devcontainer CLI for use with Podman
# Note: Requires Node.js/npm (installed by fedpunk essentials)

echo "📦 Setting up Devcontainer CLI..."

# Verify npm is available
if not command -v npm >/dev/null 2>&1
    echo "✗ npm not found. Please run fedpunk installation first."
    echo "  Node.js and npm are installed as part of fedpunk essentials."
    exit 1
end

# Install devcontainer CLI globally
echo "→ Installing @devcontainers/cli..."
sudo npm install -g @devcontainers/cli

# Verify installation
if command -v devcontainer >/dev/null 2>&1
    echo "✓ Devcontainer CLI installed successfully!"
    devcontainer --version
else
    echo "✗ Failed to install devcontainer CLI"
    exit 1
end

echo ""
echo "Usage:"
echo "  devcontainer up --workspace-folder ."
echo "  devcontainer exec --workspace-folder . fish"
echo ""
echo "Or use aliases (after deploying fish config):"
echo "  dc-up         # Start container"
echo "  dc-exec fish  # Execute shell in container"
echo "  dc-rebuild    # Rebuild from scratch"
echo ""
echo "Make sure Podman is running:"
echo "  systemctl --user start podman.socket"
