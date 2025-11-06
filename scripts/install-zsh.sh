#!/usr/bin/env bash
set -euo pipefail

# Get either /root or /home/USER depending on the user
DIR=$(if [ "$(id -u)" -eq 0 ]; then echo "/root"; else echo "/home/$(whoami)"; fi)

cd "$(dirname "${BASH_SOURCE[0]}")/.."

echo "→ Installing Zsh and dependencies"

sudo dnf copr enable -y atim/starship

sudo dnf upgrade --refresh -qy
sudo dnf install -qy zsh starship

# Try lsd via dnf first; fall back to cargo only if needed
if ! command -v lsd >/dev/null 2>&1; then
  if ! sudo dnf install -qy lsd; then
    sudo dnf install -qy cargo
    cargo install lsd
  fi
fi

stow -t "$DIR" zsh

# Install oh-my-zsh (run as user)
RUNZSH=no KEEP_ZSHRC=yes sh -c \
  "$(wget -O- https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

git clone https://github.com/zsh-users/zsh-autosuggestions \
  ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
  ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

wget -O ~/.oh-my-zsh/custom/themes/agnosterzak.zsh-theme \
  https://raw.githubusercontent.com/zakaziko99/agnosterzak-ohmyzsh-theme/master/agnosterzak.zsh-theme


if ! command -v chsh &>/dev/null; then
  sudo dnf install -qy util-linux-user
fi

# Change shell for the current user (needs sudo if run inside devcontainer)
if command -v sudo &>/dev/null; then
  sudo chsh -s /bin/zsh "$(whoami)"
else
  chsh -s /bin/zsh
fi

echo "Zsh setup complete."
