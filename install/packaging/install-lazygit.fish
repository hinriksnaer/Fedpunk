#!/usr/bin/env fish

echo "→ Installing lazygit"

# Enable COPR repository for lazygit
sudo dnf install -qy dnf-plugins-core
sudo dnf copr enable -qy atim/lazygit

# Install lazygit
sudo dnf upgrade --refresh -qy
sudo dnf install -qy lazygit

echo "✓ lazygit installed"