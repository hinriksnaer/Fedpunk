#!/usr/bin/env bash
set -euo pipefail

# Get either /root or /home/USER depending on the user
DIR=$(if [ "$(id -u)" -eq 0 ]; then echo "/root"; else echo "/home/$(whoami)"; fi)

cd "$(dirname "${BASH_SOURCE[0]}")/.."

echo "’ Installing Hyprland and dependencies"

# Enable COPR repository for Hyprland
sudo dnf copr enable -y solopasha/hyprland

sudo dnf upgrade --refresh -qy

# Core Hyprland packages
packages=(
  hyprland
  hyprpaper
  dunst
  wofi
  grim
  slurp
  wl-clipboard
  foot
  thunar
  pavucontrol
  playerctl
  wpctl
)

sudo dnf install -qy "${packages[@]}"

# Create wallpapers directory and add a simple default wallpaper
mkdir -p "$DIR/.config/hypr/wallpapers"

# Create a simple solid color wallpaper if none exists
if [ ! -f "$DIR/.config/hypr/wallpapers/default.jpg" ]; then
  # Create a simple 1920x1080 solid color image using ImageMagick if available
  if command -v convert >/dev/null 2>&1; then
    convert -size 1920x1080 xc:'#2e3440' "$DIR/.config/hypr/wallpapers/default.jpg"
  else
    echo "Warning: ImageMagick not found. Please add a wallpaper to ~/.config/hypr/wallpapers/default.jpg"
  fi
fi

# Stow the configuration
stow -t "$DIR" hyprland

echo " Hyprland setup complete."
echo "  To start Hyprland, log out and select 'Hyprland' from your display manager,"
echo "  or run 'Hyprland' from a TTY."
echo ""
echo "  Key bindings:"
echo "    Super+Q: Open terminal (foot)"
echo "    Super+R: Open application launcher (wofi)"
echo "    Super+C: Close window"
echo "    Super+M: Exit Hyprland"
echo "    Super+[1-9]: Switch workspace"
echo "    Print: Screenshot area to clipboard"