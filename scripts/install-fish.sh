#!/usr/bin/env bash
set -euo pipefail

# Get either /root or /home/USER depending on the user
DIR=$(if [ "$(id -u)" -eq 0 ]; then echo "/root"; else echo "/home/$(whoami)"; fi)

cd "$(dirname "${BASH_SOURCE[0]}")/.."

echo "→ Installing Fish and dependencies"

sudo dnf copr enable -y atim/starship

sudo dnf upgrade --refresh -qy
sudo dnf install -qy fish starship

# # Try lsd via dnf first; fall back to cargo only if needed
if ! command -v lsd >/dev/null 2>&1; then
  if ! sudo dnf install -qy lsd; then
    sudo dnf install -qy cargo
    cargo install lsd
  fi
fi

stow -t "$DIR" fish

# Install fisher (fish plugin manager)
fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher"

# Install useful fish plugins
fish -c "fisher install PatrickF1/fzf.fish"

if ! command -v chsh &>/dev/null; then
  sudo dnf install -qy util-linux-user
fi

# Change shell for the current user (needs sudo if run inside devcontainer)
if command -v sudo &>/dev/null; then
  sudo chsh -s /usr/bin/fish "$(whoami)"
else
  chsh -s /usr/bin/fish
fi

echo "Fish setup complete."
