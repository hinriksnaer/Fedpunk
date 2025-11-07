#!/usr/bin/env fish

# Get target directory (either /root or /home/USER)
set TARGET_DIR (test (id -u) -eq 0; and echo "/root"; or echo "/home/"(whoami))

sudo dnf install btop

cd (dirname (status -f))/../

echo "→ Installing btop configuration"

# Stow the configuration
stow -t $TARGET_DIR btop

echo "✓ btop configuration installed"
