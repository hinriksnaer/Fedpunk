#!/usr/bin/env fish
# Setup Fedpunk theme system (similar to omarchy's theme.sh)

# Source helper functions
source "$FEDPUNK_INSTALL/helpers/all.fish"

info "Setting up theme system"

# Setup theme links
mkdir -p ~/.config/fedpunk/themes 2>>$FEDPUNK_LOG_FILE
for f in "$FEDPUNK_PATH/themes"/*
    if test -d "$f"
        ln -nfs "$f" ~/.config/fedpunk/themes/ 2>>$FEDPUNK_LOG_FILE
    end
end

# Set initial theme to default (ayu mirage)
mkdir -p ~/.config/fedpunk/current 2>>$FEDPUNK_LOG_FILE
if test -d "$FEDPUNK_PATH/themes/default"
    ln -snf ~/.config/fedpunk/themes/default ~/.config/fedpunk/current/theme 2>>$FEDPUNK_LOG_FILE
else
    # Use first available theme
    set first_theme (find "$FEDPUNK_PATH/themes" -mindepth 1 -maxdepth 1 -type d 2>>$FEDPUNK_LOG_FILE | head -1)
    if test -n "$first_theme"
        ln -snf "$first_theme" ~/.config/fedpunk/current/theme 2>>$FEDPUNK_LOG_FILE
    end
end

# Set initial background (first background found in current theme)
if test -L ~/.config/fedpunk/current/theme
    set first_bg (find ~/.config/fedpunk/current/theme/backgrounds -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" \) 2>>$FEDPUNK_LOG_FILE | sort | head -1)
    if test -n "$first_bg"
        mkdir -p ~/.config/hypr/wallpapers 2>>$FEDPUNK_LOG_FILE
        ln -snf "$first_bg" ~/.config/fedpunk/current/background 2>>$FEDPUNK_LOG_FILE
        ln -snf "$first_bg" ~/.config/hypr/wallpapers/current 2>>$FEDPUNK_LOG_FILE
    end
end

# Set specific app theme links for current theme
mkdir -p ~/.config/btop/themes 2>>$FEDPUNK_LOG_FILE
if test -f ~/.config/fedpunk/current/theme/btop.theme
    ln -snf ~/.config/fedpunk/current/theme/btop.theme ~/.config/btop/themes/current.theme 2>>$FEDPUNK_LOG_FILE
end

mkdir -p ~/.config/kitty 2>>$FEDPUNK_LOG_FILE
if test -f ~/.config/fedpunk/current/theme/kitty.conf
    ln -snf ~/.config/fedpunk/current/theme/kitty.conf ~/.config/kitty/theme.conf 2>>$FEDPUNK_LOG_FILE
end

# Add managed policy directories for Chromium and Brave for theme changes
run_quiet "Setting up browser policy directories" sh -c "sudo mkdir -p /etc/chromium/policies/managed /etc/brave/policies/managed && sudo chmod a+rw /etc/chromium/policies/managed /etc/brave/policies/managed"

set current_theme (basename (readlink ~/.config/fedpunk/current/theme 2>>$FEDPUNK_LOG_FILE) 2>>$FEDPUNK_LOG_FILE; or echo "default")
success "Theme system configured (current: $current_theme)"
