# Configuration Reference

Complete reference for Fedpunk configuration files and their locations.

---

## 📁 Directory Structure

```
~/.local/share/fedpunk/          ← Main Fedpunk directory
├── themes/                      ← Built-in themes (12 themes)
├── profiles/dev/                      ← Your customizations (gitignored)
├── config/                      ← Core application configs
├── bin/                         ← Utility scripts
└── install/                     ← Installation scripts

~/.config/                       ← XDG config directory (symlinked)
├── fish/                        ← Fish shell config
├── hypr/                        ← Hyprland compositor config
├── kitty/                       ← Kitty terminal config
├── nvim/                        ← Neovim editor config
├── tmux/                        ← Tmux multiplexer config
├── lazygit/                     ← Lazygit config
├── btop/                        ← btop system monitor config
├── rofi/                        ← Rofi launcher config
└── waybar/                      ← Waybar status bar config
```

---

## 🐟 Fish Shell Configuration

### Main Config
**Location:** `~/.config/fish/config.fish`
**Source:** `config/fish/.config/fish/config.fish`

**Contains:**
- Shell initialization
- Path setup
- Plugin loading
- Function definitions
- Theme integration

### Custom Overrides
**Location:** `profiles/dev/config.fish`
**Loaded:** After main config (your settings win)

**Example:**
```fish
# profiles/dev/config.fish
alias gs='git status'
alias gp='git push'
set -x EDITOR nvim
set -x BROWSER firefox
```

### Functions
**Location:** `~/.config/fish/functions/`

**Key Functions:**
- Theme management
- Git helpers
- Navigation shortcuts

---

## 🪟 Hyprland Configuration

### Main Config
**Location:** `~/.config/hypr/hyprland.conf`
**Source:** `config/hyprland/.config/hypr/hyprland.conf`

### Modular Configs
**Location:** `~/.config/hypr/conf.d/`

| File | Purpose |
|------|---------|
| `variables.conf` | Colors, environment variables |
| `env.conf` | Environment variables |
| `general.conf` | Window gaps, borders, layout |
| `decorations.conf` | Window appearance |
| `layouts.conf` | Dwindle and master layouts |
| `input.conf` | Mouse, keyboard, touchpad |
| `keybinds.conf` | Keyboard shortcuts |
| `windowrules.conf` | Application-specific rules |
| `autostart.conf` | Applications to start |
| `misc.conf` | Miscellaneous settings |
| `nvidia.conf` | NVIDIA-specific settings |
| `debug.conf` | Debug logging |

### Monitor Configuration
**Location:** `~/.config/hypr/monitors.conf`

**Edit this file** to configure your displays:
```conf
# Example monitor configuration
monitor=DP-1,2560x1440@144,0x0,1
monitor=HDMI-A-1,1920x1080@60,2560x0,1
```

### Workspace Configuration
**Location:** `~/.config/hypr/workspaces.conf`

**Configure workspace rules and assignments**

### Custom Keybindings
**Location:** `profiles/dev/keybinds.conf`
**Loaded:** After default keybinds (your bindings can override defaults)

**Example:**
```conf
# profiles/dev/keybinds.conf
bind = Super, M, exec, spotify
bind = Super+Shift, F, exec, firefox --private-window
```

### Theme Integration
**Location:** `~/.local/share/fedpunk/themes/<theme-name>/hyprland.conf`
**Applied:** Via theme switcher

---

## 🖥️ Kitty Terminal Configuration

### Main Config
**Location:** `~/.config/kitty/kitty.conf`
**Source:** `config/kitty/.config/kitty/kitty.conf`

**Contains:**
- Font configuration
- Performance settings
- Keybindings
- Theme loading

### Theme
**Location:** `~/.config/kitty/theme.conf` (symlink)
**Points to:** Current theme's `kitty.conf`

**Themes use omarchy format** - 100% compatible

---

## ✏️ Neovim Configuration

### Main Config
**Location:** `~/.config/nvim/init.lua`
**Source:** Git submodule at `config/neovim/.config/nvim/`

**Based on:** LazyVim

**Features:**
- LSP support
- Autocompletion
- Syntax highlighting
- File explorer
- Git integration
- Theme integration

### Customization
Edit files in `~/.config/nvim/lua/config/` or add to `profiles/dev/config/nvim/`

---

## 🔀 Tmux Configuration

### Main Config
**Location:** `~/.config/tmux/tmux.conf`
**Source:** `config/tmux/.config/tmux/tmux.conf`

**Contains:**
- Plugin manager (TPM)
- Keybindings
- Theme integration
- Status bar configuration

### Plugins
**Location:** `~/.config/tmux/plugins/`
**Managed by:** TPM (Tmux Plugin Manager)

**Install plugins:** `Prefix + I` (Ctrl+Space + I)

---

## 🎨 Theme System

### Theme Storage
**Built-in:** `~/.local/share/fedpunk/themes/`
**Custom:** `profiles/dev/themes/`

### Theme Structure
```
themes/my-theme/
├── hyprland.conf      ← Hyprland colors
├── kitty.conf         ← Terminal colors (omarchy format)
├── rofi.rasi          ← Launcher styling
├── btop.theme         ← System monitor colors
├── mako.ini           ← Notification styling
├── neovim.lua         ← Editor colorscheme
├── waybar.css         ← Status bar styling
├── alacritty.toml     ← Alacritty colors
├── ghostty.conf       ← Ghostty colors
├── vscode.json        ← VS Code theme
├── chromium.theme     ← Browser theme
├── hyprlock.conf      ← Lock screen theme
├── swayosd.css        ← OSD styling
├── icons.theme        ← Icon theme name
└── backgrounds/       ← Wallpapers
    ├── wallpaper-1.jpg
    └── wallpaper-2.png
```

### Theme Selection
**Current theme stored in:** Theme-specific symlinks in `~/.config/`

**Commands:**
- `fedpunk-theme-list` - List available themes
- `fedpunk-theme-set <name>` - Set theme
- `fedpunk-theme-current` - Show current theme

---

## 🎯 Rofi Launcher Configuration

### Main Config
**Location:** `~/.config/rofi/config.rasi`
**Source:** `config/rofi/.config/rofi/config.rasi`

### Theme
**Location:** `~/.config/rofi/theme.rasi` (symlink)
**Points to:** Current theme's `rofi.rasi`

---

## 📊 btop System Monitor Configuration

### Main Config
**Location:** `~/.config/btop/btop.conf`
**Source:** `config/btop/.config/btop/btop.conf`

### Theme
**Location:** `~/.config/btop/themes/active.theme` (symlink)
**Points to:** Current theme's `btop.theme`

---

## 📊 Waybar Status Bar Configuration

### Main Config
**Location:** `~/.config/waybar/config`
**Source:** `config/waybar/.config/waybar/config`

### Style
**Location:** `~/.config/waybar/style.css`
**Source:** Base style + theme overlay

### Theme
**Location:** `~/.config/waybar/theme.css` (symlink)
**Points to:** Current theme's `waybar.css`

---

## 🔧 Custom Dotfiles (Stow)

### Location
**Base:** `profiles/dev/config/`

### Structure
Each package mirrors your home directory:
```
profiles/dev/config/
├── git/
│   ├── .gitconfig
│   └── .gitignore_global
├── alacritty/
│   └── .config/
│       └── alacritty/
│           └── alacritty.toml
└── npm/
    └── .npmrc
```

### Management
```bash
# Deploy dotfiles
fedpunk-stow-profile git
fedpunk-stow-profile alacritty

# List packages
fedpunk-stow-profile --list

# Remove
fedpunk-stow-profile --delete git
```

---

## 🔐 Environment Variables

### Global Environment
**Location:** `~/.config/hypr/conf.d/env.conf`

**Contains:**
- Display server settings
- GPU variables
- XDG directories
- Application defaults

### Custom Environment
**Location:** `profiles/dev/config.fish`

**Example:**
```fish
# profiles/dev/config.fish
set -x EDITOR nvim
set -x BROWSER firefox
set -x VISUAL nvim
set -x PAGER less
```

---

## 🗂️ XDG Base Directory Specification

Fedpunk follows XDG standards:

| Variable | Default | Purpose |
|----------|---------|---------|
| `$XDG_CONFIG_HOME` | `~/.config` | User configs |
| `$XDG_DATA_HOME` | `~/.local/share` | User data |
| `$XDG_STATE_HOME` | `~/.local/state` | User state |
| `$XDG_CACHE_HOME` | `~/.cache` | User cache |

**Fedpunk respects these** - all configs go in standard locations.

---

## 🔄 Configuration Loading Order

### Fish Shell
1. System config: `/etc/fish/config.fish`
2. Fedpunk config: `~/.config/fish/config.fish`
3. Custom config: `profiles/dev/config.fish` ← **Your overrides**

### Hyprland
1. Main config: `hyprland.conf`
2. Variables: `conf.d/variables.conf`
3. Theme: `themes/<theme>/hyprland.conf`
4. Environment: `conf.d/env.conf`
5. Core configs: `conf.d/*.conf`
6. Keybinds: `conf.d/keybinds.conf`
7. Custom keybinds: `profiles/dev/keybinds.conf` ← **Your overrides**
8. Autostart: `conf.d/autostart.conf`

### Themes
1. Custom themes: `profiles/dev/themes/` ← **Searched first**
2. Built-in themes: `themes/`

---

## 📝 Configuration Tips

### Best Practices
1. **Never edit core configs directly** - Use `profiles/dev/` instead
2. **Test changes** before committing
3. **Backup before major changes**
4. **Use version control** for your `profiles/dev/` directory
5. **Document custom changes**

### Testing Changes

**Fish config:**
```bash
fish --debug  # Check for errors
exec fish     # Reload shell
```

**Hyprland config:**
```bash
hyprctl reload  # Reload config
```

**Neovim:**
```
:checkhealth  # Verify setup
:Lazy sync    # Update plugins
```

### Backing Up Custom Config
```bash
# Backup custom directory
tar czf ~/fedpunk-custom-backup-$(date +%Y%m%d).tar.gz \
    ~/.local/share/fedpunk/profiles/dev/

# Or use git
cd ~/.local/share/fedpunk/custom
git init
git add .
git commit -m "My Fedpunk customizations"
git remote add origin <your-repo>
git push
```

---

## 🔍 Finding Configuration Files

### Quick Reference
```bash
# Fish config
vim ~/.config/fish/config.fish

# Hyprland config
vim ~/.config/hypr/hyprland.conf

# Kitty config
vim ~/.config/kitty/kitty.conf

# Neovim config
vim ~/.config/nvim/init.lua

# Custom overrides
vim ~/.local/share/fedpunk/profiles/dev/config.fish
vim ~/.local/share/fedpunk/profiles/dev/keybinds.conf
```

### Finding Files
```bash
# Find all configs
find ~/.config -name "*.conf"

# Find Fedpunk files
find ~/.local/share/fedpunk -name "*.fish"

# Check symlink targets
ls -la ~/.config/kitty/theme.conf
```

---

## 📚 Related Documentation

- [Customization Guide](../guides/customization.md) - How to customize
- [Themes Guide](../guides/themes.md) - Theme system details
- [Keybindings Reference](keybindings.md) - All keyboard shortcuts
- [Scripts Reference](scripts.md) - Script documentation

---

**All configs in one place, clearly organized! 📁**
