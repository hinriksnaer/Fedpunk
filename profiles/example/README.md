# Example Profile

**Template profile for creating custom Fedpunk profiles**

---

## 📋 Purpose

This is a **minimal template** for creating your own Fedpunk profile. Copy this directory and customize it for your needs.

**Use Cases:**
- Work profile with company-specific tools
- Personal profile with entertainment apps
- Minimal server profile
- Testing/experimentation profile

---

## 🗂️ Structure

```
profiles/example/
├── modes/                   # Required: Module lists
│   ├── desktop.yaml         # Full desktop environment
│   └── container.yaml       # Terminal-only environment
├── plugins/                 # Optional: Profile-specific modules
│   └── README.md            # Plugin documentation
├── fedpunk.toml             # Optional: Extra packages/scripts
└── monitors.conf            # Optional: Monitor configuration
```

---

##🚀 Quick Start

### Create Your Profile

```bash
# 1. Copy example profile
cp -r ~/.local/share/fedpunk/profiles/example ~/.local/share/fedpunk/profiles/myprofile

# 2. Customize module lists
nvim ~/.local/share/fedpunk/profiles/myprofile/modes/desktop.yaml

# 3. Activate your profile
fedpunk-activate-profile myprofile

# 4. Install your profile
cd ~/.local/share/fedpunk
fish install.fish  # Will prompt for profile
# Select "myprofile" from list
```

---

## 📝 Mode Files

### `modes/desktop.yaml`

**Full desktop environment template:**

```yaml
mode:
  name: desktop
  description: Full desktop environment

modules:
  # Core System (choose what you need)
  - essentials       # Core utilities
  - languages        # Programming languages

  # Terminal Tools
  - fish             # Modern shell
  - neovim           # Editor
  - tmux             # Multiplexer

  # Desktop (if needed)
  - fonts            # Fonts
  - kitty            # Terminal emulator
  - hyprland         # Window manager

  # Your custom modules
  # - plugins/my-tools
```

**Customize by:**
- Removing modules you don't need
- Adding modules from `modules/` directory
- Adding your own plugins

### `modes/container.yaml`

**Minimal terminal-only template:**

```yaml
mode:
  name: container
  description: Minimal terminal environment

modules:
  # Essential only
  - essentials
  - fish
  - neovim

  # Add others as needed
  # - tmux
  # - lazygit
```

**Use for:**
- Devcontainers
- Remote servers
- CI/CD environments
- Minimal installs

---

## 🔌 Creating Profile Plugins

### Why Plugins?

**Plugins are profile-scoped modules** perfect for:
- Work-specific tools (VPN, company CLI tools)
- Personal apps (Spotify, Discord, games)
- Experimental features
- Profile-specific configurations

### Plugin Structure

```bash
profiles/myprofile/plugins/my-plugin/
├── module.yaml              # Module metadata (required)
├── config/                  # Dotfiles (optional)
│   └── .config/my-plugin/
│       └── config.conf
└── scripts/                 # Lifecycle hooks (optional)
    ├── install              # Custom installation
    └── after                # Post-deployment
```

### Example: Work Tools Plugin

```bash
# 1. Create plugin directory
mkdir -p profiles/myprofile/plugins/work-tools

# 2. Create module.yaml
cat > profiles/myprofile/plugins/work-tools/module.yaml <<'EOF'
module:
  name: work-tools
  description: Work-specific development tools
  dependencies:
    - fish

packages:
  dnf:
    - openvpn
    - remmina  # RDP client
  npm:
    - "@company/cli"

stow:
  target: $HOME
  conflicts: warn
EOF

# 3. Add configuration
mkdir -p profiles/myprofile/plugins/work-tools/config/.config/work
echo "COMPANY_API_KEY=xxx" > profiles/myprofile/plugins/work-tools/config/.config/work/env

# 4. Deploy
fedpunk module deploy plugins/work-tools

# 5. Add to desktop mode for auto-deployment
echo "  - plugins/work-tools" >> profiles/myprofile/modes/desktop.yaml
```

**See:** [plugins/README.md](plugins/README.md) for detailed guide

---

## 🖥️ Monitor Configuration

### `monitors.conf` (Optional)

Profile-specific Hyprland monitor setup.

**Create the file:**
```bash
cat > profiles/myprofile/monitors.conf <<'EOF'
# Primary monitor
monitor = DP-1, 2560x1440@144, 0x0, 1

# Secondary monitor (optional)
# monitor = HDMI-A-1, 1920x1080@60, 2560x0, 1
EOF
```

**Find your monitors:**
```bash
hyprctl monitors
```

**Common setups:**

**Laptop only:**
```conf
monitor = eDP-1, 1920x1080@60, 0x0, 1
```

**External + laptop:**
```conf
monitor = DP-1, 2560x1440@144, 0x0, 1
monitor = eDP-1, 1920x1080@60, 2560x0, 1
```

**External only (disable laptop):**
```conf
monitor = DP-1, 2560x1440@144, 0x0, 1
monitor = eDP-1, disable
```

---

## ⚙️ Extra Configuration

### `fedpunk.toml` (Optional)

Profile-level packages and setup scripts.

**Create the file:**
```bash
cat > profiles/myprofile/fedpunk.toml <<'EOF'
[packages]
extra = ["htop", "tree", "tldr"]

[scripts]
setup = ["setup-work-env.fish"]
EOF
```

**What it does:**
- `extra` - DNF packages to install on profile activation
- `setup` - Scripts to run on profile activation (relative to profile dir)

**Activate profile to run:**
```bash
fedpunk-activate-profile myprofile
```

---

## 🎯 Profile Examples

### Minimal Server Profile

```yaml
# modes/server.yaml
mode:
  name: server
  description: Minimal server tools

modules:
  - essentials
  - fish
  - tmux
  - btop
  # No desktop components
```

### Gaming/Entertainment Profile

```yaml
# modes/desktop.yaml
mode:
  name: gaming
  description: Entertainment and gaming setup

modules:
  # Base system
  - essentials
  - fish
  - neovim

  # Desktop
  - fonts
  - kitty
  - hyprland

  # Entertainment plugins
  - plugins/gaming
  - plugins/media
```

```yaml
# plugins/gaming/module.yaml
module:
  name: gaming
  description: Gaming and entertainment apps

packages:
  flatpak:
    - com.spotify.Client
    - com.discordapp.Discord
    - com.valvesoftware.Steam

stow:
  target: $HOME
  conflicts: warn
```

### Work Profile

```yaml
# modes/desktop.yaml
modules:
  # Development essentials
  - essentials
  - languages
  - fish
  - neovim
  - tmux

  # Desktop
  - fonts
  - kitty
  - hyprland

  # Work tools
  - plugins/work-vpn
  - plugins/work-tools
  - plugins/company-cli
```

---

## 🔄 Workflow

### 1. Create Profile

```bash
# Copy template
cp -r profiles/example profiles/work

# Edit modes
nvim profiles/work/modes/desktop.yaml
nvim profiles/work/modes/container.yaml
```

### 2. Add Plugins (Optional)

```bash
# Create plugin
mkdir -p profiles/work/plugins/company-tools

# Add module.yaml
nvim profiles/work/plugins/company-tools/module.yaml

# Add to mode
echo "  - plugins/company-tools" >> profiles/work/modes/desktop.yaml
```

### 3. Add Monitor Config (Optional)

```bash
# Create monitors.conf
nvim profiles/work/monitors.conf
```

### 4. Activate & Install

```bash
# Activate profile
fedpunk-activate-profile work

# Install with profile
fish install.fish --mode desktop
```

---

## 📊 Available Modules

**View all available modules:**
```bash
fedpunk module list
```

**Common modules:**
- `essentials` - Core utilities (ripgrep, fzf, fd, etc)
- `languages` - Programming languages (Rust, Node.js, etc)
- `fish` - Fish shell
- `neovim` - Neovim editor with LSP
- `tmux` - Terminal multiplexer
- `lazygit` - Git TUI
- `yazi` - File manager
- `btop` - System monitor
- `fonts` - JetBrainsMono, Nerd Fonts
- `kitty` - GPU-accelerated terminal
- `hyprland` - Wayland compositor
- `rofi` - Application launcher
- `waybar` - Status bar
- `mako` - Notifications
- `firefox` - Browser
- `gh` - GitHub CLI
- `bitwarden` - Password manager CLI
- `claude` - Claude Code integration

**Module info:**
```bash
fedpunk module info <module-name>
```

---

## 🆘 Troubleshooting

### Profile Not Listed

```bash
# Profiles must be in profiles/ directory
ls ~/.local/share/fedpunk/profiles/

# Profile needs at least one mode file
ls ~/.local/share/fedpunk/profiles/myprofile/modes/
```

### Module Not Found

```bash
# Check module exists
fedpunk module list | grep <module-name>

# Check spelling in mode file
cat profiles/myprofile/modes/desktop.yaml
```

### Plugin Not Deploying

```bash
# Check active profile
readlink ~/.local/share/fedpunk/.active-config

# Should point to your profile:
# ~/.local/share/fedpunk/profiles/myprofile

# Activate if needed
fedpunk-activate-profile myprofile

# Deploy manually
fedpunk module deploy plugins/<plugin-name>
```

---

## 📚 Next Steps

1. **Copy this profile:**
   ```bash
   cp -r profiles/example profiles/myprofile
   ```

2. **Customize modes:**
   - Edit `modes/desktop.yaml`
   - Edit `modes/container.yaml`

3. **Create plugins (optional):**
   - Create `plugins/my-tools/`
   - Add `module.yaml`
   - Deploy: `fedpunk module deploy plugins/my-tools`

4. **Install:**
   ```bash
   fish install.fish
   # Select your profile when prompted
   ```

---

## 📖 Documentation

- **[Dev Profile](../dev/README.md)** - Reference implementation
- **[Plugin System](../dev/plugins/README.md)** - Complete plugin guide
- **[Architecture](../../ARCHITECTURE.md)** - Module system design
- **[Module Creation](../../docs/development/contributing.md)** - Creating modules

---

**Profile Template Version:** 2.0
**Last Updated:** 2025-01-20
**Compatible With:** Fedpunk v2.0+
