#!/usr/bin/env fish
# Setup Fedpunk theme system (similar to omarchy's theme.sh)

# Source helper functions
source "$FEDPUNK_INSTALL/helpers/all.fish"

info "Setting up theme system"

# Setup theme links
step "Creating theme directories" "mkdir -p ~/.config/fedpunk/themes"

gum spin --spinner moon --title "Discovering themes..." -- fish -c '
    for f in "'$FEDPUNK_PATH'/themes"/*
        if test -d "$f"
            ln -nfs "$f" ~/.config/fedpunk/themes/
        end
    end
'
success "Theme links created"

# Set initial theme to default (ayu mirage)
step "Initializing theme directories" "mkdir -p ~/.config/fedpunk/current"

gum spin --spinner dot --title "Setting default theme..." -- fish -c '
    if test -d "'$FEDPUNK_PATH'/themes/default"
        ln -snf ~/.config/fedpunk/themes/default ~/.config/fedpunk/current/theme
    else
        # Use first available theme
        set first_theme (find "'$FEDPUNK_PATH'/themes" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | head -1)
        if test -n "$first_theme"
            ln -snf "$first_theme" ~/.config/fedpunk/current/theme
        end
    end
'
success "Default theme set"

# Set initial background
gum spin --spinner dot --title "Configuring wallpaper..." -- fish -c '
    if test -L ~/.config/fedpunk/current/theme
        set first_bg (find ~/.config/fedpunk/current/theme/backgrounds -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" \) 2>/dev/null | sort | head -1)
        if test -n "$first_bg"
            mkdir -p ~/.config/hypr/wallpapers
            ln -snf "$first_bg" ~/.config/fedpunk/current/background
            ln -snf "$first_bg" ~/.config/hypr/wallpapers/current
        end
    end
'
success "Wallpaper configured"

# Set specific app theme links
gum spin --spinner dot --title "Linking application themes..." -- fish -c '
    mkdir -p ~/.config/btop/themes
    if test -f ~/.config/fedpunk/current/theme/btop.theme
        ln -snf ~/.config/fedpunk/current/theme/btop.theme ~/.config/btop/themes/current.theme
    end

    mkdir -p ~/.config/kitty
    if test -f ~/.config/fedpunk/current/theme/kitty.conf
        ln -snf ~/.config/fedpunk/current/theme/kitty.conf ~/.config/kitty/theme.conf
    end
'
success "Application themes linked"

# Add managed policy directories for Chromium and Brave for theme changes
run_quiet "Setting up browser policy directories" sh -c "sudo mkdir -p /etc/chromium/policies/managed /etc/brave/policies/managed && sudo chmod a+rw /etc/chromium/policies/managed /etc/brave/policies/managed"

set current_theme (basename (readlink ~/.config/fedpunk/current/theme 2>/dev/null) 2>/dev/null; or echo "default")
echo ""
box "Theme system ready! Current: $current_theme" $GUM_SUCCESS
