#!/usr/bin/env bash
set -euo pipefail

# Get either /root or /home/USER depending on the user
DIR=$(if [ "$(id -u)" -eq 0 ]; then echo "/root"; else echo "/home/$(whoami)"; fi)

cd "$(dirname "${BASH_SOURCE[0]}")/.."

echo "→ Installing packages tmux"

# Packages to install
packages=(
  tmux
)

sudo dnf upgrade --refresh -qy
sudo dnf install -qy "${packages[@]}"

stow -t "$DIR" tmux

echo "setting up tmux"
# Setup tmux plugins
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

token=tpm_done

tmux start-server \; \
  set -g exit-empty off \; \
  source-file ~/.config/tmux/tmux.conf \; \
  run-shell "~/.tmux/plugins/tpm/scripts/install_plugins.sh && tmux wait-for -S $token" \; \
  wait-for "$token" \; \
  set -g exit-empty on
echo "tmux setup complete."
