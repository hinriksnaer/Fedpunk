# Dev Profile (Reference Example)

This is a **reference implementation** of a fully-configured development profile.

Use this as a starting point for your own profile, or keep your personal setup elsewhere.

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

### Scripts

- **scripts/install-nvim-mcp.fish** - Neovim MCP integration
- **scripts/setup-podman.fish** - Setup Podman for containers
- **scripts/setup-devcontainer.fish** - Setup Devcontainer CLI

### Container Development

The profile includes Podman and Devcontainer CLI setup:

**Setup:**
```bash
./scripts/setup-podman.fish           # Install and configure Podman
./scripts/setup-devcontainer.fish     # Install devcontainer CLI
```

**Aliases included:**
- `docker` → `podman` (Docker compatibility)
- `docker-compose` → `podman-compose`
- `dc-up` → Start devcontainer
- `dc-exec` → Execute in devcontainer
- `dc-rebuild` → Rebuild devcontainer

**Environment:**
- `DOCKER_HOST` set for Podman socket
- Docker API compatibility enabled

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
- [ ] Setup container development (optional):
  ```bash
  ./scripts/setup-podman.fish
  ./scripts/setup-devcontainer.fish
  ```

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
