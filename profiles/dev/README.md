# Dev Profile

Complete development environment with containers, Git workflow, and **Bitwarden** password manager.

This is a **reference implementation** of a fully-configured development profile.

## Features

- **Bitwarden Integration**: Password management with CLI + GUI (browser integration)
- **Git Workflow**: Comprehensive git aliases and shortcuts
- **Container Development**: Podman setup for Docker-compatible workflows
- **Neovim MCP**: Model Context Protocol integration for AI-assisted development
- **Devcontainer Support**: Full devcontainer CLI setup

## What's Configured

Profiles provide overlays that extend or customize the base Fedpunk configuration.

### Profile Structure

#### **config.fish** - Fish shell customizations
Sourced by the main Fish config at `~/.config/fish/config.fish`

Includes:
- Git aliases (gs, ga, gc, gp, gl, etc.)
- Development shortcuts (v, vi, vim → nvim)
- Container aliases (docker, podman)
- **Bitwarden CLI aliases**: `bwu`, `bwl`, `bwg`, `bwgen`, `bws`
- Environment variables (EDITOR, BROWSER)
- Custom functions (mkproj, gcp, devcon)

#### **keybinds.conf** - Hyprland keybindings
Included by Hyprland config at `~/.config/hypr/conf.d/keybinds.conf`

Add your custom:
- Application launchers
- Window management shortcuts
- Workspace bindings

### Scripts

- **scripts/setup-bitwarden.fish** - Install Bitwarden (GUI + CLI)
  - Supports `--reinstall` flag to force reinstall
- **scripts/bw-ssh-add.fish** - Add SSH keys to Bitwarden vault
- **scripts/install-nvim-mcp.fish** - Neovim MCP integration
- **scripts/setup-podman.fish** - Setup Podman for containers
- **scripts/setup-devcontainer.fish** - Setup Devcontainer CLI

### Themes

- **themes/** - Your custom themes (if any)

## Quick Start

### Activate Dev Profile

The dev profile is the default active profile. To ensure it's active:

```bash
cd ~/.local/share/fedpunk
ln -sf profiles/dev .active-config
source ~/.config/fish/config.fish
```

### Install Bitwarden

Run the setup script to automatically install Bitwarden (GUI + CLI):

```bash
fish ~/.local/share/fedpunk/profiles/dev/scripts/setup-bitwarden.fish
```

This will automatically:
1. Install Flatpak and add Flathub
2. Install Bitwarden desktop app (for browser integration)
3. Install Bitwarden CLI (via npm or direct download)

**GUI Usage:**
- App menu: Search for "Bitwarden"
- Desktop: Browser extension integration

**CLI Usage:**
```bash
# Login
bw login your-email@example.com

# Unlock vault (save the session key!)
export BW_SESSION=$(bw unlock --raw)

# Get a password
bw get password gmail

# List all items
bw list items

# Generate password
bw generate --length 20

# Sync vault
bw sync
```

**Included Commands & Aliases:**

*Authentication:*
- `bwlogin` - Login and auto-save session key
- `bwunlock` / `bwu` - Unlock vault and auto-save session key

*Credential Management:*
- `bw-get <name>` / `bwg` - Interactive search and get password (auto-copy to clipboard)
- `bwl` - List items
- `bwgen` - Generate password
- `bws` - Sync vault

*SSH Integration:*
- `bw-ssh-add [key-path]` / `bwsshadd` - Store SSH key in Bitwarden
- `bw-ssh-load [key-name]` / `bwssh` - Load SSH key from Bitwarden into SSH agent

*Environment Variables:*
- `bw-env [item-name]` - Load environment variables from Bitwarden secure note

**Auto-unlock on Shell Start:**
When you open a new Fish shell, it will automatically prompt to unlock your Bitwarden vault if it's locked.

### Using Included Aliases

**Git shortcuts:**
```bash
gs      # git status
gd      # git diff
ga      # git add
gc      # git commit
gp      # git push
gcp "message"  # Quick commit + push
```

**Bitwarden CLI:**
```bash
# First time setup
bwlogin              # Login and save session

# Daily usage (auto-prompts on shell start)
bwu                  # Unlock vault
bwg github           # Search & get password (copies to clipboard)
bwgen                # Generate strong password
bws                  # Sync vault

# SSH key management
bwsshadd             # Add your SSH key to Bitwarden
bwssh                # Load SSH key from Bitwarden to agent

# Environment variables
bw-env production    # Load production env vars from Bitwarden
```

**Development tools:**
```bash
v file.txt    # Open in neovim
dc ps         # docker ps (podman-backed)
```

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
