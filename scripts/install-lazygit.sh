#!/usr/bin/env bash
set -euo pipefail

# Get either /root or /home/USER depending on the user
DIR=$(if [ "$(id -u)" -eq 0 ]; then echo "/root"; else echo "/home/$(whoami)"; fi)

cd "$(dirname "${BASH_SOURCE[0]}")/.."

echo "→ Installing packages"

# Packages to install
packages=(
  lazygit
)

# ---- Privileged installs ----
sudo dnf install -qy dnf-plugins-core
sudo dnf copr enable -qy atim/lazygit

sudo dnf upgrade --refresh -qy
sudo dnf install -qy "${packages[@]}"

stow -t "$DIR" lazygit


