#!/usr/bin/env fish
# Setup Fedpunk theme system (similar to omarchy's theme.sh)

echo "→ Setting up Fedpunk themes"

# Setup theme links
mkdir -p ~/.config/fedpunk/themes
for f in "$FEDPUNK_PATH/themes"/*
    if test -d "$f"
        ln -nfs "$f" ~/.config/fedpunk/themes/
    end
end

# Set initial theme to default (ayu mirage)
mkdir -p ~/.config/fedpunk/current
if test -d "$FEDPUNK_PATH/themes/default"
    ln -snf ~/.config/fedpunk/themes/default ~/.config/fedpunk/current/theme
else
    # Use first available theme
    set first_theme (find "$FEDPUNK_PATH/themes" -mindepth 1 -maxdepth 1 -type d | head -1)
    if test -n "$first_theme"
        ln -snf "$first_theme" ~/.config/fedpunk/current/theme
    end
end

# Set initial background (first background found in current theme)
if test -L ~/.config/fedpunk/current/theme
    set first_bg (find ~/.config/fedpunk/current/theme/backgrounds -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" \) 2>/dev/null | sort | head -1)
    if test -n "$first_bg"
        mkdir -p ~/.config/hypr/wallpapers
        ln -snf "$first_bg" ~/.config/fedpunk/current/background
        ln -snf "$first_bg" ~/.config/hypr/wallpapers/current
    end
end

# Set specific app theme links for current theme
mkdir -p ~/.config/btop/themes
if test -f ~/.config/fedpunk/current/theme/btop.theme
    ln -snf ~/.config/fedpunk/current/theme/btop.theme ~/.config/btop/themes/current.theme
end

mkdir -p ~/.config/kitty
if test -f ~/.config/fedpunk/current/theme/kitty.conf
    ln -snf ~/.config/fedpunk/current/theme/kitty.conf ~/.config/kitty/theme.conf
end

# Add managed policy directories for Chromium and Brave for theme changes
sudo mkdir -p /etc/chromium/policies/managed 2>/dev/null; or true
sudo chmod a+rw /etc/chromium/policies/managed 2>/dev/null; or true

sudo mkdir -p /etc/brave/policies/managed 2>/dev/null; or true
sudo chmod a+rw /etc/brave/policies/managed 2>/dev/null; or true

echo "✅ Theme system configured"
set current_theme (basename (readlink ~/.config/fedpunk/current/theme 2>/dev/null) 2>/dev/null; or echo "none")
echo "  • Default theme: $current_theme"
echo "  • Switch themes: Super+Shift+T"
