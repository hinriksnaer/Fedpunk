# Dev Profile

**Development profile for Fedpunk with desktop and container modes**

---

## 📋 Overview

The `dev` profile is the default Fedpunk profile featuring:
- **Desktop Mode** - Full Hyprland environment with all development tools
- **Container Mode** - Minimal terminal-only setup for devcontainers and servers
- **Plugin System** - Profile-specific modules for custom tools
- **Monitor Configuration** - Custom display setup for desktop mode

---

## 🗂️ Structure

```
profiles/dev/
├── modes/                      # Module lists per environment
│   ├── desktop/                # Full desktop with Hyprland
│   │   ├── mode.yaml
│   │   └── hypr.conf          # Per-mode Hyprland overrides
│   ├── laptop/                 # Laptop-optimized mode
│   │   ├── mode.yaml
│   │   └── hypr.conf
│   └── container/              # Minimal terminal-only
│       └── mode.yaml
├── plugins/                    # Profile-specific modules
│   ├── README.md               # Plugin system documentation
│   └── dev-extras/             # Example: Spotify, Discord, Devcontainer CLI
│       ├── module.yaml
│       └── config/
├── fedpunk.toml                # Extra packages and setup scripts
└── monitors.conf               # Hyprland monitor configuration
```

---

## 🎭 Modes

### Desktop Mode (`desktop/mode.yaml`)

**Full development environment with GUI:**

```yaml
modules:
  # Core System
  - essentials         # Core utils, ripgrep, fzf, etc
  - languages          # Rust, Node.js, etc

  # Terminal Tools
  - neovim             # Editor with LSP
  - fish               # Modern shell
  - starship           # Prompt
  - tmux               # Terminal multiplexer
  - lazygit            # Git TUI
  - yazi               # File manager
  - btop               # System monitor

  # Desktop Environment
  - fonts              # JetBrainsMono, Nerd Fonts
  - kitty              # GPU-accelerated terminal
  - hyprland           # Wayland compositor
  - rofi               # Launcher
  - waybar             # Status bar
  - mako               # Notifications
  - firefox            # Browser

  # Development Tools
  - gh                 # GitHub CLI
  - bitwarden          # Password manager CLI
  - claude             # Claude Code integration

  # Profile Plugins
  - plugins/dev-extras # Spotify, Discord, Devcontainer CLI
```

**Deploy:**
```bash
fish install.fish                    # Interactive (chooses desktop automatically)
# OR
fish install.fish --mode desktop     # Explicit
```

### Container Mode (`container/mode.yaml`)

**Minimal terminal-only setup:**

```yaml
modules:
  # Core System
  - essentials         # Core utils only
  - languages          # Rust, Node.js

  # Terminal Tools
  - neovim             # Editor with LSP
  - fish               # Shell
  - starship           # Prompt
  - tmux               # Multiplexer
  - lazygit            # Git TUI
  - btop               # System monitor

  # Development Tools
  - gh                 # GitHub CLI
  - bitwarden          # Password manager CLI
  - claude             # Claude Code integration

  # No desktop components!
```

**Deploy:**
```bash
fish install.fish --mode container --non-interactive
```

**Perfect for:**
- Devcontainers
- Remote servers via SSH
- WSL environments
- Docker containers
- CI/CD environments

---

## 🔌 Plugin System

Profile plugins are **profile-scoped modules** that extend the base installation.

### Why Plugins?

- **Isolation** - Keep work/personal tools separate
- **No Merge Conflicts** - Profiles are gitignored
- **Composable** - Mix base modules + custom plugins
- **Full Module Features** - Dependencies, packages, configs, lifecycle hooks

### Plugin Structure

```bash
profiles/dev/plugins/my-plugin/
├── module.yaml          # Standard module metadata
├── config/              # Dotfiles (stowed to $HOME)
│   └── .config/my-plugin/
│       └── config.conf
└── scripts/             # Lifecycle hooks (optional)
    ├── install
    └── after
```

### Example: dev-extras Plugin

```yaml
# profiles/dev/plugins/dev-extras/module.yaml
module:
  name: dev-extras
  description: Extra development tools - Spotify, Discord, Devcontainer CLI
  dependencies:
    - fish

packages:
  npm:
    - "@devcontainers/cli"
  flatpak:
    - com.spotify.Client
    - com.discordapp.Discord

stow:
  target: $HOME
  conflicts: warn
```

### Creating a Plugin

**1. Create plugin directory:**
```bash
mkdir -p profiles/dev/plugins/work-tools
```

**2. Add module.yaml:**
```yaml
module:
  name: work-tools
  description: Work-specific development tools
  dependencies:
    - fish

packages:
  dnf:
    - podman-compose
  npm:
    - "@company/cli-tool"

stow:
  target: $HOME
  conflicts: warn
```

**3. Add configs (optional):**
```bash
mkdir -p profiles/dev/plugins/work-tools/config/.config/work
echo "API_KEY=..." > profiles/dev/plugins/work-tools/config/.config/work/credentials
```

**4. Deploy:**
```bash
fedpunk module deploy plugins/work-tools
```

**5. Add to mode (auto-deploy on install):**
```yaml
# profiles/dev/modes/desktop/mode.yaml
modules:
  - fish
  - neovim
  # ...
  - plugins/work-tools  # Auto-deployed with profile
```

**See:** [plugins/README.md](plugins/README.md) for complete guide

---

## 🖥️ Monitor Configuration

### `monitors.conf`

Profile-specific Hyprland monitor configuration sourced **after** default settings.

**Edit your display setup:**
```bash
nvim profiles/dev/monitors.conf
```

**Example configurations:**

**Single monitor:**
```conf
# Laptop screen
monitor = eDP-1, 1920x1080@60, 0x0, 1
```

**Dual monitors (side by side):**
```conf
# Primary on left
monitor = DP-1, 2560x1440@144, 0x0, 1
# Secondary on right
monitor = HDMI-A-1, 1920x1080@60, 2560x0, 1
```

**Ultrawide + laptop:**
```conf
# Ultrawide primary
monitor = DP-1, 3440x1440@100, 0x0, 1
# Laptop below (for reference)
monitor = eDP-1, 1920x1080@60, 760x1440, 1
```

**Disable laptop screen when docked:**
```conf
# External monitor
monitor = DP-1, 2560x1440@144, 0x0, 1
# Disable laptop
monitor = eDP-1, disable
```

**Find your monitor names:**
```bash
hyprctl monitors
```

**Reload after changes:**
```bash
hyprctl reload
# OR
Super+Shift+C
```

---

## ⚙️ Extra Configuration (`fedpunk.toml`)

Profile-level packages and setup scripts (optional).

```toml
[packages]
extra = ["htop", "ncdu", "tree"]

[scripts]
setup = ["setup-work-vpn.fish", "configure-keys.fish"]
```

**Usage:**
```bash
fedpunk-activate-profile dev
```

This will:
1. Install extra packages via DNF
2. Run setup scripts
3. Deploy profile plugins (if in mode)

---

## 🎯 Usage Examples

### Activate Profile

```bash
# Activate dev profile
fedpunk-activate-profile dev

# Or set as active
ln -sf ~/.local/share/fedpunk/profiles/dev ~/.local/share/fedpunk/.active-config
```

### View Profile Modules

```bash
# Desktop mode modules
cat ~/.local/share/fedpunk/profiles/dev/modes/desktop/mode.yaml

# Container mode modules
cat ~/.local/share/fedpunk/profiles/dev/modes/container/mode.yaml
```

### Add Module to Mode

```bash
# Add module to desktop mode
echo "  - docker" >> profiles/dev/modes/desktop/mode.yaml

# Deploy new module
fedpunk module deploy docker
```

### Create and Deploy Plugin

```bash
# Create plugin structure
mkdir -p profiles/dev/plugins/my-tools
cat > profiles/dev/plugins/my-tools/module.yaml <<'EOF'
module:
  name: my-tools
  description: My custom tools
  dependencies: []

packages:
  dnf:
    - my-package

stow:
  target: $HOME
  conflicts: warn
EOF

# Deploy plugin
fedpunk module deploy plugins/my-tools

# Add to mode for auto-deployment
echo "  - plugins/my-tools" >> profiles/dev/modes/desktop/mode.yaml
```

---

## 🔄 Updating Profile

### Update Module List

```bash
# Edit mode file
nvim profiles/dev/modes/desktop/mode.yaml

# Re-run installer to deploy changes
fish install.fish --mode desktop
```

### Update Monitor Configuration

```bash
# Edit monitors
nvim profiles/dev/monitors.conf

# Reload Hyprland
hyprctl reload
```

### Update Plugins

```bash
# Edit plugin
nvim profiles/dev/plugins/dev-extras/module.yaml

# Redeploy
fedpunk module deploy plugins/dev-extras
```

---

## 🎓 Customization Tips

### Add Work-Specific Module

```bash
# 1. Create plugin
mkdir -p profiles/dev/plugins/work-vpn

# 2. Add module.yaml with VPN packages
cat > profiles/dev/plugins/work-vpn/module.yaml <<EOF
module:
  name: work-vpn
  description: Work VPN and security tools

packages:
  dnf:
    - openvpn
    - network-manager-openvpn-gnome

stow:
  target: \$HOME
  conflicts: warn
EOF

# 3. Add VPN config
mkdir -p profiles/dev/plugins/work-vpn/config/.config/openvpn
# Copy VPN config files here

# 4. Deploy
fedpunk module deploy plugins/work-vpn
```

### Remove Desktop Components for Server

```bash
# Just install container mode
fish install.fish --mode container --non-interactive
```

### Mix and Match Modules

```yaml
# profiles/dev/modes/custom.yaml
modules:
  # Core (always needed)
  - essentials
  - fish
  - neovim

  # Desktop (only what you want)
  - fonts
  - kitty
  # Skip hyprland if using i3/sway

  # Your plugins
  - plugins/my-tools
```

---

## 📊 Module Deployment Order

Modules deploy in the order listed in mode files, with **dependencies deployed first automatically**.

**Example:**
```yaml
modules:
  - hyprland  # Depends on fonts, kitty
  - fonts
  - kitty
```

**Actual deployment order:**
1. fonts (hyprland dependency)
2. kitty (hyprland dependency)
3. hyprland (requested)

Dependencies are resolved recursively and automatically.

---

## 🆘 Troubleshooting

### Plugin Not Found

```bash
# Check active profile
readlink ~/.local/share/fedpunk/.active-config

# Should point to: ~/.local/share/fedpunk/profiles/dev

# If not, activate profile
fedpunk-activate-profile dev
```

### Monitor Config Not Applying

```bash
# Check if file is sourced
grep -r "monitors.conf" ~/.config/hypr/

# Reload Hyprland
hyprctl reload

# Check current monitors
hyprctl monitors
```

### Mode Not Installing Plugins

```bash
# Ensure plugin is listed in mode file
cat profiles/dev/modes/desktop/mode.yaml | grep plugins/

# Deploy manually
fedpunk module deploy plugins/<plugin-name>
```

---

## 📚 See Also

- **[Plugin System Guide](plugins/README.md)** - Complete plugin documentation
- **[Module Creation](../../docs/development/contributing.md)** - How to create modules
- **[Architecture](../../ARCHITECTURE.md)** - Module system design
- **[Customization Guide](../../docs/guides/customization.md)** - General customization

---

**Profile Version:** 2.0
**Last Updated:** 2025-01-20
**Compatible With:** Fedpunk v2.0+
