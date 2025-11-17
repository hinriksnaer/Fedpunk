# Dev Profile - Terminal Only

This is a **terminal-only** version of the dev profile for servers, containers, and headless environments.

**No desktop/Hyprland configs** - just Fish, Git, SSH, and container tools.

## Quick Start

```bash
# Copy this profile
cp -r profiles/dev-terminal profiles/yourname

# Customize it
nvim profiles/yourname/config/git/.gitconfig      # Add your name/email

# Activate it
ln -sf profiles/yourname .active-config

# Deploy configs
fedpunk-stow-profile fish
fedpunk-stow-profile git
fedpunk-stow-profile ssh
```

## What's Configured

Everything is organized as **Stow packages**. Each package mirrors your home directory structure.

### Stow Packages

#### **config/fish/** - Fish shell customizations
Location: `~/.config/fish/config.fish`
- Git aliases (gs, ga, gc, gp, gl, etc.)
- Development shortcuts (dev, dots, .., ...)
- Podman/Docker aliases and environment
- Devcontainer shortcuts (dc-up, dc-exec, dc-rebuild)
- Editor setup (nvim)
- PATH additions (cargo, local bin)

Deploy: `fedpunk-stow-profile fish`

#### **config/git/** - Git configuration
Locations:
- `~/.gitconfig` - Aliases and settings
- `~/.gitignore_global` - Global ignore patterns

**TODO**: Update name/email in `.gitconfig`

Deploy: `fedpunk-stow-profile git`

#### **config/ssh/** - SSH configuration
Location: `~/.ssh/config`
- GitHub/GitLab setup
- Jump host examples
- Connection sharing

Deploy: `fedpunk-stow-profile ssh`

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
- [ ] Deploy configs:
  ```bash
  fedpunk-stow-profile fish
  fedpunk-stow-profile git
  fedpunk-stow-profile ssh
  ```
- [ ] Setup container development (optional):
  ```bash
  ./scripts/setup-podman.fish
  ./scripts/setup-devcontainer.fish
  ```

## Differences from Desktop Profile

**Not included (desktop-only):**
- Hyprland configuration
- Monitor configuration
- Keybindings
- Desktop window manager settings

**Included (terminal focus):**
- Fish shell with all aliases
- Git configuration
- SSH configuration
- Container development tools
- Neovim configuration (via base fedpunk)
- Tmux configuration (via base fedpunk)

## Use Cases

- **Remote servers** - SSH into servers and have your dev environment
- **Devcontainers** - Inside containers where you don't need desktop
- **Cloud VMs** - Lightweight setup for cloud instances
- **WSL/Docker** - Terminal environments on Windows/Mac
- **CI/CD runners** - Automated build environments

## See Also

- [profiles/dev/](../dev/README.md) - Full desktop development profile
- [profiles/example/](../example/README.md) - Template profile
- [Customization Guide](../../docs/guides/customization.md) - Full guide
