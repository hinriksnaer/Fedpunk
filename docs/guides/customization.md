# Profile Configuration

Your personal profile is stored in `profiles/dev/` and is **gitignored**. This is your space for customizations.
Anything you put here won't cause merge conflicts when pulling updates.

**Note:** The profile system supports multiple profiles (e.g., `profiles/work/`, `profiles/gaming/`), but you can start with just `dev/` for your development setup.

## What Goes Here?

### `profiles/dev/themes/`
Add your own custom themes here. They'll appear alongside the built-in themes.

**Structure:**
```
profiles/dev/themes/my-theme/
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

### `profiles/dev/scripts/`
Add personal utility scripts here. They'll be available in your PATH after sourcing Fish config.

**Example:**
```fish
# profiles/dev/scripts/my-script.fish
#!/usr/bin/env fish
echo "My custom script!"
```

### `profiles/dev/config.fish`
Personal Fish shell configuration that sources after the main config.

**Example:**
```fish
# profiles/dev/config.fish

# Personal aliases
alias gs='git status'
alias gp='git push'

# Custom environment variables
set -x EDITOR nvim
set -x BROWSER firefox

# Override default theme
set -x FEDPUNK_DEFAULT_THEME "my-theme"
```

### `profiles/dev/keybinds.conf`
Custom Hyprland keybindings that supplement or override defaults.

**Example:**
```conf
# profiles/dev/keybinds.conf

# Custom application launchers
bind = Super, B, exec, firefox
bind = Super, M, exec, spotify

# Override default keybinds
bind = Super, Return, exec, kitty --class floating
```

### `profiles/dev/config/`
**chezmoi-based custom dotfiles** - manage any dotfile using chezmoi.

This is the most flexible option for managing dotfiles for apps not covered above or extending existing configs.

**Structure:**
```
profiles/dev/config/
├── nvim-profiles/dev/          # Package name
│   └── .config/          # Mirrors home directory
│       └── nvim/
│           └── lua/
│               └── profiles/dev/
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
# Stow a package (creates symlinks from ~/ to profiles/dev/config/)
fedpunk-stow-profile nvim-custom

# List all packages
fedpunk-stow-profile --list

# Unstow (remove symlinks)
fedpunk-stow-profile --delete nvim-custom

# Stow all packages
fedpunk-stow-profile --all
```

**See [`profiles/dev/config/README.md`](config/README.md) for detailed documentation.**

## How It Works

The installation and theme scripts check `profiles/dev/` first, then fall back to defaults:

1. **Themes**: `profiles/dev/themes/` is searched before `themes/`
2. **Scripts**: `profiles/dev/scripts/` added to Fish function path
3. **Config**: `profiles/dev/config.fish` sourced if it exists
4. **Keybinds**: `profiles/dev/keybinds.conf` included in Hyprland config
5. **Dotfiles**: `profiles/dev/config/` packages stowed via `fedpunk-stow-profile`

## Getting Started

1. Copy example files from the main repo as starting points
2. Modify them to your liking
3. They're gitignored, so pull updates worry-free!

**Quick Start:**
```bash
# Create your custom config
cp config/fish/.config/fish/config.fish profiles/dev/config.fish

# Create a custom theme based on existing one
cp -r themes/ayu-mirage profiles/dev/themes/my-theme

# Edit to your heart's content!
```

## What's Safe to Commit?

**Never committed (gitignored):**
- Everything in `profiles/dev/`
- Active theme symlinks
- Fish shell variables

**Always committed (tracked):**
- Stock themes in `themes/`
- Core scripts in `bin/`
- Configuration templates in `config/`

---

**Remember:** This is YOUR space. Experiment freely!
