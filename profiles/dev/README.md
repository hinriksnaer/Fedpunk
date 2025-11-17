# Dev Profile (Reference Example)

This is a **reference implementation** of a fully-configured development profile.

Use this as a starting point for your own profile, or keep your personal setup elsewhere.

## What's Configured

Profiles provide overlays that extend or customize the base Fedpunk configuration.

### Profile Structure

#### **config.fish** - Fish shell customizations
Sourced by the main Fish config at `~/.config/fish/config.fish`

Add your personal:
- Git aliases (gs, ga, gc, gp, gl, etc.)
- Development shortcuts
- Environment variables
- Editor preferences
- Custom PATH entries

#### **keybinds.conf** - Hyprland keybindings
Included by Hyprland config at `~/.config/hypr/conf.d/keybinds.conf`

Add your custom:
- Application launchers
- Window management shortcuts
- Workspace bindings

### Scripts

- **scripts/install-nvim-mcp.fish** - Neovim MCP integration
- **scripts/setup-podman.fish** - Setup Podman for containers
- **scripts/setup-devcontainer.fish** - Setup Devcontainer CLI

### Themes

- **themes/** - Your custom themes (if any)

## Setup Checklist

- [ ] Create your profile: `cp -r profiles/example profiles/myprofile`
- [ ] Activate it: `ln -sf profiles/myprofile ~/.local/share/fedpunk/.active-config`
- [ ] Customize `config.fish` with your aliases and environment
- [ ] Add custom `keybinds.conf` if using desktop mode
- [ ] Add utility scripts to `scripts/` directory
- [ ] Reload Fish config: `source ~/.config/fish/config.fish`

## Customization Examples

### Fish Shell Aliases

Edit `profiles/myprofile/config.fish`:
```fish
# Git shortcuts
alias gs='git status'
alias ga='git add'
alias gc='git commit'

# Development
set -x EDITOR nvim
set -x BROWSER firefox

# Custom PATH
fish_add_path -g $HOME/my-tools/bin
```

### Hyprland Keybindings

Edit `profiles/myprofile/keybinds.conf`:
```conf
# Custom application launchers
bind = Super, B, exec, firefox
bind = Super, M, exec, spotify

# Override defaults
bind = Super, Return, exec, kitty --class floating
```

### Utility Scripts

Add to `profiles/myprofile/scripts/`:
```fish
#!/usr/bin/env fish
# profiles/myprofile/scripts/my-tool.fish
echo "My custom tool!"
```

Scripts in this directory are automatically added to your PATH.

## Profile Management

Profiles are activated via the `.active-config` symlink in the Fedpunk directory.

### Creating a New Profile

```bash
# Create from template
cp -r ~/.local/share/fedpunk/profiles/example ~/.local/share/fedpunk/profiles/myprofile

# Activate it
ln -sf profiles/myprofile ~/.local/share/fedpunk/.active-config

# Customize
nvim ~/.local/share/fedpunk/profiles/myprofile/config.fish
```

### Switching Profiles

```bash
# Switch to different profile
ln -sf profiles/work ~/.local/share/fedpunk/.active-config

# Reload shell
source ~/.config/fish/config.fish

# Or restart Hyprland to apply keybindings
```

### Multiple Profiles

You can create profiles for different contexts:
- `profiles/work/` - Work setup
- `profiles/personal/` - Personal projects
- `profiles/gaming/` - Gaming configuration
- `profiles/presentation/` - Presentation mode

## See Also

- [Example Profile](../example/README.md) - Minimal profile template
- [Customization Guide](../../docs/guides/customization.md) - Full customization guide
- [Configuration Reference](../../docs/reference/configuration.md) - All config files
