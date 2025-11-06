#!/usr/bin/env bash
set -euo pipefail

# --- figure out whose home to target (works with/without sudo) ---
if [ "$EUID" -eq 0 ]; then
  if [ -n "${SUDO_USER:-}" ] && [ "$SUDO_USER" != "root" ]; then
    TARGET_USER="$SUDO_USER"
    TARGET_HOME="$(getent passwd "$SUDO_USER" | cut -d: -f6)"
  else
    TARGET_USER="root"
    TARGET_HOME="/root"
  fi
else
  TARGET_USER="$(whoami)"
  TARGET_HOME="$HOME"
fi

echo "→ Installing Neovim and its dependencies for user: $TARGET_USER ($TARGET_HOME)"

# --- packages (system-wide) ---
packages=(
  ripgrep
  fzf
)

# Use sudo for package ops if not root
SUDO=""
[ "$EUID" -ne 0 ] && SUDO="sudo"

$SUDO dnf upgrade --refresh -qy
$SUDO dnf install -yq "${packages[@]}"

# --- user-local Neovim install (no sudo) ---
TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

mkdir -p "$TARGET_HOME/.local" "$TARGET_HOME/.local/bin"

curl -fL --retry 3 -o "$TMPDIR/nvim.tar.gz" \
  "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz"

# Extract into ~/.local (folder will be nvim-linux-x86_64)
tar -xzf "$TMPDIR/nvim.tar.gz" -C "$TARGET_HOME/.local"

# Symlink to ~/.local/bin
ln -sfn "$TARGET_HOME/.local/nvim-linux-x86_64/bin/nvim" \
        "$TARGET_HOME/.local/bin/nvim"

# Ensure ownership if script was run with sudo
if [ "$EUID" -eq 0 ] && [ "$TARGET_USER" != "root" ]; then
  chown -R "$TARGET_USER":"$TARGET_USER" "$TARGET_HOME/.local"
fi

# --- ensure ~/.local/bin is on PATH for future shells ---
add_path_line='export PATH="$HOME/.local/bin:$PATH"'
for rc in "$TARGET_HOME/.bashrc" "$TARGET_HOME/.zshrc"; do
  if [ -f "$rc" ] && ! grep -qF "$add_path_line" "$rc"; then
    echo "$add_path_line" >> "$rc"
  fi
done

cd "$(dirname "${BASH_SOURCE[0]}")/.."

# Neovim config is typically a 'neovim' (or 'nvim') dir in the repo:
if [ -d "neovim" ]; then
  echo "Stowing neovim → $TARGET_HOME"
  stow -t "$TARGET_HOME" neovim
elif [ -d "nvim" ]; then
  echo "Stowing nvim → $TARGET_HOME"
  stow -t "$TARGET_HOME" nvim
else
  echo "No 'neovim' or 'nvim' dir in repo; skipping stow for Neovim config"
fi

echo "✓ Done. Make sure your shell loads ~/.bashrc or ~/.zshrc, then run: nvim --version"
