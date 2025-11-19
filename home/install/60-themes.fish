#!/usr/bin/env fish
# ============================================================================
# THEMES: Setup Fedpunk theme system
# ============================================================================
# Purpose:
#   - Discover available themes
#   - Set default theme (ayu-mirage)
#   - Link theme configs for terminal and desktop apps
# Runs: When theme files change (run_onchange)
# ============================================================================

# Skip if container mode
if test "$FEDPUNK_MODE" = "container"
    info "Skipping theme setup (container mode)"
    exit 0
end

source "$FEDPUNK_PATH/lib/helpers.fish"

section "Theme System Setup"

# Create theme directories
step "Creating theme directories" "mkdir -p ~/.config/fedpunk/themes ~/.config/fedpunk/current"

# Discover and link themes
subsection "Discovering themes"
for theme_dir in $FEDPUNK_PATH/themes/*
    if test -d "$theme_dir"
        set theme_name (basename "$theme_dir")
        ln -snf "$theme_dir" ~/.config/fedpunk/themes/
        info "Linked theme: $theme_name"
    end
end

# Set default theme
subsection "Setting default theme"
if test -d "$FEDPUNK_PATH/themes/ayu-mirage"
    ln -snf "$FEDPUNK_PATH/themes/ayu-mirage" ~/.config/fedpunk/current/theme
    success "Default theme set to ayu-mirage"
else
    set first_theme (ls -1 $FEDPUNK_PATH/themes | head -1)
    if test -n "$first_theme"
        ln -snf "$FEDPUNK_PATH/themes/$first_theme" ~/.config/fedpunk/current/theme
        success "Default theme set to $first_theme"
    else
        warning "No themes found"
    end
end

# Link terminal app themes
subsection "Setting up terminal themes"
mkdir -p ~/.config/btop/themes

if test -f ~/.config/fedpunk/current/theme/btop.theme
    ln -snf ~/.config/fedpunk/current/theme/btop.theme ~/.config/btop/themes/active.theme
    success "btop theme linked"
end

if test -d ~/.config/nvim; and test -f ~/.config/fedpunk/current/theme/neovim.lua
    mkdir -p ~/.config/nvim/lua/plugins
    cp ~/.config/fedpunk/current/theme/neovim.lua ~/.config/nvim/lua/plugins/colorscheme.lua
    success "Neovim theme configured"
end

# Link desktop app themes (if desktop mode)
if test "$FEDPUNK_MODE" != "container"
    subsection "Setting up desktop themes"

    if test -f ~/.config/fedpunk/current/theme/kitty.conf
        ln -snf ~/.config/fedpunk/current/theme/kitty.conf ~/.config/kitty/theme.conf
        success "Kitty theme linked"
    end

    if test -f ~/.config/fedpunk/current/theme/mako.conf
        ln -snf ~/.config/fedpunk/current/theme/mako.conf ~/.config/mako/theme.conf
        success "Mako theme linked"
    end

    if test -f ~/.config/fedpunk/current/theme/rofi.rasi
        ln -snf ~/.config/fedpunk/current/theme/rofi.rasi ~/.config/rofi/theme.rasi
        success "Rofi theme linked"
    end

    if test -f ~/.config/fedpunk/current/theme/waybar.css
        ln -snf ~/.config/fedpunk/current/theme/waybar.css ~/.config/waybar/theme.css
        success "Waybar theme linked"
    end

    # Set default wallpaper
    if test -d ~/.config/fedpunk/current/theme/backgrounds
        mkdir -p ~/.config/hypr/wallpapers
        set first_bg (ls ~/.config/fedpunk/current/theme/backgrounds/*.{png,jpg,jpeg} 2>/dev/null | head -1)
        if test -n "$first_bg"
            ln -snf "$first_bg" ~/.config/hypr/wallpapers/current
            success "Default wallpaper set"
        end
    end
end

echo ""
box "Theme System Ready!" $GUM_SUCCESS
