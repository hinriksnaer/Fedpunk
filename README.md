# Fedpunk Linux Setup

**A modern, fish-first development environment for Fedora Linux with Hyprland**

Fedpunk transforms your Fedora installation into a sleek, productive development environment featuring the Hyprland Wayland compositor, Fish shell, and carefully curated development tools.

---

## 🚀 Features

- **🐟 Fish-first architecture** - Modern shell with intelligent autocompletion and syntax highlighting
- **🪟 Hyprland compositor** - Blazing fast tiling Wayland window manager
- **⚡ NVIDIA support** - Proprietary driver installation with Wayland compatibility
- **🛠️ Development tools** - Neovim, tmux, lazygit, and essential utilities
- **🎨 Consistent theming** - Coordinated color schemes across all applications
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
| **Neovim** | Modern vim-based editor | `~/.config/nvim/` |
| **Tmux** | Terminal multiplexer | `~/.config/tmux/` |
| **Lazygit** | Terminal git UI | `~/.config/lazygit/` |
| **btop** | Resource monitor | `~/.config/btop/` |

### 🪟 Desktop Setup  
| Component | Description | Configuration |
|-----------|-------------|---------------|
| **Hyprland** | Tiling Wayland compositor | `~/.config/hypr/` |
| **Foot** | Fast Wayland terminal | System default |
| **Desktop Portals** | File dialogs, authentication | Auto-configured |
| **NVIDIA** | Proprietary drivers (optional) | Auto-configured |

---

## 🔧 Installation Details

### What Gets Installed

**System Packages:**
- Fish shell with Starship prompt
- Hyprland compositor with essential tools
- Development utilities (ripgrep, fzf, git)
- Audio/video support (PipeWire, codecs)
- Desktop integration (portals, authentication)

**Configurations:**
- Fish shell with custom functions and aliases
- Hyprland with sensible keybindings and theming
- Neovim with LSP and modern plugins
- Tmux with plugin manager and themes
- Git integration with Lazygit

**Optional Components:**
- NVIDIA proprietary drivers with Wayland support
- Additional desktop applications

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
- `Super + Q` - Open terminal (Foot)
- `Super + R` - Application launcher (wofi)
- `Super + C` - Close window
- `Super + 1-9` - Switch workspaces
- `Print` - Screenshot to clipboard
- `Super + M` - Exit Hyprland

### Shell Usage
```fish
# Fish is now your default shell
# Starship provides a modern prompt
# Use 'help' for Fish documentation
```

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
Configurations use consistent color schemes. Modify:
- `fish/.config/starship.toml` - Prompt theming
- `hyprland/.config/hypr/hyprland.conf` - Window manager theming
- `btop/.config/btop/btop.conf` - Monitor theming

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

- [JaKooLit's Hyprland-Dots](https://github.com/JaKooLit/Fedora-Hyprland) - Inspiration and package references
- [Fish Shell Community](https://fishshell.com/) - Amazing shell and ecosystem
- [Hyprland Community](https://hyprland.org/) - Cutting-edge Wayland compositor

---

**Fedpunk - Where Fedora meets the future of Linux desktop computing**