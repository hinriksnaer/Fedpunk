# Installation Complete!

Your Fedpunk theme management scripts have been set up successfully, inspired by the omarchy design.

## What Was Created

### Scripts (in `~/Fedpunk/bin/`)

1. **fedpunk-theme-list** - List all available themes
2. **fedpunk-theme-current** - Show the active theme
3. **fedpunk-theme-set** - Switch to a specific theme
4. **fedpunk-theme-next** - Cycle to next theme
5. **fedpunk-theme-prev** - Cycle to previous theme
6. **fedpunk-theme-refresh** - Reapply current theme
7. **fedpunk-refresh-walker** - Refresh walker configuration
8. **fedpunk-wallpaper-next** - Cycle through wallpapers
9. **fedpunk-wallpaper-set** - Set wallpaper from theme

### Keybindings (Added to Hyprland)

- `Super + Shift + T` - Next theme
- `Super + Shift + Y` - Previous theme
- `Super + Shift + R` - Refresh theme
- `Super + Shift + W` - Next wallpaper

### Configuration Changes

1. **PATH updated** - Added `~/Fedpunk/bin` to your Fish shell PATH
2. **Keybindings updated** - Modified `~/.config/hypr/conf.d/keybinds.conf`

## Quick Start

### Using Scripts Directly

```fish
# List available themes
fedpunk-theme-list

# Check current theme
fedpunk-theme-current

# Switch to a specific theme
fedpunk-theme-set osaka-jade

# Cycle through themes
fedpunk-theme-next
fedpunk-theme-prev

# Refresh current theme
fedpunk-theme-refresh
```

### Using Keybindings

- Press `Super + Shift + T` to cycle through your themes
- Press `Super + Shift + Y` to go back to the previous theme
- Press `Super + Shift + R` to refresh the current theme

## Next Steps

1. **Install swaybg** (required for wallpaper support):
   ```fish
   sudo dnf install swaybg
   ```

2. **Reload your shell** to activate the PATH changes:
   ```fish
   source ~/.config/fish/config.fish
   ```

3. **Reload Hyprland** to activate the new keybindings:
   ```fish
   hyprctl reload
   ```

4. **Test it out!** Try cycling through themes with `Super + Shift + T`

## Adding More Themes

To add new themes, create a directory in `~/Fedpunk/themes/` with any of these files:

- `hyprland.conf` - Hyprland colors and styling
- `kitty.conf` - Kitty terminal theme (used by omarchy)
- `walker.css` - Walker launcher color variables
- `btop.theme` - btop system monitor theme
- `backgrounds/` - Directory containing wallpaper images (jpg, png, jpeg)

All files are optional!

### Walker Theme Integration

Walker now uses a custom theme system inspired by omarchy:
- Main style: `~/.local/share/fedpunk/walker/themes/fedpunk-default/style.css`
- Theme colors: Automatically imported from `walker.css` in your active theme
- Walker will restart automatically when switching themes for immediate updates

### Wallpaper Management

Wallpapers are managed using **swaybg** (like omarchy):
- Wallpapers are stored in each theme's `backgrounds/` directory
- The active wallpaper is symlinked at `~/.config/hypr/wallpapers/current`
- Wallpapers automatically change when switching themes
- Press `Super + Shift + W` to cycle through wallpapers in the current theme

**Note:** You need to install swaybg: `sudo dnf install swaybg`

## Clean Up (Optional)

Your `~/.config/fish/config.fish` has some duplicate entries. You may want to clean those up manually if desired.
