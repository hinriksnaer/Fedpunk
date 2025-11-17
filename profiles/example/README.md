# Example Profile Template

This is a minimal profile template to get you started.

**Copy this to create your own profile!**

## Quick Start

```bash
# Copy this template
cp -r ~/.local/share/fedpunk/profiles/example ~/.local/share/fedpunk/profiles/myprofile

# Activate it
ln -sf profiles/myprofile ~/.local/share/fedpunk/.active-config

# Customize
nvim ~/.local/share/fedpunk/profiles/myprofile/config.fish
```

## Profile Structure

```
profiles/myprofile/
├── config.fish          # Fish shell customizations (sourced by main config)
├── keybinds.conf        # Hyprland keybindings (included by main config)
├── scripts/             # Utility scripts (automatically added to PATH)
│   └── my-tool.fish
├── themes/              # Custom themes (optional)
│   └── my-theme/
└── README.md            # Documentation
```

## What Goes Where

### config.fish - Shell Customizations

This file is automatically sourced by `~/.config/fish/config.fish`.

Add your:
- Aliases
- Environment variables
- Custom functions
- PATH additions

**Example:**
```fish
# Git shortcuts
alias gs='git status'
alias ga='git add'
alias gc='git commit -m'

# Development
set -x EDITOR nvim
set -x BROWSER firefox

# Custom tools
fish_add_path -g $HOME/my-tools/bin
```

### keybinds.conf - Hyprland Keybindings

This file is included by `~/.config/hypr/conf.d/keybinds.conf`.

Add your:
- Application launchers
- Custom shortcuts
- Workspace bindings

**Example:**
```conf
# Launch applications
bind = Super, B, exec, firefox
bind = Super, M, exec, spotify

# Override defaults
bind = Super, Return, exec, kitty --class floating
```

### scripts/ - Utility Scripts

Scripts in this directory are automatically added to your PATH.

**Example:**
```fish
#!/usr/bin/env fish
# profiles/myprofile/scripts/project-switch.fish

function project-switch
    set projects ~/projects/*
    set choice (printf '%s\n' $projects | fzf)
    cd $choice
end

project-switch
```

Make it executable:
```bash
chmod +x profiles/myprofile/scripts/project-switch.fish
```

### themes/ - Custom Themes

Add custom themes that will be available via `fedpunk theme set`.

See the main `themes/` directory for examples.

## Setup Checklist

- [ ] Copy profile template: `cp -r profiles/example profiles/myprofile`
- [ ] Activate profile: `ln -sf profiles/myprofile ~/.local/share/fedpunk/.active-config`
- [ ] Edit `config.fish` with your preferences
- [ ] Add custom keybindings to `keybinds.conf` (if using desktop)
- [ ] Add utility scripts to `scripts/` directory
- [ ] Reload config: `source ~/.config/fish/config.fish`

## Profile Management

### Activating a Profile

```bash
ln -sf profiles/myprofile ~/.local/share/fedpunk/.active-config
source ~/.config/fish/config.fish
```

### Switching Profiles

```bash
# Switch to work profile
ln -sf profiles/work ~/.local/share/fedpunk/.active-config

# Reload
source ~/.config/fish/config.fish

# Restart Hyprland to apply keybindings (if desktop mode)
```

### Multiple Profiles

Create different profiles for different contexts:

```bash
# Work setup
profiles/work/

# Personal projects
profiles/personal/

# Gaming configuration
profiles/gaming/

# Presentation mode
profiles/presentation/
```

## See Also

- [Dev Profile](../dev/README.md) - Full featured example
- [Dev-Terminal Profile](../dev-terminal/README.md) - Terminal-only example
- [Customization Guide](../../docs/guides/customization.md) - Full customization guide
