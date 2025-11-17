# Dev Profile - Terminal Only

This is a **terminal-only** version of the dev profile for servers, containers, and headless environments.

**No desktop/Hyprland configs** - just Fish, scripts, and terminal tools.

## Quick Start

```bash
# Copy this profile
cp -r ~/.local/share/fedpunk/profiles/dev-terminal ~/.local/share/fedpunk/profiles/myprofile

# Activate it
ln -sf profiles/myprofile ~/.local/share/fedpunk/.active-config

# Customize it
nvim ~/.local/share/fedpunk/profiles/myprofile/config.fish
```

## Profile Structure

```
profiles/dev-terminal/
├── config.fish          # Fish shell customizations
├── scripts/             # Utility scripts (added to PATH)
│   ├── install-nvim-mcp.fish
│   ├── setup-podman.fish
│   └── setup-devcontainer.fish
└── README.md
```

## What's Configured

### config.fish - Terminal Environment

Contains terminal-focused customizations:
- Git aliases (gs, ga, gc, gp, gl, etc.)
- Development shortcuts (dev, dots, .., ...)
- Podman/Docker aliases and environment
- Devcontainer shortcuts (dc-up, dc-exec, dc-rebuild)
- Editor setup (nvim)
- PATH additions

**Example aliases included:**
```fish
# Git shortcuts
alias gs='git status'
alias ga='git add'
alias gc='git commit -m'
alias gp='git push'
alias gl='git log --oneline'

# Docker/Podman
alias docker='podman'
alias docker-compose='podman-compose'
```

### scripts/ - Development Tools

- **install-nvim-mcp.fish** - Neovim MCP integration setup
- **setup-podman.fish** - Install and configure Podman for containers
- **setup-devcontainer.fish** - Setup Devcontainer CLI

**Usage:**
```bash
# Run setup scripts
./profiles/myprofile/scripts/setup-podman.fish
./profiles/myprofile/scripts/setup-devcontainer.fish
```

## Setup Checklist

- [ ] Copy profile: `cp -r profiles/dev-terminal profiles/myprofile`
- [ ] Activate: `ln -sf profiles/myprofile ~/.local/share/fedpunk/.active-config`
- [ ] Customize `config.fish` with your preferences
- [ ] Add utility scripts to `scripts/` directory
- [ ] Reload config: `source ~/.config/fish/config.fish`
- [ ] (Optional) Run setup scripts for container development

## Differences from Desktop Profile

**Not included (desktop-only):**
- Hyprland keybindings
- Monitor configuration
- Desktop window manager settings
- GUI application configs

**Included (terminal focus):**
- Fish shell with comprehensive aliases
- Git configuration examples
- Container development tools (Podman/Docker)
- Neovim configuration support
- Terminal multiplexer support

## Use Cases

- **Remote servers** - SSH into servers with your dev environment
- **Devcontainers** - Inside containers where desktop isn't needed
- **Cloud VMs** - Lightweight setup for cloud instances
- **WSL/Docker** - Terminal environments on Windows/Mac
- **CI/CD runners** - Automated build environments

## Container Development

This profile includes tools for container-based development:

**Podman:**
```bash
# Setup Podman
./scripts/setup-podman.fish

# Aliases available after setup
docker ps                    # Actually runs: podman ps
docker-compose up            # Actually runs: podman-compose up
```

**Devcontainer CLI:**
```bash
# Setup devcontainer CLI
./scripts/setup-devcontainer.fish

# Shortcuts available
dc-up           # Start devcontainer
dc-exec bash    # Execute command in devcontainer
dc-rebuild      # Rebuild devcontainer
```

## See Also

- [Dev Profile](../dev/README.md) - Full desktop development profile
- [Example Profile](../example/README.md) - Minimal template
- [Customization Guide](../../docs/guides/customization.md) - Full guide
