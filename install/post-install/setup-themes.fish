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
    # Try ayu-mirage first, then fall back to first available theme
    if test -d "'$FEDPUNK_PATH'/themes/ayu-mirage"
        ln -snf "'$FEDPUNK_PATH'/themes/ayu-mirage" ~/.config/fedpunk/current/theme
    else
        # Use first available theme
        set first_theme (find "'$FEDPUNK_PATH'/themes" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | head -1)
        if test -n "$first_theme"
            ln -snf "$first_theme" ~/.config/fedpunk/current/theme
        end
    end
'
success "Default theme set"

# Set up terminal application themes (btop, neovim)
gum spin --spinner dot --title "Setting up terminal themes..." -- fish -c '
    # btop theme (symlink is fine)
    mkdir -p ~/.config/btop/themes
    if test -f ~/.config/fedpunk/current/theme/btop.theme
        ln -snf ~/.config/fedpunk/current/theme/btop.theme ~/.config/btop/themes/active.theme
    end

    # neovim theme (copy instead of symlink - Lua module loader breaks with symlinks)
    # Only set up if neovim config directory exists
    if test -d ~/.config/nvim
        mkdir -p ~/.config/nvim/lua/plugins
        if test -L ~/.config/fedpunk/current/theme
            set theme_path (readlink ~/.config/fedpunk/current/theme)
            if test -f "$theme_path/neovim.lua"
                cp -f "$theme_path/neovim.lua" ~/.config/nvim/lua/plugins/theme.lua
            end
        else if test -f ~/.config/fedpunk/current/theme/neovim.lua
            cp -f ~/.config/fedpunk/current/theme/neovim.lua ~/.config/nvim/lua/plugins/theme.lua
        end
    end
'
success "Terminal themes set up"

# Desktop-only theme setup
if test "$FEDPUNK_MODE" != "container"
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

    # Kitty theme
    gum spin --spinner dot --title "Linking desktop themes..." -- fish -c '
        mkdir -p ~/.config/kitty
        if test -f ~/.config/fedpunk/current/theme/kitty.conf
            ln -snf ~/.config/fedpunk/current/theme/kitty.conf ~/.config/kitty/theme.conf
        end
    '
    success "Desktop themes linked"

    # Add managed policy directories for Chromium and Brave for theme changes
    # Setup browser policy directories (split into separate commands for reliability)
    if sudo mkdir -p /etc/chromium/policies/managed /etc/brave/policies/managed >>$FEDPUNK_LOG_FILE 2>&1
        if sudo chmod a+rw /etc/chromium/policies/managed /etc/brave/policies/managed >>$FEDPUNK_LOG_FILE 2>&1
            success "Browser policy directories set up"
        else
            warning "Failed to set permissions on browser policy directories"
        end
    else
        warning "Failed to create browser policy directories (may not be needed)"
    end
else
    info "Skipping desktop theme components (terminal-only mode)"
end

set current_theme (basename (readlink ~/.config/fedpunk/current/theme 2>/dev/null) 2>/dev/null; or echo "default")
echo ""
box "Theme system ready! Current: $current_theme" $GUM_SUCCESS
