# Fedpunk Installation Guide

Complete guide to installing Fedpunk on Fedora Linux.

---

## 📋 Prerequisites

- **OS:** Fedora Linux 39 or newer
- **Architecture:** x86_64
- **Internet Connection:** Required for package downloads
- **Disk Space:** ~2GB free space
- **User Account:** Non-root user with sudo privileges

---

## 🚀 Quick Install

### One-Command Bootstrap

```bash
curl -fsSL https://raw.githubusercontent.com/hinriksnaer/Fedpunk/main/boot.sh | bash
```

**What this does:**
1. Installs minimal dependencies (git, fish, stow, gum, yq)
2. Clones Fedpunk repository to `~/.local/share/fedpunk`
3. Launches the interactive installer

**Follow the interactive prompts to:**
- Choose your profile (`default`, `dev`, or `example`)
- Select your mode (desktop or container)
- Optionally add extra modules

---

## 📦 Profile Selection

### Recommended: Default Profile

```bash
# During interactive install, choose:
Profile: default
Mode: desktop (or container)
```

**The `default` profile includes:**
- Core development tools (Neovim, Fish, tmux)
- File managers and utilities (lazygit, yazi, btop)
- Desktop environment (Hyprland, Kitty, Rofi) [desktop mode only]
- GitHub CLI and Bitwarden password manager
- Claude Code integration
- 12 theme system with live switching

**What's NOT included:**
- Hardware-specific configurations (NVIDIA, fan control)
- Audio/multimedia (add separately if needed)
- Personal entertainment apps

### Dev Profile (Reference)

The `dev` profile is the author's personal configuration including:
- All default profile features
- NVIDIA GPU drivers
- Audio and multimedia packages
- Personal plugins (Spotify, Discord, dev container CLI)
- Hardware-specific configurations (fan control, ultrawide monitor)

**Use this as reference** for creating your own customizations.

### Example Profile (Template)

Minimal template for building your own custom profile. See [`profiles/example/README.md`](../../profiles/example/README.md) for details.

---

## 🎭 Mode Selection

### Desktop Mode

**Full GUI environment with:**
- Hyprland Wayland compositor
- Kitty GPU-accelerated terminal
- Rofi application launcher
- Waybar status bar
- Firefox browser
- Complete theming system

**Best for:**
- Primary workstation setup
- Development on physical hardware
- Full Fedpunk experience

### Container Mode

**Terminal-only setup with:**
- Fish shell and modern CLI tools
- Neovim with full LSP support
- tmux, lazygit, btop, yazi
- Theme system (terminal apps only)

**Best for:**
- Devcontainers and remote servers
- WSL environments
- Existing desktop setups (add tools only)
- Minimal installations

---

## 🔧 Manual Installation

### Step 1: Bootstrap

```bash
# Install minimal dependencies
sudo dnf install -y git fish stow gum yq

# Clone repository
git clone https://github.com/hinriksnaer/Fedpunk.git ~/.local/share/fedpunk
cd ~/.local/share/fedpunk
```

### Step 2: Run Installer

**Interactive (recommended):**
```bash
fish install.fish
```

**Non-interactive:**
```bash
# Desktop mode with default profile
fish install.fish --profile default --mode desktop --non-interactive

# Container mode
fish install.fish --profile default --mode container --non-interactive
```

### Step 3: Activate

**For desktop mode:**
```bash
# Restart to load Hyprland
sudo systemctl reboot
```

**For container mode:**
```bash
# Start Fish shell
exec fish

# Configuration is already active via symlinks
```

---

## 🎨 Post-Installation

### Try the Theme System

```fish
# List all themes
fedpunk-theme-list

# Switch themes
fedpunk-theme-set catppuccin
fedpunk-theme-set tokyo-night
fedpunk-theme-set nord

# Keyboard shortcuts (desktop mode)
Super+T              # Theme selection menu
Super+Shift+T        # Next theme
Super+Shift+Y        # Previous theme
```

### Add Optional Modules

```fish
# NVIDIA GPU support
fedpunk module deploy nvidia

# Audio and multimedia
fedpunk module deploy audio
fedpunk module deploy multimedia

# Vertex AI for Claude Code
fedpunk module deploy vertex-ai

# List all available modules
fedpunk module list
```

### Configure Tools

**Neovim:**
```bash
# Open Neovim
nvim

# Inside Neovim:
:checkhealth        # Verify LSP setup
:Lazy               # Manage plugins
:Mason              # Manage LSP servers
```

**GitHub CLI:**
```bash
# Authenticate with GitHub
gh auth login

# Verify
gh repo list
```

**Bitwarden:**
```bash
# Login to vault
fedpunk vault login

# Check status
fedpunk vault status
```

---

## 🔄 Updating Fedpunk

### Update System

```bash
# Navigate to Fedpunk directory
cd ~/.local/share/fedpunk

# Pull latest changes
git pull

# Re-run installer (safe to repeat)
fish install.fish

# Update system packages
sudo dnf update -y
```

### Update Individual Modules

```bash
# Force update specific module
fedpunk module deploy neovim --force

# Relink configurations
fedpunk module stow neovim
```

### Reload Services

```bash
# Reload all services (desktop mode)
hyprctl reload

# Reload shell
exec fish
```

---

## 🐛 Troubleshooting

### Fish Shell Not Available

```bash
# Manually start Fish
exec fish

# Or restart terminal
exit
# Then reopen terminal
```

### Hyprland Won't Start

```bash
# Check logs
cat /tmp/hypr/$(ls -t /tmp/hypr/ | head -1)/hyprland.log

# Verify desktop mode was selected
cat ~/.local/share/fedpunk/.active-config

# NVIDIA users - ensure drivers loaded
lsmod | grep nvidia
```

### Missing Dependencies

```bash
# Re-run bootstrap
bash ~/.local/share/fedpunk/boot.sh

# Manually install core dependencies
sudo dnf install -y git fish stow gum yq
```

### Neovim Plugins Not Loading

```bash
# Open Neovim
nvim

# Sync plugins
:Lazy sync

# Check health
:checkhealth
```

### Permission Issues

```bash
# Fix ownership
sudo chown -R $USER:$USER ~/.config ~/.local/share/fedpunk

# Fix SELinux contexts (Fedora)
sudo restorecon -R ~/.config ~/.local/share/fedpunk
```

### Stow Conflicts

```bash
# If stow reports conflicts, check what's blocking
stow -n -v -d ~/.local/share/fedpunk/modules/fish/config -t ~

# Backup and remove conflicting files
mv ~/.config/fish ~/.config/fish.backup

# Retry module deployment
fedpunk module deploy fish
```

---

## 📁 Installation Logs

All installation output is saved to:
```
/tmp/fedpunk-install-<timestamp>.log
```

**View logs:**
```bash
# Find latest log
ls -lt /tmp/fedpunk-install-*.log | head -1

# View log
cat /tmp/fedpunk-install-*.log

# Search for errors
grep -i "error\|fail" /tmp/fedpunk-install-*.log
```

---

## 🐳 Container-Specific Installation

### For Devcontainers

**devcontainer.json:**
```json
{
  "name": "Fedpunk Dev",
  "image": "fedora:40",
  "postCreateCommand": "curl -fsSL https://raw.githubusercontent.com/hinriksnaer/Fedpunk/main/boot.sh | bash -s -- --profile default --mode container --non-interactive",
  "customizations": {
    "vscode": {
      "settings": {
        "terminal.integrated.defaultProfile.linux": "fish"
      }
    }
  }
}
```

### For Remote Servers

```bash
# SSH into server
ssh user@server

# Run container mode install
curl -fsSL https://raw.githubusercontent.com/hinriksnaer/Fedpunk/main/boot.sh | bash -s -- --profile default --mode container --non-interactive

# Start Fish shell
exec fish
```

---

## 🔐 Security Considerations

### Bootstrap Script

The bootstrap script (`boot.sh`) only:
- Installs minimal dependencies via DNF
- Clones the repository
- Launches Fish-based installer

**Review before running:**
```bash
curl https://raw.githubusercontent.com/hinriksnaer/Fedpunk/main/boot.sh | less
```

### Sudo Usage

Fedpunk requires sudo for:
- Installing system packages (DNF)
- Setting Fish as default shell (`chsh`)
- NVIDIA driver installation (if selected)

**All sudo operations are clearly logged** in installation logs.

---

## 🎯 What Gets Installed

### System Packages (DNF)

**Core utilities:**
- git, fish, stow, gum, yq
- ripgrep, fzf, fd-find, bat, eza
- curl, wget, unzip, tar

**Development tools (if languages module included):**
- rust, cargo
- nodejs, npm
- python3, pip

**Desktop environment (desktop mode only):**
- hyprland, kitty, rofi
- waybar, mako, swaybg
- firefox

### Dotfiles

Fedpunk uses **GNU Stow** to symlink configurations:

```
~/.local/share/fedpunk/modules/fish/config/.config/fish/
↓ (stow symlink)
~/.config/fish/
```

**This means:**
- Instant deployment (no generation step)
- Live editing (changes are immediate)
- Easy rollback (unstow module)

### Installation Location

```
~/.local/share/fedpunk/          # Main repository
├── modules/                     # 27 modules
├── profiles/                    # Profile configurations
│   ├── default/                 # Recommended profile
│   ├── dev/                     # Reference profile
│   └── example/                 # Template profile
├── themes/                      # 12 themes
└── lib/fish/                    # Core orchestration
```

---

## 🚪 Uninstalling

### Remove Fedpunk

```bash
# Unstow all configurations
cd ~/.local/share/fedpunk
for module in modules/*/; do
    fedpunk module unstow $(basename $module)
done

# Remove repository
rm -rf ~/.local/share/fedpunk

# Remove Fish as default shell (optional)
chsh -s /bin/bash

# Uninstall packages (optional, manual)
# Review and remove packages as needed
```

**Note:** Your existing configurations will remain in `~/.config/` after unstowing.

---

## 📚 Next Steps

After installation:

1. **Explore the basics:**
   - [`docs/guides/customization.md`](customization.md) - Personalize your setup
   - [`docs/guides/themes.md`](themes.md) - Theme system guide
   - [`docs/reference/keybindings.md`](../reference/keybindings.md) - Keyboard shortcuts

2. **Learn the module system:**
   - [`docs/design/DOTFILE_MODULES.md`](../design/DOTFILE_MODULES.md) - Architecture
   - [`docs/development/contributing.md`](../development/contributing.md) - Create modules

3. **Join the community:**
   - Star the [GitHub repository](https://github.com/hinriksnaer/Fedpunk)
   - Report issues or contribute improvements
   - Share your custom profiles and themes

---

**Ready to transform your workflow? Welcome to Fedpunk!** 🚀
