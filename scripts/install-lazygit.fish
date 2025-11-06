#!/usr/bin/env fish

# Get target directory (either /root or /home/USER)
set TARGET_DIR (test (id -u) -eq 0; and echo "/root"; or echo "/home/"(whoami))

cd (dirname (status -f))/../

echo "→ Installing lazygit"

# Enable COPR repository for lazygit
sudo dnf install -qy dnf-plugins-core
sudo dnf copr enable -qy atim/lazygit

# Install lazygit
sudo dnf upgrade --refresh -qy
sudo dnf install -qy lazygit

# Stow the configuration
stow -t $TARGET_DIR lazygit

echo "✓ lazygit installation complete"