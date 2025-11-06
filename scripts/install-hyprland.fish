#!/usr/bin/env fish

# Get target directory (either /root or /home/USER)
set TARGET_DIR (test (id -u) -eq 0; and echo "/root"; or echo "/home/"(whoami))

cd (dirname (status -f))/../

echo "→ Installing Hyprland and dependencies"

# Enable COPR repository for Hyprland
sudo dnf copr enable -y solopasha/hyprland

sudo dnf upgrade --refresh -qy

# Core Hyprland packages
set packages \
  hyprland \
  hyprpaper \
  dunst \
  wofi \
  grim \
  slurp \
  wl-clipboard \
  foot \
  thunar \
  pavucontrol \
  playerctl \
  wpctl \
  polkit-gnome \
  xdg-desktop-portal-hyprland \
  xdg-desktop-portal-gtk

sudo dnf install -qy $packages

# Create wallpapers directory and add a simple default wallpaper
mkdir -p "$TARGET_DIR/.config/hypr/wallpapers"

# Create a simple solid color wallpaper if none exists
if not test -f "$TARGET_DIR/.config/hypr/wallpapers/default.jpg"
    # Create a simple 1920x1080 solid color image using ImageMagick if available
    if command -v convert >/dev/null 2>&1
        convert -size 1920x1080 xc:'#2e3440' "$TARGET_DIR/.config/hypr/wallpapers/default.jpg"
    else
        echo "⚠️ ImageMagick not found. Please add a wallpaper to ~/.config/hypr/wallpapers/default.jpg"
    end
end

# Stow the configuration
stow -t $TARGET_DIR hyprland

echo ""
echo "✓ Hyprland setup complete!"
echo ""
echo "To start Hyprland:"
echo "  - Log out and select 'Hyprland' from your display manager"
echo "  - Or run 'Hyprland' from a TTY"
echo ""
echo "Key bindings:"
echo "  Super+Q: Open terminal (foot)"
echo "  Super+R: Open application launcher (wofi)"
echo "  Super+C: Close window"
echo "  Super+M: Exit Hyprland"
echo "  Super+[1-9]: Switch workspace"
echo "  Print: Screenshot area to clipboard"