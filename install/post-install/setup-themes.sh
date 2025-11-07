#!/bin/bash
# Setup Fedpunk theme system (similar to omarchy's theme.sh)

echo "→ Setting up Fedpunk themes"

# Setup theme links
mkdir -p ~/.config/fedpunk/themes
for f in "$FEDPUNK_PATH/themes"/*; do
    if [ -d "$f" ]; then
        ln -nfs "$f" ~/.config/fedpunk/themes/
    fi
done

# Set initial theme to catppuccin (or first available theme)
mkdir -p ~/.config/fedpunk/current
if [ -d "$FEDPUNK_PATH/themes/catppuccin" ]; then
    ln -snf ~/.config/fedpunk/themes/catppuccin ~/.config/fedpunk/current/theme
else
    # Use first available theme
    first_theme=$(find "$FEDPUNK_PATH/themes" -mindepth 1 -maxdepth 1 -type d | head -1)
    if [ -n "$first_theme" ]; then
        ln -snf "$first_theme" ~/.config/fedpunk/current/theme
    fi
fi

# Set initial background (first background found in current theme)
if [ -L ~/.config/fedpunk/current/theme ]; then
    first_bg=$(find ~/.config/fedpunk/current/theme/backgrounds -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" \) 2>/dev/null | sort | head -1)
    if [ -n "$first_bg" ]; then
        mkdir -p ~/.config/hypr/wallpapers
        ln -snf "$first_bg" ~/.config/fedpunk/current/background
        ln -snf "$first_bg" ~/.config/hypr/wallpapers/current
    fi
fi

# Set specific app theme links for current theme
mkdir -p ~/.config/btop/themes
if [ -f ~/.config/fedpunk/current/theme/btop.theme ]; then
    ln -snf ~/.config/fedpunk/current/theme/btop.theme ~/.config/btop/themes/current.theme
fi

mkdir -p ~/.config/kitty
if [ -f ~/.config/fedpunk/current/theme/kitty.conf ]; then
    ln -snf ~/.config/fedpunk/current/theme/kitty.conf ~/.config/kitty/theme.conf
fi

# Add managed policy directories for Chromium and Brave for theme changes
sudo mkdir -p /etc/chromium/policies/managed 2>/dev/null || true
sudo chmod a+rw /etc/chromium/policies/managed 2>/dev/null || true

sudo mkdir -p /etc/brave/policies/managed 2>/dev/null || true
sudo chmod a+rw /etc/brave/policies/managed 2>/dev/null || true

echo "✅ Theme system configured"
echo "  • Default theme: $(basename $(readlink ~/.config/fedpunk/current/theme 2>/dev/null) 2>/dev/null || echo "none")"
echo "  • Switch themes: Super+Shift+T"
