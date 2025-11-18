# Fedpunk

**A modern, keyboard-driven Fedora development environment with Hyprland Wayland compositor**

Fedpunk transforms Fedora into a productivity-focused workspace featuring tiling window management, seamless theming, and a curated set of development tools—all driven by Fish shell and designed for developers who value efficiency and aesthetics.

---

## Why Fedpunk?

**🚀 Zero-friction setup** - One command installs everything: from compositor to terminal to themes
**⚡ Blazing fast workflow** - Hyprland compositor with optimized keybindings and vim-style navigation
**🎨 Live theme switching** - 11 complete themes that update across all applications instantly
**🐟 Fish-first design** - Modern shell with intelligent completions and powerful scripting
**🖥️ Flexible deployment** - Full desktop or terminal-only for servers and containers
**🔄 Layout persistence** - Remembers your window layout preferences across theme changes
**📦 Modular architecture** - Clean separation between terminal and desktop components

---

## 📚 Documentation

**Complete documentation available in [`docs/`](docs/)**

- **[Architecture Guide](ARCHITECTURE.md)** - System design and philosophy ⭐ **Start Here**
- **[Installation Guide](docs/guides/installation.md)** - Detailed setup instructions
- **[Customization Guide](docs/guides/customization.md)** - Make it your own
- **[Themes Guide](docs/guides/themes.md)** - Theme system and creation
- **[Keybindings Reference](docs/reference/keybindings.md)** - All keyboard shortcuts
- **[Configuration Reference](docs/reference/configuration.md)** - Config files and structure
- **[Scripts Reference](docs/reference/scripts.md)** - Utility scripts documentation
- **[Contributing Guide](docs/development/contributing.md)** - How to contribute

---

## Quick Start

### Full Desktop Install (Hyprland + Terminal)

```bash
curl -fsSL https://raw.githubusercontent.com/hinriksnaer/Fedpunk/main/boot.sh | bash
```

**Installs:**
- Hyprland compositor with optimized window management
- Kitty terminal with GPU acceleration
- Neovim, tmux, lazygit, btop
- 11 beautiful themes with instant switching
- NVIDIA drivers (optional, interactive prompt)

### Terminal-Only Install (Servers/Containers)

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/hinriksnaer/Fedpunk/main/boot-terminal.sh)
```

**Installs:**
- Fish shell with modern tooling
- Neovim with LSP and plugins
- tmux, lazygit, btop
- Theme system (terminal apps only)
- Skips all desktop components

Perfect for devcontainers, remote servers, or when you already have a compositor.

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
| **ripgrep, fzf** | Fast searching and fuzzy finding |

### Desktop Environment
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

## Installation Details

### What Gets Installed

**Core System:**
- Fish shell with Starship prompt
- Development tools (git, ripgrep, fzf, fd)
- PipeWire audio stack
- Desktop portals (file pickers, authentication)

**Terminal Tools:**
- Neovim with LSP support and modern plugins
- Tmux with plugin manager
- Lazygit for git workflow
- btop for system monitoring

**Desktop (unless --terminal-only):**
- Hyprland compositor with dependencies
- Kitty terminal emulator
- Rofi application launcher
- Mako notification daemon
- Firefox browser
- Font packages (JetBrainsMono, Nerd Fonts)
- Optional: NVIDIA drivers with Wayland support

### Architecture

Fedpunk uses a **modular installation system**:

```
1. Preflight (install/preflight/)
   - Cargo/Rust toolchain
   - Fish shell setup
   - Essential development tools
   - System repository configuration

2. Terminal Components (install/terminal/)
   - btop, neovim, tmux, lazygit
   - Configs deployed via chezmoi

3. Desktop Components (install/desktop/)
   - hyprland, kitty, rofi
   - Audio, fonts, bluetooth
   - Optional NVIDIA drivers

4. Post-Install (install/post-install/)
   - Theme system initialization
   - Final configurations
```

**Installation is re-run safe** - gracefully handles already-installed components.

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
cd ~/.local/share/fedpunk
git pull
fish install.fish  # Re-run installation (safe to repeat)
```

The installer detects existing components and only updates what's needed.

---

## Advanced Usage

### Terminal-Only Deployment

Perfect for:
- Devcontainers
- Remote servers
- WSL environments
- Existing desktop setups

```bash
# During install
fish install.fish --terminal-only --non-interactive

# Or use the boot script
bash <(curl -fsSL https://raw.githubusercontent.com/hinriksnaer/Fedpunk/main/boot-terminal.sh)
```

### Layout Management

Fedpunk includes intelligent layout persistence:

```bash
# Toggle between dwindle (standard tiling) and master (ultrawide optimized)
Super+Alt+Space

# Your choice is remembered across:
# - Theme changes
# - Hyprland reloads
# - System restarts
```

The system writes your preference to `~/.config/hypr/layout-preference` and automatically restores it.

### Custom Packages

Add packages to the appropriate module:

**Terminal packages:**
```fish
# install/terminal/packaging/yourpackage.fish
function install-yourpackage
    sudo dnf install -y yourpackage
end
```

**Desktop packages:**
```fish
# install/desktop/packaging/yourpackage.fish
function install-yourpackage
    sudo dnf install -y yourpackage
end
```

Then call it from the main install sequence.

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

## Known Issues (v0.1.0)

The following issues are known in this release and will be addressed in future versions:

**Installation:**
- **Yazi file manager**: Installation may fail if `unzip` package is missing; cargo build can fail on minimal container systems
- **Neovim configuration**: Git submodule deployment may require manual initialization with `git submodule update --init --recursive`
- **Final chezmoi deployment**: May fail in some edge cases during installation; investigating root cause

**Profile System:**
- **Profile config deployment**: Profile-specific config deployment not fully implemented (see `fedpunk-activate-profile:236`)
- **Stow migration**: Users upgrading from pre-0.1.0 need to migrate from Stow-based profiles (see CHANGELOG.md migration guide)

**Desktop:**
- **Theme symlink creation**: First-time theme setup may require manual `fedpunk theme set <theme-name>`
- **Profile keybindings**: Profile-specific keybinds.conf inclusion pending full implementation

**Workarounds:**
```bash
# Install yazi dependencies manually if needed
sudo dnf install -y unzip

# Initialize Neovim submodules if needed
cd ~/.local/share/fedpunk
git submodule update --init --recursive

# Manually set theme on first install
fedpunk theme set ayu-mirage
```

Installation logs are saved to `/tmp/fedpunk-install-*.log` for troubleshooting.

---

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Test your changes: `fish install.fish`
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
