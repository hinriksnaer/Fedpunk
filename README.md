# Fedpunk

**A modern, keyboard-driven Fedora development environment with Hyprland Wayland compositor**

Fedpunk transforms Fedora into a productivity-focused workspace featuring tiling window management, seamless theming, and a curated set of development tools—all driven by Fish shell and designed for developers who value efficiency and aesthetics.

---

## Why Fedpunk?

**🚀 Zero-friction setup** - One command installs everything: from compositor to terminal to themes
**⚡ Blazing fast workflow** - Hyprland compositor with optimized keybindings and vim-style navigation
**🎨 Live theme switching** - 11 complete themes that update across all applications instantly
**🐟 Fish-first design** - Modern shell with intelligent completions and powerful scripting
**🖥️ Flexible deployment** - Desktop, laptop, or container modes
**🔄 Layout persistence** - Remembers your window layout preferences across theme changes
**📦 Modular architecture** - Clean separation between terminal and desktop components

---

## Quick Start

### Installation

```bash
chezmoi init --apply https://github.com/hinriksnaer/Fedpunk.git
```

**That's it!** Chezmoi will:
1. Prompt you to select a mode (desktop/laptop/container)
2. Install all packages based on your mode
3. Deploy configurations
4. Set up post-deployment tasks

**Or use explicit mode:**
```bash
FEDPUNK_MODE=desktop chezmoi init --apply https://github.com/hinriksnaer/Fedpunk.git
FEDPUNK_MODE=laptop chezmoi init --apply https://github.com/hinriksnaer/Fedpunk.git
FEDPUNK_MODE=container chezmoi init --apply https://github.com/hinriksnaer/Fedpunk.git
```

### Modes

**Desktop** - Full desktop environment with Hyprland
- Hyprland compositor + Kitty terminal + Rofi launcher
- Neovim, tmux, lazygit, btop, yazi
- Firefox, fonts, audio stack
- 11 beautiful themes with instant switching
- Optional NVIDIA drivers

**Laptop** - Desktop mode with power optimizations
- Same as desktop
- Firmware updates enabled by default
- Power-aware settings

**Container** - Minimal terminal environment
- Terminal tools only (no GUI)
- Perfect for devcontainers, remote servers, WSL
- Fish, Neovim, tmux, lazygit, btop, yazi
- Theme system (terminal apps only)

---

## Themes

**11 carefully curated themes included:**

- **aetheria** - Ethereal purple and blue gradients
- **ayu-mirage** - Warm, muted desert tones
- **catppuccin** - Soothing pastel palette (mocha)
- **catppuccin-latte** - Light mode variant
- **matte-black** - Pure minimalist black
- **nord** - Arctic-inspired cool tones
- **osaka-jade** - Vibrant teal and green
- **ristretto** - Rich espresso browns
- **rose-pine** - Soft rose and pine palette
- **tokyo-night** - Deep blues with neon accents
- **torrentz-hydra** - Bold contrast scheme

### Theme Previews

**Ayu Mirage**
![Ayu Mirage Theme](themes/ayu-mirage/theme.png)

**Tokyo Night**
![Tokyo Night Theme](themes/tokyo-night/preview.png)

**Torrentz Hydra**
![Torrentz Hydra Theme](themes/torrentz-hydra/preview.png)

**Theme Management:**
```fish
fedpunk-theme-list              # List all themes
fedpunk-theme-set <name>        # Switch to specific theme
fedpunk-theme-next              # Cycle forward (Super+Shift+T)
fedpunk-theme-prev              # Cycle backward (Super+Shift+Y)
```

**What themes control:**
- Hyprland - Border colors, gaps, decorations
- Kitty - Terminal colors (live reload)
- Rofi - Launcher appearance
- Mako - Notification styling (live reload)
- Neovim - Editor colorscheme (live reload)
- btop - System monitor colors (live reload)
- Wallpapers - Per-theme backgrounds

---

## What You Get

### Terminal Environment
| Tool | Purpose |
|------|---------|
| **Fish Shell** | Modern shell with intelligent autocompletion and syntax highlighting |
| **Starship** | Fast, customizable prompt with git integration |
| **Neovim** | Vim-based editor with LSP, tree-sitter, and modern plugins |
| **Tmux** | Terminal multiplexer with sensible defaults |
| **Lazygit** | Terminal UI for git with vim bindings |
| **btop** | Beautiful resource monitor |
| **Yazi** | Modern file manager with preview support |
| **ripgrep, fzf** | Fast searching and fuzzy finding |

### Desktop Environment (Desktop/Laptop modes)
| Component | Purpose |
|-----------|---------|
| **Hyprland** | Tiling Wayland compositor with dynamic layouts |
| **Kitty** | GPU-accelerated terminal with ligature support |
| **Rofi** | Application launcher with theme integration |
| **Mako** | Notification daemon with theme support |
| **swaybg** | Wallpaper manager with per-theme backgrounds |
| **Firefox** | Default web browser |

### Hyprland Features
- **Dual layout support** - Switch between dwindle and master layouts (optimized for ultrawide)
- **Vim-based navigation** - H/J/K/L for all window operations
- **Smart modifier scheme** - Consistent Super/Shift/Alt/Ctrl for different operations
- **Workspace management** - Direct switching, cycling, and silent window moves
- **Layout persistence** - Remembers your preferred layout across theme changes
- **No flicker** - Theme changes preserve window positions and layouts

---

## Keybindings

### Navigation (SUPER)
| Key | Action |
|-----|--------|
| `Super+H/J/K/L` | Focus windows (vim-style) |
| `Super+Arrow Keys` | Focus windows (arrows) |
| `Super+1-9` | Switch to workspace |
| `Super+Tab` | Toggle to last workspace |

### Workspace Operations (SUPER+SHIFT)
| Key | Action |
|-----|--------|
| `Super+Shift+H/L` | Cycle workspaces |
| `Super+Shift+1-9` | Move window to workspace |

### Window Manipulation (SUPER+ALT)
| Key | Action |
|-----|--------|
| `Super+Alt+H/J/K/L` | Move window |
| `Super+Alt+R` | Rotate split direction |
| `Super+Alt+Space` | Toggle layout (dwindle ↔ master) |

### Adjustments (SUPER+CTRL)
| Key | Action |
|-----|--------|
| `Super+Ctrl+H/J/K/L` | Resize window |
| `Super+Ctrl+1-9` | Move window silently (no focus) |

### Applications
| Key | Action |
|-----|--------|
| `Super+Return` | Terminal (Kitty) |
| `Super+Space` | Application launcher (Rofi) |
| `Super+B` | Browser (Firefox) |
| `Super+E` | File manager |
| `Super+Shift+B` | Bluetooth manager |

### Window Management
| Key | Action |
|-----|--------|
| `Super+Q` | Close window |
| `Super+V` | Toggle floating |
| `Super+F` | Toggle fullscreen |
| `Super+P` | Pseudo tile |

### Themes
| Key | Action |
|-----|--------|
| `Super+T` | Theme selection menu |
| `Super+Shift+T` | Next theme |
| `Super+Shift+Y` | Previous theme |
| `Super+Shift+R` | Refresh theme |
| `Super+Shift+W` | Next wallpaper |

### Screenshots
| Key | Action |
|-----|--------|
| `Print` | Selection screenshot |
| `Super+Print` | Full screen screenshot |

---

## System Requirements

- **OS:** Fedora Linux 39+
- **Arch:** x86_64
- **RAM:** 4GB minimum, 8GB recommended
- **Storage:** ~2GB free space
- **Optional:** NVIDIA GPU (proprietary drivers available)

---

## Architecture

Fedpunk uses a **chezmoi-first architecture**:

```
1. chezmoi init --apply <repo>
   ├─ .chezmoi.toml.tmpl processes mode selection
   ├─ Loads profiles/<profile>/modes/<mode>.yaml
   └─ Sets up data model

2. run_before_install-packages.fish
   └─ Installs packages based on mode configuration

3. chezmoi apply
   └─ Deploys all dotfiles to ~/.config/

4. run_once_after scripts
   ├─ install-nvim.fish (sets up plugins)
   ├─ install-tmux-plugins.fish (sets up TPM)
   ├─ post-install.fish (package updates)
   ├─ desktop-optimize.fish (desktop only)
   └─ desktop-themes.fish (desktop only)
```

**Mode-driven installation** - Modes defined in simple YAML files with inline comments:
```
profiles/dev/modes/
├── container.yaml  # Minimal terminal environment
├── desktop.yaml    # Full desktop environment
└── laptop.yaml     # Desktop with power optimizations
```

**Installation is idempotent** - Safe to run multiple times. Scripts use `run_once` semantics.

All logs saved to `/tmp/fedpunk-install-*.log` for troubleshooting.

---

## Configuration

### File Locations
All configs use standard XDG paths:
```
~/.config/fish/          # Fish shell
~/.config/hypr/          # Hyprland compositor
~/.config/kitty/         # Kitty terminal
~/.config/nvim/          # Neovim
~/.config/tmux/          # Tmux
~/.config/lazygit/       # Lazygit
~/.config/btop/          # btop
~/.config/rofi/          # Rofi launcher
```

### Customization

**Hyprland keybindings:**
Edit `~/.config/hypr/conf.d/keybinds.conf`

**Window rules:**
Edit `~/.config/hypr/conf.d/windowrules.conf`

**Monitor configuration:**
Edit `~/.config/hypr/monitors.conf`

**Fish functions:**
Add files to `~/.config/fish/functions/`

**Theme creation:**
Copy a theme directory in `~/.local/share/fedpunk/themes/`, customize the files, then switch to it with `fedpunk-theme-set`.

---

## Updates

```bash
# Update dotfiles and re-apply
chezmoi update

# Or manually
chezmoi init --apply --force
```

Chezmoi's `run_once` scripts ensure setup tasks only run when needed.

---

## Troubleshooting

### Fish Not Available After Install
```bash
exec fish
# Or restart your terminal
```

### Hyprland Won't Start
```bash
# Check for driver issues
dmesg | grep -i error

# NVIDIA users - ensure drivers loaded
lsmod | grep nvidia

# Check Hyprland logs
cat /tmp/hypr/$(ls -t /tmp/hypr/ | head -1)/hyprland.log
```

### Audio Not Working
```bash
# Check PipeWire status
systemctl --user status pipewire pipewire-pulse wireplumber

# Restart audio services
systemctl --user restart pipewire pipewire-pulse wireplumber

# List audio devices
wpctl status
```

### Theme Changes Reset Layout
This should not happen as of the latest version. If it does:
```bash
# Check if restore script exists
ls ~/.config/hypr/scripts/restore-layout.fish

# Verify preference file
cat ~/.config/hypr/layout-preference

# Should contain "dwindle" or "master"
```

### Permission Errors
```bash
# Fix SELinux contexts if needed
sudo restorecon -R ~/.config

# Ensure ownership
sudo chown -R $USER:$USER ~/.config
```

---

## Philosophy

Fedpunk is built around core principles:

**Keyboard-first** - Mouse is optional, everything accessible via keybindings
**Consistency** - Similar operations use similar key combinations
**Vim-inspired** - H/J/K/L navigation throughout the system
**Modular** - Components can be installed independently
**Fish-powered** - Leverage Fish's modern shell features
**Aesthetic** - Beautiful themes that work across all applications
**Productive** - Optimized for developer workflows

---

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Test your changes in a VM or container
4. Commit with clear messages
5. Submit a pull request

**Areas for contribution:**
- New themes
- Additional window rules
- Package additions
- Documentation improvements
- Bug fixes

---

## Acknowledgments

- [omarchy](https://github.com/basecamp/omarchy) - Theming framework inspiration
- [JaKooLit's Hyprland-Dots](https://github.com/JaKooLit/Fedora-Hyprland) - Package references
- [Fish Shell Community](https://fishshell.com/) - Amazing modern shell
- [Hyprland](https://hyprland.org/) - Revolutionary Wayland compositor
- The Fedora Project - Solid Linux foundation

---

## License

MIT License - See LICENSE file for details

---

**Fedpunk - Where keyboard-driven workflow meets modern aesthetics**
