# Fedpunk Linux Setup

**An awesome omarchy-based Fedora setup with Hyprland**

Fedpunk is a modern, fish-first development environment built on top of the excellent [omarchy](https://github.com/swaystudio/omarchy) framework. It transforms your Fedora installation into a sleek, productive workspace featuring the Hyprland Wayland compositor, comprehensive theming system, and carefully curated development tools.

**✨ Fully compatible with omarchy themes** - Use any theme from omarchy or create your own!

---

## 🚀 Features

- **🎨 Omarchy-based theming** - Built on omarchy's excellent theme framework with full compatibility
- **🐟 Fish-first architecture** - Modern shell with intelligent autocompletion and scripting
- **🪟 Hyprland compositor** - Blazing fast tiling Wayland window manager with master layout support
- **⚡ Dynamic theme switching** - Switch themes on-the-fly with Super+Shift+T (14 complete themes included)
- **🖼️ Integrated wallpaper management** - Per-theme wallpapers with swaybg integration
- **⚡ NVIDIA support** - Proprietary driver installation with Wayland compatibility
- **🛠️ Premium development tools** - Neovim, tmux, lazygit, btop, bluetui, and more
- **🐱 Kitty terminal** - GPU-accelerated with live theme synchronization
- **🎨 Live theme reloading** - Neovim, Kitty, Mako, and btop reload automatically
- **📦 Automated setup** - One command installs and configures everything
- **✨ Beautiful install UI** - Interactive spinners and progress indicators with gum
- **🔄 Re-run safe** - Gracefully handles already-installed components

---

## 📋 System Requirements

- **OS**: Fedora Linux (39+)
- **Architecture**: x86_64
- **Internet**: Required for package downloads
- **Storage**: ~2GB free space
- **Optional**: NVIDIA GPU (for NVIDIA driver installation)

---

## ⚡ Quick Start

### Method 1: Full Desktop Install (Hyprland + Terminal)
```bash
# One-line install - clones repo and installs everything
curl -fsSL https://raw.githubusercontent.com/hinriksnaer/Fedpunk/main/boot.sh | bash

# Or manually:
git clone https://github.com/hinriksnaer/Fedpunk.git ~/.local/share/fedpunk
cd ~/.local/share/fedpunk
fish install.fish
```

This installs:
- **Desktop**: Hyprland, Kitty, Rofi, Mako, NVIDIA drivers (optional)
- **Terminal**: Fish Shell, Neovim, tmux, Lazygit, btop
- **Tools**: Claude Code AI assistant (optional)
- **Themes**: 14 complete omarchy themes with live switching

### Method 2: Terminal-Only Install (Recommended for Servers)
```bash
# Clone the repository anywhere you like
git clone https://github.com/hinriksnaer/Fedpunk.git
cd Fedpunk
./install.sh
```

This installs:
- **Terminal**: Fish Shell, Neovim, tmux, Lazygit, btop
- **Tools**: Claude Code AI assistant (optional)
- **Skips**: Hyprland, Kitty, and all desktop components

The configs will be deployed to standard XDG locations (`~/.config/`) via stow.

---

## 📦 Components

### 🐟 Terminal Setup
| Component | Description | Configuration |
|-----------|-------------|---------------|
| **Fish Shell** | Modern shell with intelligent features | `~/.config/fish/` |
| **Claude Code** | AI coding assistant | `~/.config/claude/` |
| **Neovim** | Modern vim-based editor | `~/.config/nvim/` |
| **Tmux** | Terminal multiplexer | `~/.config/tmux/` |
| **Lazygit** | Terminal git UI | `~/.config/lazygit/` |
| **btop** | Resource monitor | `~/.config/btop/` |
| **Audio Stack** | PipeWire audio server | System-wide |

### 🪟 Desktop Setup
| Component | Description | Configuration |
|-----------|-------------|---------------|
| **Hyprland** | Tiling Wayland compositor | `~/.config/hypr/` |
| **Kitty** | GPU-accelerated terminal | `~/.config/kitty/` |
| **Rofi** | Application launcher | `~/.config/rofi/` |
| **Mako** | Notification daemon | `~/.config/mako/` |
| **Firefox** | Default web browser | System default |
| **swaybg** | Wallpaper manager | Theme-controlled |
| **Desktop Portals** | File dialogs, authentication | Auto-configured |
| **NVIDIA** | Proprietary drivers (optional) | Auto-configured |

---

## 🔧 Installation Details

### What Gets Installed

**System Packages:**
- Fish shell with Starship prompt
- Claude Code AI assistant with Fish integration
- Hyprland compositor with essential tools
- Firefox browser with privacy optimizations
- Development utilities (ripgrep, fzf, git)
- Audio/video support (PipeWire, codecs)
- Desktop integration (portals, authentication)

**Configurations:**
- Fish shell with AI-enhanced functions and aliases
- Claude Code with project-aware assistance
- Hyprland with sensible keybindings and theming
- Neovim with LSP, modern plugins, and AI integration
- Tmux with plugin manager and Claude Code bindings
- Git integration with Lazygit and AI commit messages

**Optional Components:**
- NVIDIA proprietary drivers with Wayland support
- Additional browsers (Chromium, Brave)
- Extended development tools

### Architecture

Fedpunk uses a **modular Fish-first approach**:

1. **Boot** (`boot.sh`) - Preflight checks, installs git, fish, and gum
2. **Preflight** (`install/preflight/`) - Critical setup in order:
   - `setup-cargo.fish` - Rust/Cargo installation (many tools depend on this)
   - `setup-fish.fish` - Fish shell configuration, stow, and plugins
   - `install-essentials.fish` - Core development tools
   - `setup-system.fish` - System setup, repositories, and submodules
3. **Packaging** (`install/packaging/`) - Pure package installations (no configs):
   - `audio.fish`, `bluetui.fish`, `fonts.fish`, `claude.fish`, `nvidia.fish`
4. **Configuration** (`install/config/`) - End-to-end component setup (install + deploy):
   - Each script installs packages AND stows configs for easier troubleshooting
   - `btop.fish`, `neovim.fish`, `tmux.fish`, `lazygit.fish`, `kitty.fish`, `hyprland.fish`
5. **Post-install** (`install/post-install/`) - Theme setup and final configuration

### Installation UI

The installer features a **modern terminal UI** powered by gum:

- **Interactive spinners** - Visual feedback for all operations (downloads, installs, configuration)
- **Contextual animations** - Different spinner styles for different operations:
  - `line` - Downloads and network operations
  - `dot` - Package installations and quick operations
  - `meter` - System upgrades and heavy operations
  - `moon` - Discovery and scanning operations
  - `pulse` - Service reloads and restarts
- **Smart error handling** - Detailed error messages with log file references
- **Progress indicators** - Track installation progress ([1/8], [2/8], etc.)
- **Graceful re-runs** - Detects already-installed components and continues smoothly
- **Clean output** - Verbose command output captured in logs, only status messages shown

All installation logs are saved to `/tmp/fedpunk-install-*.log` for troubleshooting.

---

## 🎨 Post-Installation

### Starting Hyprland
```bash
# From display manager: Select "Hyprland" session
# From TTY:
Hyprland
```

### Key Bindings (Hyprland)

**Applications:**
- `Super + Return` - Terminal (Kitty)
- `Super + B` - Browser (Firefox)
- `Super + Space` - Application launcher (Rofi)
- `Super + E` - File manager (Thunar)
- `Super + Shift + B` - Bluetooth manager (bluetui)

**Window Management:**
- `Super + Q` - Close window
- `Super + Shift + E` - Exit Hyprland
- `Super + V` - Toggle floating
- `Super + F` - Toggle fullscreen
- `Super + h/j/k/l` - Focus windows (Vim keys)
- `Super + Shift + h/j/k/l` - Move windows
- `Super + Ctrl + h/j/k/l` - Resize windows

**Workspaces:**
- `Super + 1-9` - Switch workspaces
- `Super + Shift + 1-9` - Move window to workspace

**Theme & Appearance:**
- `Super + Shift + T` - Next theme
- `Super + Shift + Y` - Previous theme
- `Super + Shift + R` - Refresh current theme
- `Super + Shift + W` - Next wallpaper

**Layouts:**
- `Super + Alt + L` - Toggle layout (dwindle ↔ master)

**Screenshots:**
- `Print` - Selection screenshot
- `Super + Print` - Full screen screenshot
- `Super + Shift + S` - Alternative selection

### Shell Usage
```fish
# Fish is now your default shell with AI assistance
# Starship provides a modern prompt
# Use 'help' for Fish documentation

# Claude Code AI assistance
claude auth login          # Set up AI assistance
cc ask "your question"     # Quick AI queries
ai_commit                  # AI-generated commit messages
ai_explain some_command    # Explain commands or files
ai_fix                     # Fix code issues
ai_review                  # Code review assistance
```

---

## 🤖 AI-Enhanced Development

Fedpunk includes Claude Code for intelligent coding assistance:

### Quick AI Commands
```fish
# Basic assistance
cc ask "how do I optimize this function?"
ask "explain this error message"

# Development workflow  
ai_commit                    # Generate commit messages
ai_review                   # Code review assistance
ai_fix error.log           # Debug errors
ai_explain main.py         # Explain code files
ai_optimize slow_function  # Performance suggestions

# Project context
ai_project "how should I structure this app?"
```

### Integrated Features
- **Context-aware**: Automatically detects git repos and project files
- **Fish integration**: Native completions and shortcuts
- **tmux binding**: `Ctrl+a, C-a` opens Claude interactive mode
- **Neovim plugin**: AI assistance directly in your editor
- **Git workflow**: Smart commit messages and code reviews

---

## 🔄 Updates

```fish
# Navigate to wherever you cloned the repository
cd /path/to/Fedpunk
git pull
fish install.fish  # Re-run installation (safe to re-run)
```

---

## 🛠️ Customization

### Installation Structure

The installation system is organized by component type:

```
install/
├── preflight/        # System setup & prerequisites
├── terminal/         # Terminal-only components
│   ├── config/       # btop, neovim, tmux, lazygit
│   └── packaging/    # claude CLI
├── desktop/          # Desktop-only components
│   ├── config/       # hyprland, kitty, rofi
│   └── packaging/    # fonts, audio, bluetui, nvidia
├── post-install/     # Final cleanup tasks
└── helpers/          # Shared utility functions
```

### Adding Custom Packages

**Terminal components:**
- Add to `install/terminal/packaging/` for pure packages
- Add to `install/terminal/config/` for components with configs

**Desktop components:**
- Add to `install/desktop/packaging/` for pure packages
- Add to `install/desktop/config/` for components with configs

### Modifying Configurations
All configurations use standard XDG paths:
- `~/.config/` - Application configurations
- `~/.local/bin/` - User binaries

### Theming

Fedpunk uses the omarchy theming system for coordinated themes across all applications:

**Theme Management:**
```fish
fedpunk-theme-list      # List all available themes
fedpunk-theme-current   # Show current theme
fedpunk-theme-set <name>  # Switch to a specific theme
fedpunk-theme-next      # Cycle to next theme (Super+Shift+T)
fedpunk-theme-prev      # Cycle to previous theme (Super+Shift+Y)
fedpunk-theme-refresh   # Refresh current theme (Super+Shift+R)
```

**Creating Custom Themes:**
Themes are located in the `themes/` directory of your Fedpunk repository. Each theme directory contains:
- `hyprland.conf` - Hyprland colors and variables
- `kitty.conf` - Kitty terminal colors (omarchy standard)
- `rofi.rasi` - Rofi launcher theme
- `mako.ini` - Mako notification daemon theme
- `neovim.lua` - Neovim colorscheme (with live reload)
- `btop.theme` - btop resource monitor theme
- `backgrounds/` - Theme wallpapers

**Omarchy Theme Compatibility:**
14 complete themes included by default. You can also copy themes directly from any omarchy installation - they work out of the box!

**Supported Applications:**
- Hyprland - Window borders and decorations (instant)
- Kitty - Terminal colors (auto-reload on theme change)
- Rofi - Application launcher (instant)
- Mako - Notification daemon (auto-reload on theme change)
- Neovim - Editor colorscheme (live reload while editing)
- btop - Resource monitor (auto-reload on theme change)
- swaybg - Wallpapers (instant switching)

---

## 🐛 Troubleshooting

### Common Issues

**Fish not found after installation:**
```bash
# Restart shell or:
exec fish
```

**Hyprland won't start:**
```bash
# Check for NVIDIA driver conflicts:
dmesg | grep nvidia
# Ensure Wayland is properly configured
```

**Browser login issues:**
```bash
# Use device flow for GitHub CLI:
gh auth login --web=false
```

**Permission errors:**
```bash
# Fix SELinux contexts:
sudo restorecon -R ~/.config
```

**Audio not working:**
```bash
# Check PipeWire status:
systemctl --user status pipewire pipewire-pulse wireplumber

# Restart audio services:
systemctl --user restart pipewire pipewire-pulse wireplumber

# List audio devices:
wpctl status

# Test audio output:
paplay /usr/share/sounds/alsa/Front_Center.wav
```

**Bluetooth audio issues:**
```bash
# Restart Bluetooth service:
sudo systemctl restart bluetooth

# Connect via bluetoothctl:
bluetoothctl
# Then: scan on, pair <device>, connect <device>
```

---

## 📖 Documentation

- [Fish Shell Documentation](https://fishshell.com/docs/)
- [Hyprland Wiki](https://wiki.hyprland.org/)
- [Neovim Documentation](https://neovim.io/doc/)

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test the installation
5. Submit a pull request

---

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## 🙏 Acknowledgments

- [omarchy](https://github.com/swaystudio/omarchy) - The excellent theming framework this project is built upon
- [JaKooLit's Hyprland-Dots](https://github.com/JaKooLit/Fedora-Hyprland) - Inspiration and package references
- [Fish Shell Community](https://fishshell.com/) - Amazing shell and ecosystem
- [Hyprland Community](https://hyprland.org/) - Cutting-edge Wayland compositor

---

**Fedpunk - An awesome omarchy-based Fedora setup where aesthetics meet productivity**