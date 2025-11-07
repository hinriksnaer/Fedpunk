# Fedpunk Linux Setup

**An awesome omarchy-based Fedora setup with Hyprland**

Fedpunk is a modern, fish-first development environment built on top of the excellent [omarchy](https://github.com/swaystudio/omarchy) framework. It transforms your Fedora installation into a sleek, productive workspace featuring the Hyprland Wayland compositor, comprehensive theming system, and carefully curated development tools.

**✨ Fully compatible with omarchy themes** - Use any theme from omarchy or create your own!

---

## 🚀 Features

- **🎨 Omarchy-based theming** - Built on omarchy's excellent theme framework with full compatibility
- **🐟 Fish-first architecture** - Modern shell with intelligent autocompletion and scripting
- **🪟 Hyprland compositor** - Blazing fast tiling Wayland window manager with master layout support
- **⚡ Dynamic theme switching** - Switch themes on-the-fly with Super+Shift+T (includes all omarchy themes)
- **🖼️ Integrated wallpaper management** - Per-theme wallpapers with swaybg integration
- **⚡ NVIDIA support** - Proprietary driver installation with Wayland compatibility
- **🛠️ Premium development tools** - Neovim, tmux, lazygit, btop, bluetui, and more
- **🐱 Kitty terminal** - GPU-accelerated with theme synchronization
- **📦 Automated setup** - One command installs and configures everything

---

## 📋 System Requirements

- **OS**: Fedora Linux (39+)
- **Architecture**: x86_64
- **Internet**: Required for package downloads
- **Storage**: ~2GB free space
- **Optional**: NVIDIA GPU (for NVIDIA driver installation)

---

## ⚡ Quick Start

### One-Command Full Install
```bash
git clone https://github.com/yourusername/fedpunk.git
cd fedpunk
bash install.sh
```

### Interactive Installation
```fish
git clone https://github.com/yourusername/fedpunk.git
cd fedpunk
fish install.fish
```

### Direct Commands
```fish
# Full setup (terminal + desktop)
fish install.fish full

# Terminal only (Fish, Neovim, tmux, etc.)
fish install.fish terminal

# Desktop only (Hyprland environment)
fish install.fish desktop

# Custom components
fish install.fish custom --neovim --tmux --hyprland
```

### Quick Terminal Setup
```fish
# Just the essentials for development
fish install-terminal.fish
```

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

### 🪟 Desktop Setup
| Component | Description | Configuration |
|-----------|-------------|---------------|
| **Hyprland** | Tiling Wayland compositor | `~/.config/hypr/` |
| **Kitty** | GPU-accelerated terminal | `~/.config/kitty/` |
| **Walker** | Application launcher | `~/.config/walker/` |
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

1. `install.fish` - Main installer with interactive menu
2. `install-terminal.fish` - Terminal-focused setup (Fish, Neovim, tmux)
3. `install-desktop.fish` - Desktop environment setup (Hyprland)
4. Individual component installers in `scripts/` directory
5. Automatic dependency resolution and error handling

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
- `Super + Space` - Application launcher (Walker)
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
cd fedpunk
git pull
fish install.fish  # Re-run for updates

# Or update specific parts:
fish install-terminal.fish  # Update terminal tools
fish install-desktop.fish   # Update desktop environment
```

---

## 🛠️ Customization

### Adding Custom Packages
Edit `scripts/install-*.fish` files to add your preferred packages.

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
Themes are located in `~/Fedpunk/themes/`. Each theme directory contains:
- `hyprland.conf` - Hyprland colors and variables
- `kitty.conf` - Kitty terminal colors (omarchy standard)
- `walker.css` - Walker launcher theme
- `btop.theme` - btop resource monitor theme
- `backgrounds/` - Theme wallpapers

**Omarchy Theme Compatibility:**
All 12 omarchy themes are included by default. You can also copy themes directly from any omarchy installation - they work out of the box!

**Supported Applications:**
- Hyprland window borders and decorations
- Kitty terminal (requires restart to apply)
- Walker application launcher (auto-reloads)
- btop resource monitor (auto-reloads)
- swaybg wallpapers (instant switching)

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