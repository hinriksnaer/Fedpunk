# Custom Configuration Directory

This directory is **gitignored** and is your personal space for customizations.
Anything you put here won't cause merge conflicts when pulling updates.

**Note:** This is the ONLY place for user customizations. The old `profiles/` system has been removed in favor of this simpler, single-location approach.

## What Goes Here?

### `custom/themes/`
Add your own custom themes here. They'll appear alongside the built-in themes.

**Structure:**
```
custom/themes/my-theme/
├── hyprland.conf
├── kitty.conf
├── rofi.rasi
├── btop.theme
├── mako.ini
├── neovim.lua
├── waybar.css
└── backgrounds/
    └── wallpaper.jpg
```

**Usage:**
```bash
fedpunk-theme-set my-theme
```

### `custom/scripts/`
Add personal utility scripts here. They'll be available in your PATH after sourcing Fish config.

**Example:**
```fish
# custom/scripts/my-script.fish
#!/usr/bin/env fish
echo "My custom script!"
```

### `custom/config.fish`
Personal Fish shell configuration that sources after the main config.

**Example:**
```fish
# custom/config.fish

# Personal aliases
alias gs='git status'
alias gp='git push'

# Custom environment variables
set -x EDITOR nvim
set -x BROWSER firefox

# Override default theme
set -x FEDPUNK_DEFAULT_THEME "my-theme"
```

### `custom/keybinds.conf`
Custom Hyprland keybindings that supplement or override defaults.

**Example:**
```conf
# custom/keybinds.conf

# Custom application launchers
bind = Super, B, exec, firefox
bind = Super, M, exec, spotify

# Override default keybinds
bind = Super, Return, exec, kitty --class floating
```

### `custom/config/`
**Stow-based custom dotfiles** - manage any dotfile using GNU Stow.

This is the most flexible option for managing dotfiles for apps not covered above or extending existing configs.

**Structure:**
```
custom/config/
├── nvim-custom/          # Package name
│   └── .config/          # Mirrors home directory
│       └── nvim/
│           └── lua/
│               └── custom/
│                   └── init.lua
├── git/
│   ├── .gitconfig
│   └── .gitignore_global
└── alacritty/
    └── .config/
        └── alacritty/
            └── alacritty.toml
```

**Usage:**
```bash
# Stow a package (creates symlinks from ~/ to custom/config/)
fedpunk-stow-custom nvim-custom

# List all packages
fedpunk-stow-custom --list

# Unstow (remove symlinks)
fedpunk-stow-custom --delete nvim-custom

# Stow all packages
fedpunk-stow-custom --all
```

**See [`custom/config/README.md`](config/README.md) for detailed documentation.**

## How It Works

The installation and theme scripts check `custom/` first, then fall back to defaults:

1. **Themes**: `custom/themes/` is searched before `themes/`
2. **Scripts**: `custom/scripts/` added to Fish function path
3. **Config**: `custom/config.fish` sourced if it exists
4. **Keybinds**: `custom/keybinds.conf` included in Hyprland config
5. **Dotfiles**: `custom/config/` packages stowed via `fedpunk-stow-custom`

## Getting Started

1. Copy example files from the main repo as starting points
2. Modify them to your liking
3. They're gitignored, so pull updates worry-free!

**Quick Start:**
```bash
# Create your custom config
cp config/fish/.config/fish/config.fish custom/config.fish

# Create a custom theme based on existing one
cp -r themes/ayu-mirage custom/themes/my-theme

# Edit to your heart's content!
```

## What's Safe to Commit?

**Never committed (gitignored):**
- Everything in `custom/`
- Active theme symlinks
- Fish shell variables

**Always committed (tracked):**
- Stock themes in `themes/`
- Core scripts in `bin/`
- Configuration templates in `config/`

---

**Remember:** This is YOUR space. Experiment freely!
