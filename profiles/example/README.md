# Example Profile Template

This is a **comprehensive template** with examples and extensive documentation.

**Use this as your starting point!**

## Quick Start

```bash
# Copy this template to create your own profile
cp -r profiles/example profiles/yourname

# Customize it
nvim profiles/yourname/config/git/.gitconfig      # Add your name/email
nvim profiles/yourname/config/hypr/.config/hypr/monitors.conf  # Configure monitors

# Activate it
ln -sf profiles/yourname .active-config

# Deploy configs
fedpunk-stow-profile fish
fedpunk-stow-profile hypr
fedpunk-stow-profile git
```

## What's Configured

Everything is organized as **Stow packages** for consistency. Each package mirrors your home directory structure.

### Stow Packages

#### **config/fish/** - Fish shell customizations
Location: `~/.config/fish/config.fish`
- Git aliases (gs, ga, gc, gp, gl, etc.)
- Development shortcuts (dev, dots, .., ...)
- Editor setup (nvim)
- PATH additions (cargo, local bin)

Deploy: `fedpunk-stow-profile fish`

#### **config/hypr/** - Hyprland configuration
Locations:
- `~/.config/hypr/monitors.conf` - Ultrawide monitor (7679x2160@120)
- `~/.config/hypr/conf.d/keybinds.conf` - Custom keybindings

Deploy: `fedpunk-stow-profile hypr`

#### **config/git/** - Git configuration
Locations:
- `~/.gitconfig` - Aliases and settings
- `~/.gitignore_global` - Global ignore patterns

**TODO**: Update email in `.gitconfig`

Deploy: `fedpunk-stow-profile git`

#### **config/ssh/** - SSH configuration
Location: `~/.ssh/config`
- GitHub/GitLab setup
- Jump host examples
- Connection sharing

Deploy: `fedpunk-stow-profile ssh`

### Scripts

- **scripts/install-nvim-mcp.fish** - Neovim MCP integration

### Themes

- **themes/** - Your custom themes (if any)

## Setup Checklist

- [ ] Update git email in `config/git/.gitconfig`
- [ ] Update monitor name in `config/hypr/.config/hypr/monitors.conf` (run `hyprctl monitors`)
- [ ] Deploy configs:
  ```bash
  fedpunk-stow-profile fish
  fedpunk-stow-profile hypr
  fedpunk-stow-profile git
  ```
- [ ] Customize aliases in `config/fish/.config/fish/config.fish`
- [ ] Add custom keybinds in `config/hypr/.config/hypr/conf.d/keybinds.conf`

## Adding More Configs

### SSH Configuration

```bash
# Copy example
cp -r ../example/ssh-config.example config/ssh

# Edit with your hosts
nvim config/ssh/.ssh/config

# Deploy
fedpunk-stow-profile ssh
chmod 600 ~/.ssh/config
```

### NVIDIA Configuration (if needed)

NVIDIA setup is handled during installation. Re-run the installer if you need to add GPU support.

### Other Stow Packages

Create any dotfile package in `config/`:

```bash
mkdir -p config/myapp
# Add files mirroring home directory structure
# Deploy with: fedpunk-stow-profile myapp
```

## Using This as a Template

### Option 1: Copy to Your Own Profile

```bash
# Create your personal profile
cp -r profiles/dev profiles/yourname

# Update .active-config symlink
ln -sf profiles/yourname .active-config

# Customize your profile
nvim profiles/yourname/config.fish
```

### Option 2: Start Fresh

```bash
# Create new profile
mkdir -p profiles/yourname

# Copy what you want from dev and example
cp profiles/example/*.example profiles/yourname/
cp profiles/dev/monitors.conf profiles/yourname/

# Link it
ln -sf profiles/yourname .active-config
```

## Profile Management

The `.active-config` symlink determines which profile is active.

Switch profiles:
```bash
ln -sf profiles/work .active-config
# Reload shell or restart Hyprland
```

## See Also

- [Profile Examples](../example/README.md) - Templates and examples
- [Customization Guide](../../docs/guides/customization.md) - Full guide
- [Configuration Reference](../../docs/reference/configuration.md) - All config files
