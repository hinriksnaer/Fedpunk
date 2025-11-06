#!/bin/bash
set -e

echo "→ Init & update submodules"
git submodule sync --recursive
git submodule update --init --recursive


# ---- Privileged installs ----
sudo dnf install -y dnf-plugins-core

sudo dnf upgrade --refresh -y

#!/usr/bin/env bash
set -euo pipefail

# --- Available installers ---
installers=(
  btop
  lazygit
  neovim
  tmux
  fish
  foot
  hyprland
)

bash "./scripts/init.sh"

# --- If no args → run all installers ---
if [ $# -eq 0 ]; then
  echo "→ No args provided, installing everything..."
  for name in "${installers[@]}"; do
    echo "→ Installing $name"
    bash "./scripts/install-$name.sh"
  done
  exit 0
fi

# --- Otherwise: parse args like --neovim, --zsh, etc. ---
for arg in "$@"; do
  case "$arg" in
    --*)
      # Strip leading '--'
      name="${arg#--}"

      # Check if valid installer
      if [[ " ${installers[*]} " =~ " $name " ]]; then
        echo "→ Installing $name"
        bash "./scripts/install-$name.sh"
      else
        echo "⚠️ Unknown option: $arg"
        echo "   Valid options: ${installers[*]/#/--}"
        exit 1
      fi
      ;;
    *)
      echo "⚠️ Unexpected argument: $arg"
      echo "   Use flags like --neovim, --tmux, etc."
      exit 1
      ;;
  esac
done
