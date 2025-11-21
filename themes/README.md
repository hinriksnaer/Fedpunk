# Fedpunk Themes

**11 carefully curated themes with live switching and complete color coordination**

---

## 🎨 Theme System Overview

Fedpunk's theme system provides **instant, system-wide color coordination** across:
- Hyprland (borders, shadows, gaps, blur)
- Kitty (terminal palette, live reload)
- Neovim (editor colorscheme, live reload via RPC)
- btop (system monitor colors, live reload)
- Rofi (application launcher)
- Mako (notifications, live reload)
- Waybar (status bar)
- Wallpapers (per-theme backgrounds)

**Key Features:**
- ✅ Instant switching with `Super+Shift+T`
- ✅ Live reload (no restart needed)
- ✅ Layout preservation (theme changes don't reset windows)
- ✅ Per-theme wallpapers
- ✅ Coordinated across all applications
- ✅ Easy custom theme creation

---

## 📚 Available Themes

| Theme | Style | Best For | Preview |
|-------|-------|----------|---------|
| **aetheria** | Ethereal purple/blue gradients | Creative work | [preview.png](aetheria/preview.png) |
| **ayu-mirage** | Warm desert tones | Extended coding sessions | [theme.png](ayu-mirage/theme.png) |
| **catppuccin** | Soothing pastel (mocha) | Low-light environments | [preview.png](catppuccin/preview.png) |
| **catppuccin-latte** | Light mode elegance | Bright workspaces | [preview.png](catppuccin-latte/preview.png) |
| **matte-black** | Pure minimalism | Distraction-free focus | [preview.png](matte-black/preview.png) |
| **nord** | Arctic cool tones | Scandinavian aesthetic | [preview.png](nord/preview.png) |
| **osaka-jade** | Vibrant teal/green | Energizing workflow | [preview.png](osaka-jade/preview.png) |
| **ristretto** | Rich espresso browns | Coffee-fueled coding | [preview.png](ristretto/preview.png) |
| **rose-pine** | Soft rose palette | Gentle on the eyes | [preview.png](rose-pine/preview.png) |
| **rose-pine-dark** | Dark rose variant | Night coding | [preview.png](rose-pine-dark/preview.png) |
| **tokyo-night** | Deep blues with neon accents | Cyberpunk vibes | [preview.png](tokyo-night/preview.png) |
| **torrentz-hydra** | Bold high contrast | Maximum readability | [preview.png](torrentz-hydra/preview.png) |

---

## 🚀 Quick Start

### Switch Themes

**Keyboard shortcuts (fastest):**
```
Super+Shift+T           # Next theme
Super+Shift+Y           # Previous theme
Super+T                 # Theme menu (Rofi)
Super+Shift+R           # Refresh current theme
Super+Shift+W           # Next wallpaper
```

**CLI commands:**
```bash
fedpunk-theme-list              # List all available themes
fedpunk-theme-set tokyo-night   # Switch to specific theme
fedpunk-theme-next              # Cycle forward
fedpunk-theme-prev              # Cycle backward
fedpunk-theme-current           # Show current theme
fedpunk-theme-refresh           # Reload current theme
```

### Set Wallpaper

```bash
fedpunk-wallpaper-next          # Next wallpaper for current theme
fedpunk-wallpaper-set ~/path/to/image.png  # Custom wallpaper
```

---

## 🏗️ Theme Structure

Each theme is a self-contained directory with configs for all applications:

```
themes/<theme-name>/
├── hyprland.conf        # Compositor: borders, gaps, shadows, blur
├── kitty.conf           # Terminal: color palette
├── neovim.lua           # Editor: colorscheme config
├── btop.theme           # System monitor: colors
├── rofi.rasi            # Launcher: appearance
├── waybar.css           # Status bar: styling
├── mako.conf            # Notifications: styling
└── wallpapers/          # Theme-specific backgrounds
    ├── default.png
    ├── alt1.png
    └── alt2.png
```

**How it works:**
1. Theme files are stored in `themes/<name>/`
2. Switching creates symlinks in `~/.config/` to active theme
3. Services are reloaded via signals (SIGUSR1, SIGUSR2)
4. No restart needed—themes apply instantly

---

## 🎯 Usage Guide

### List All Themes

```bash
# CLI
fedpunk-theme-list

# Output:
# Available themes:
#   aetheria
#   ayu-mirage
#   catppuccin
#   ...
```

### Set Specific Theme

```bash
# CLI
fedpunk-theme-set tokyo-night

# Rofi menu
Super+T

# What happens:
# 1. Creates symlinks to theme files
# 2. Reloads Hyprland config
# 3. Reloads Kitty (SIGUSR1)
# 4. Reloads Neovim via RPC
# 5. Reloads btop config
# 6. Reloads Mako (SIGUSR2)
# 7. Reloads Waybar (SIGUSR2)
# 8. Sets wallpaper
```

### Cycle Through Themes

```bash
# Next theme
fedpunk-theme-next
# OR
Super+Shift+T

# Previous theme
fedpunk-theme-prev
# OR
Super+Shift+Y
```

### Refresh Current Theme

```bash
# Reload current theme (fixes issues)
fedpunk-theme-refresh
# OR
Super+Shift+R
```

---

## 🎨 Creating Custom Themes

### Quick Method: Copy Existing Theme

**1. Copy theme directory:**
```bash
# Copy your favorite theme as base
cp -r ~/.local/share/fedpunk/themes/nord ~/.local/share/fedpunk/themes/my-theme
```

**2. Customize colors:**
```bash
cd ~/.local/share/fedpunk/themes/my-theme

# Edit Hyprland colors
nvim hyprland.conf

# Edit terminal colors
nvim kitty.conf

# Edit other apps as needed
nvim rofi.rasi
nvim waybar.css
nvim mako.conf
```

**3. Add wallpapers:**
```bash
# Add your wallpapers
cp ~/Pictures/wallpaper1.png wallpapers/default.png
cp ~/Pictures/wallpaper2.png wallpapers/alt1.png
```

**4. Test theme:**
```bash
fedpunk-theme-set my-theme
```

### Detailed Method: From Scratch

**1. Create theme directory:**
```bash
mkdir -p ~/.local/share/fedpunk/themes/my-theme/wallpapers
cd ~/.local/share/fedpunk/themes/my-theme
```

**2. Create Hyprland config (`hyprland.conf`):**
```conf
# Hyprland Theme: my-theme

# Border colors
general {
    col.active_border = rgba(ff79c6ff) rgba(bd93f9ff) 45deg
    col.inactive_border = rgba(44475aff)
}

# Shadows
decoration {
    col.shadow = rgba(282a36ff)
    col.shadow_inactive = rgba(282a36ff)
}

# Window rules for theme
windowrulev2 = bordercolor rgba(ff79c6ff),active
```

**3. Create Kitty config (`kitty.conf`):**
```conf
# Kitty Theme: my-theme

# Colors
foreground #f8f8f2
background #282a36

# Black
color0  #000000
color8  #4d4d4d

# Red
color1  #ff5555
color9  #ff6e67

# Green
color2  #50fa7b
color10 #5af78e

# Yellow
color3  #f1fa8c
color11 #f4f99d

# Blue
color4  #bd93f9
color12 #caa9fa

# Magenta
color5  #ff79c6
color13 #ff92d0

# Cyan
color6  #8be9fd
color14 #9aedfe

# White
color7  #bfbfbf
color15 #e6e6e6

# Cursor colors
cursor #f8f8f2
cursor_text_color background

# Selection colors
selection_foreground #282a36
selection_background #f8f8f2
```

**4. Create Neovim config (`neovim.lua`):**
```lua
-- Neovim Theme: my-theme
return {
  name = "my-theme",
  colorscheme = "dracula",  -- Or your preferred colorscheme
}
```

**5. Create btop theme (`btop.theme`):**
```ini
# btop theme: my-theme

theme[main_bg]="#282a36"
theme[main_fg]="#f8f8f2"
theme[title]="#bd93f9"
theme[hi_fg]="#ff79c6"
theme[selected_bg]="#44475a"
theme[selected_fg]="#f8f8f2"
theme[inactive_fg]="#6272a4"
theme[graph_text]="#f8f8f2"

# CPU colors
theme[cpu_box]="#bd93f9"
theme[cpu_graph_lower]="#50fa7b"
theme[cpu_graph_mid]="#f1fa8c"
theme[cpu_graph_upper]="#ff79c6"

# Memory colors
theme[mem_box]="#8be9fd"
theme[mem_graph]="#8be9fd"

# Network colors
theme[net_box]="#ff79c6"
theme[net_graph]="#ff79c6"

# Process colors
theme[proc_box]="#50fa7b"
```

**6. Create Rofi config (`rofi.rasi`):**
```css
/* Rofi Theme: my-theme */

* {
    bg: #282a36;
    fg: #f8f8f2;
    accent: #bd93f9;
    selected: #44475a;
    urgent: #ff5555;

    background-color: @bg;
    text-color: @fg;
}

window {
    border: 2px;
    border-color: @accent;
    border-radius: 8px;
    padding: 16px;
}

element selected {
    background-color: @selected;
    text-color: @accent;
}
```

**7. Create Waybar CSS (`waybar.css`):**
```css
/* Waybar Theme: my-theme */

* {
    font-family: "JetBrainsMono Nerd Font";
    font-size: 13px;
}

window#waybar {
    background-color: #282a36;
    color: #f8f8f2;
    border-bottom: 2px solid #bd93f9;
}

#workspaces button {
    color: #6272a4;
    background-color: transparent;
}

#workspaces button.active {
    color: #bd93f9;
    background-color: #44475a;
}

#workspaces button.urgent {
    color: #ff5555;
}

#clock {
    color: #8be9fd;
}

#cpu {
    color: #50fa7b;
}

#memory {
    color: #ff79c6;
}
```

**8. Create Mako config (`mako.conf`):**
```conf
# Mako Theme: my-theme

background-color=#282a36
text-color=#f8f8f2
border-color=#bd93f9
border-size=2
border-radius=8

[urgency=high]
border-color=#ff5555
```

**9. Add wallpapers:**
```bash
# Add at least one wallpaper
cp ~/Pictures/my-wallpaper.png wallpapers/default.png
```

**10. Test your theme:**
```bash
fedpunk-theme-set my-theme
```

---

## 🎨 Theme Color Palettes

### Popular Base Palettes

Use these as inspiration or starting points:

**Dracula:**
- Background: `#282a36`
- Foreground: `#f8f8f2`
- Selection: `#44475a`
- Comment: `#6272a4`
- Cyan: `#8be9fd`
- Green: `#50fa7b`
- Orange: `#ffb86c`
- Pink: `#ff79c6`
- Purple: `#bd93f9`
- Red: `#ff5555`
- Yellow: `#f1fa8c`

**Nord:**
- Background: `#2e3440`
- Foreground: `#d8dee9`
- Black: `#3b4252`
- Red: `#bf616a`
- Green: `#a3be8c`
- Yellow: `#ebcb8b`
- Blue: `#81a1c1`
- Magenta: `#b48ead`
- Cyan: `#88c0d0`
- White: `#e5e9f0`

**Tokyo Night:**
- Background: `#1a1b26`
- Foreground: `#c0caf5`
- Black: `#414868`
- Red: `#f7768e`
- Green: `#9ece6a`
- Yellow: `#e0af68`
- Blue: `#7aa2f7`
- Magenta: `#bb9af7`
- Cyan: `#7dcfff`
- White: `#a9b1d6`

---

## 🔧 Advanced Configuration

### Theme-Specific Scripts

Some themes may need additional setup. Add a `setup.fish` script:

```fish
#!/usr/bin/env fish
# themes/my-theme/setup.fish

# Example: Set GTK theme
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'

# Example: Set icon theme
gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'

# Example: Set cursor theme
gsettings set org.gnome.desktop.interface cursor-theme 'Breeze_Snow'
```

### Dynamic Color Generation

For advanced users, generate colors programmatically:

```fish
#!/usr/bin/env fish
# themes/my-theme/generate-colors.fish

# Use a base color and generate palette
set base_color "ff79c6"
# Generate complementary colors...
# Write to theme files...
```

---

## 🆘 Troubleshooting

### Theme Not Applying

```bash
# Refresh theme
fedpunk-theme-refresh

# Check symlinks
ls -la ~/.config/hypr/active-theme.conf
ls -la ~/.config/kitty/theme.conf

# Manually reload services
hyprctl reload
killall -SIGUSR2 waybar
killall -SIGUSR1 kitty
```

### Colors Not Updating

```bash
# Check which service isn't reloading
ps aux | grep -E "hyprland|waybar|kitty|mako"

# Reload manually
fedpunk-reload

# Or restart specific service
killall waybar && waybar &
```

### Wallpaper Not Changing

```bash
# Check wallpaper directory
ls ~/.local/share/fedpunk/themes/<theme-name>/wallpapers/

# Set wallpaper manually
fedpunk-wallpaper-set ~/.local/share/fedpunk/themes/<theme-name>/wallpapers/default.png
```

### Theme Files Missing

```bash
# Check theme structure
ls -la ~/.local/share/fedpunk/themes/<theme-name>/

# Required files:
# - hyprland.conf
# - kitty.conf
# - At least one wallpaper in wallpapers/

# Copy from another theme if missing
cp ~/.local/share/fedpunk/themes/nord/hyprland.conf ~/.local/share/fedpunk/themes/my-theme/
```

---

## 📚 Resources

### Documentation
- **[Themes Guide](../docs/guides/themes.md)** - Comprehensive theme guide
- **[Customization Guide](../docs/guides/customization.md)** - General customization
- **[Hyprland Wiki](https://wiki.hyprland.org)** - Hyprland configuration

### Theme Inspiration
- [base16](https://github.com/chriskempson/base16) - Theme templates
- [terminal.sexy](https://terminal.sexy/) - Terminal color schemes
- [coolors.co](https://coolors.co/) - Color palette generator
- [Dracula Theme](https://draculatheme.com/) - Popular dark theme
- [Nord Theme](https://www.nordtheme.com/) - Arctic color palette
- [Tokyo Night](https://github.com/enkia/tokyo-night-vscode-theme) - Dark theme

---

## 🤝 Contributing Themes

Want to share your theme?

1. Create theme following structure above
2. Add preview screenshot (`preview.png`)
3. Test on fresh install
4. Submit pull request to Fedpunk repository

**Theme requirements:**
- Complete config files for all apps
- At least one wallpaper
- Preview screenshot (1920x1080 recommended)
- Color palette documentation

---

**Theme System Version:** 2.0
**Last Updated:** 2025-01-20
**Total Themes:** 11
