# Hyprland Themes

This directory contains color themes for Hyprland. Themes are loaded dynamically via `active-theme.conf` symlink.

## Quick Start

**Switch themes:**
- **Super+Shift+T** - Cycle through themes
- `fish ~/.config/hypr/scripts/switch-theme.fish` - Cycle themes
- `fish ~/.config/hypr/scripts/switch-theme.fish <theme-name>` - Switch to specific theme

## Adding New Themes

### Method 1: Drop-in External Themes

Simply drop any `.conf` file with color definitions into this directory:

```bash
cd ~/.config/hypr/themes
wget https://raw.githubusercontent.com/user/theme-repo/main/hyprland.conf -O my-theme.conf
```

**Requirements:** Theme file must define these variables:
- `$accent_color` - Primary accent (active borders, highlights)
- `$inactive_color` - Inactive elements
- `$background` - Background color
- `$foreground` - Text/foreground color

**Optional colors** (recommended for completeness):
- `$black`, `$red`, `$green`, `$yellow`, `$blue`, `$magenta`, `$cyan`, `$white`

### Method 2: Create Your Own

Create a new `.conf` file in this directory:

```bash
# my-theme.conf
$accent_color = rgb(ff6699)
$inactive_color = rgba(44444480)
$background = rgb(1a1a1a)
$foreground = rgb(ffffff)

# Optional: full palette
$black = rgb(000000)
$red = rgb(ff0000)
# ... etc
```

### Method 3: Adapt External Themes

If a theme uses different variable names, create a wrapper:

```bash
# tokyo-night.conf
source = $HOME/.config/hypr/themes/external/tokyo-night-original.conf

# Map their variables to ours
$accent_color = $tokyonight_blue
$inactive_color = $tokyonight_comment
$background = $tokyonight_bg
$foreground = $tokyonight_fg
```

## Included Themes

- **default.conf** - Original coral/orange theme
- **ayu-mirage.conf** - Ayu Mirage (warm, pastel)
- **catppuccin-mocha.conf** - Catppuccin Mocha (purple accents)
- **nord.conf** - Nord (cool, blue)

## Color Format

Hyprland accepts colors in these formats:
- `rgb(RRGGBB)` - Solid color
- `rgba(RRGGBBAA)` - With alpha transparency
- No `#` prefix needed

## Notes

- Theme files are never modified by the switcher
- Only the `active-theme.conf` symlink changes
- Non-color settings (gaps, blur, etc.) are in `conf.d/variables.conf`
- Themes reload instantly with Super+Shift+T
