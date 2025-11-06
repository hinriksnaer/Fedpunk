# Hyprland Configuration

This directory contains configuration for [Hyprland](https://hyprland.org/), a dynamic tiling Wayland compositor.

## Files

- **hyprland.conf** - Main Hyprland configuration
- **hyprpaper.conf** - Wallpaper configuration for hyprpaper
- **wallpapers/** - Directory for your wallpapers

## Key Bindings

The configuration uses `SUPER` (Windows/Command key) as the main modifier:

### Applications
- `SUPER + RETURN` - Open terminal (foot)
- `SUPER + R` - Application launcher (rofi)
- `SUPER + E` - File manager (thunar)
- `SUPER + Q` - Close active window
- `SUPER + M` - Exit Hyprland

### Window Management
- `SUPER + V` - Toggle floating mode
- `SUPER + J` - Toggle split mode
- `SUPER + arrow keys` or `SUPER + h/j/k/l` - Move focus between windows

### Workspaces
- `SUPER + [1-9,0]` - Switch to workspace
- `SUPER + SHIFT + [1-9,0]` - Move window to workspace
- `SUPER + S` - Toggle scratchpad
- `SUPER + mouse scroll` - Cycle through workspaces

### Media Keys
- `XF86AudioRaiseVolume/LowerVolume` - Volume control
- `XF86AudioMute` - Mute audio
- `XF86MonBrightnessUp/Down` - Screen brightness
- `Print` - Screenshot (selection)
- `SHIFT + Print` - Screenshot (full screen)

## Customization

### Wallpaper
1. Place your wallpaper image at `~/.config/hypr/wallpapers/default.jpg`
2. Or edit `hyprpaper.conf` to point to your preferred wallpaper location

### Monitor Configuration
Edit the `monitor=` line in `hyprland.conf`:
```
monitor=DP-1,1920x1080@144,0x0,1
```

See monitor names with: `hyprctl monitors`

### Themes and Colors
- Border colors: Search for `col.active_border` and `col.inactive_border`
- Gaps: Adjust `gaps_in` and `gaps_out`
- Rounding: Modify `rounding` value

## Dependencies

The install script installs these packages:
- hyprland - The compositor itself
- hyprpaper - Wallpaper daemon
- waybar - Status bar
- dunst - Notification daemon
- rofi-wayland - Application launcher
- grim, slurp - Screenshot tools
- wl-clipboard - Wayland clipboard utilities
- brightnessctl - Brightness control
- pipewire, wireplumber - Audio server
- xdg-desktop-portal-hyprland - Desktop portal
- thunar - File manager
- foot - Terminal (configured separately)

## Starting Hyprland

From a TTY (not within another desktop environment):
```bash
Hyprland
```

Or add it to your display manager's session list.

## More Information

- [Hyprland Wiki](https://wiki.hyprland.org/)
- [Hyprland GitHub](https://github.com/hyprwm/Hyprland)
