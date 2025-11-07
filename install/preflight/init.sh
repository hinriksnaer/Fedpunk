#!/usr/bin/env bash
set -euo pipefail

echo "→ Init & update submodules"
git submodule sync --recursive
git submodule update --init --recursive

echo "→ Installing stow"

# Packages to install
packages=(
  stow
  node
)

sudo dnf upgrade --refresh -qy
sudo dnf install -qy "${packages[@]}"


