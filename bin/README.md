# Fedpunk Utility Scripts

This directory contains modular utility scripts for managing your Fedpunk environment, inspired by the omarchy setup.

## Theme Management Scripts

All theme scripts are written in Fish shell for consistency with the Fedpunk environment.

### Available Commands

#### `fedpunk-theme-list`
List all available themes in your themes directory.

```fish
fedpunk-theme-list
```

**Output:** Formatted list of theme names (e.g., "Osaka Jade", "Catppuccin Latte")

---

#### `fedpunk-theme-current`
Display the currently active theme.

```fish
fedpunk-theme-current
```

**Output:** Name of the current theme

---

#### `fedpunk-theme-set <theme-name>`
Switch to a specific theme by name.

```fish
# Examples
fedpunk-theme-set osaka-jade
fedpunk-theme-set "Osaka Jade"  # Also accepts spaces
fedpunk-theme-set default
```

**Features:**
- Updates Hyprland configuration
- Creates symlinks for theme files (foot, walker, btop)
- Reloads applications automatically
- Shows notification with results
- Case-insensitive theme names

---

#### `fedpunk-theme-next`
Cycle to the next theme in alphabetical order.

```fish
fedpunk-theme-next
```

**Keybinding:** `Super + Shift + T`

---

#### `fedpunk-theme-prev`
Cycle to the previous theme in alphabetical order.

```fish
fedpunk-theme-prev
```

**Keybinding:** `Super + Shift + Y`

---

#### `fedpunk-theme-refresh`
Reapply the current theme (useful after editing theme files).

```fish
fedpunk-theme-refresh
```

**Keybinding:** `Super + Shift + R`

---

#### `fedpunk-refresh-walker`
Refresh and restart walker to apply configuration changes.

```fish
fedpunk-refresh-walker
```

---

### Wallpaper Management

#### `fedpunk-wallpaper-next`
Cycle to the next wallpaper in the current theme's backgrounds directory.

```fish
fedpunk-wallpaper-next
```

**Keybinding:** `Super + Shift + W`

---

#### `fedpunk-wallpaper-set <theme-name>`
Set the first wallpaper from a theme's backgrounds. If no theme specified, uses current theme.

```fish
# Set wallpaper from specific theme
fedpunk-wallpaper-set osaka-jade

# Set wallpaper from current theme
fedpunk-wallpaper-set
```

**Note:** This is automatically called when switching themes with `fedpunk-theme-set`.

---

## Theme File Structure

Each theme should be organized in the `~/Fedpunk/themes/<theme-name>/` directory with the following optional files:

```
themes/
└── theme-name/
    ├── hyprland.conf          # Hyprland colors and styling
    ├── kitty.conf             # Kitty terminal theme colors
    ├── foot.ini               # Foot terminal theme
    ├── .fedpunk-foot.ini      # Alternative foot theme name
    ├── walker.css             # Walker launcher theme colors
    ├── btop.theme             # btop system monitor theme
    └── backgrounds/           # Wallpaper images (jpg, png, jpeg)
        ├── 1-wallpaper.jpg
        ├── 2-wallpaper.png
        └── ...
```

**Note:** All theme files are optional. The scripts will skip missing files gracefully.

### Walker Theme Colors

Walker themes use CSS color variables defined in `walker.css`:

```css
@define-color selected-text #color;
@define-color text #color;
@define-color base #color;
@define-color border #color;
@define-color foreground #color;
@define-color background #color;
```

The main walker style is located at `~/.local/share/fedpunk/walker/themes/fedpunk-default/style.css` and automatically imports colors from the active theme.

### Wallpaper Management

Wallpapers use **swaybg** (omarchy-compatible):
- Images are stored in `backgrounds/` directory of each theme
- Wallpapers are automatically set when switching themes
- The symlink `~/.config/hypr/wallpapers/current` points to the active wallpaper
- `fedpunk-wallpaper-next` cycles through available wallpapers

**Requirement:** Install swaybg with `sudo dnf install swaybg`

---

## Adding Scripts to PATH

To use these scripts from anywhere, add the bin directory to your PATH:

### For Fish Shell

Add to `~/.config/fish/config.fish`:

```fish
# Add Fedpunk bin to PATH
fish_add_path $HOME/Fedpunk/bin
```

Then reload your config:

```fish
source ~/.config/fish/config.fish
```

### For Bash/Zsh

Add to `~/.bashrc` or `~/.zshrc`:

```bash
export PATH="$HOME/Fedpunk/bin:$PATH"
```

---

## Script Design Philosophy

These scripts follow the omarchy design patterns:
- **Modular:** Each script does one thing well
- **Composable:** Scripts can be used together or independently
- **User-friendly:** Clear output, notifications, and error messages
- **Fish-native:** Written in Fish for better integration with Fedpunk

---

## Troubleshooting

### Theme not found
Ensure your theme directory exists in `~/Fedpunk/themes/` and has the correct structure.

### Keybindings not working
Make sure the keybindings in `~/.config/hypr/conf.d/keybinds.conf` point to the correct script paths, and reload Hyprland with `hyprctl reload`.

### Scripts not executable
Run: `chmod +x ~/Fedpunk/bin/fedpunk-*`
