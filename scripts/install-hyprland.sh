#!/usr/bin/env bash
set -euo pipefail

# Get either /root or /home/USER depending on the user
DIR=$(if [ "$(id -u)" -eq 0 ]; then echo "/root"; else echo "/home/$(whoami)"; fi)

cd "$(dirname "${BASH_SOURCE[0]}")/.."

echo "’ Installing packages: hyprland and related tools"

# Packages to install
packages=(
  hyprland
  hyprpaper
  waybar
  dunst
  rofi-wayland
  grim
  slurp
  wl-clipboard
  brightnessctl
  pipewire
  wireplumber
  xdg-desktop-portal-hyprland
  qt6ct
  thunar
)

sudo dnf upgrade --refresh -qy
sudo dnf install -qy "${packages[@]}"

# Use stow to symlink configs
stow -t "$DIR" hyprland

echo "’ Hyprland configuration installed successfully!"
echo "’ Note: Add your wallpaper to ~/.config/hypr/wallpapers/default.jpg"
echo "’ You can start Hyprland by running 'Hyprland' from a TTY"
