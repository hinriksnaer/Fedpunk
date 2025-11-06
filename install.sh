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
  nvidia
)

bash "./scripts/init.sh"

# --- Helper function to run installer ---
run_installer() {
  local name="$1"
  
  # Prefer Fish scripts if Fish is available and script exists
  if command -v fish >/dev/null 2>&1 && [ -f "./scripts/install-$name.fish" ]; then
    echo "→ Installing $name (using Fish)"
    fish "./scripts/install-$name.fish"
  elif [ -f "./scripts/install-$name.sh" ]; then
    echo "→ Installing $name (using Bash)"
    bash "./scripts/install-$name.sh"
  else
    echo "⚠️ No installer found for $name"
    return 1
  fi
}

# --- If no args → run all installers ---
if [ $# -eq 0 ]; then
  echo "→ No args provided, installing everything..."
  for name in "${installers[@]}"; do
    run_installer "$name"
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
        run_installer "$name"
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
