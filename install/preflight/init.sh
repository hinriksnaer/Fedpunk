#!/usr/bin/env bash
set -euo pipefail

echo "→ Init & update submodules"
cd "$FEDPUNK_PATH"

# Check if git-lfs is needed for submodules
if git submodule status | grep -q "lfs"; then
    echo "→ Installing git-lfs for submodules..."
    sudo dnf install -qy git-lfs
    git lfs install
fi

git submodule sync --recursive
git submodule update --init --recursive

echo "→ Installing essential packages"

# Essential packages
packages=(
  stow
  nodejs
  npm
  curl
  wget
  which
)

# Enable RPM Fusion repositories for additional packages
echo "→ Enabling RPM Fusion repositories..."
sudo dnf install -qy \
    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm || true

sudo dnf upgrade --refresh -qy
sudo dnf install -qy "${packages[@]}"

# Verify Node.js version is compatible (>= 16)
node_version=$(node --version | sed 's/v//' | cut -d. -f1)
if [[ $node_version -lt 16 ]]; then
    echo "⚠️  Warning: Node.js version $node_version detected. Some components may require Node.js 16+."
fi


