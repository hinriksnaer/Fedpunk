# Default Profile

**General-purpose configuration suitable for most Fedpunk users**

---

## 📋 Overview

The `default` profile provides a clean, opinionated setup for Fedora Linux users who want:
- Modern development tools without heavy customization
- Hyprland desktop environment (desktop mode)
- Terminal-only option (container mode)
- No hardware-specific configurations

**This profile is ideal for:**
- New Fedpunk users
- General development workflows
- Testing Fedpunk on different hardware
- Building your own customizations from a solid foundation

---

## 🎭 Modes

### Desktop Mode (`desktop.yaml`)

**General-purpose desktop environment:**

**Core System:**
- `essentials` - Core utilities (ripgrep, fzf, fd, bat, eza, etc.)
- `languages` - Development languages (Rust, Node.js, Python, Go)

**Terminal Tools:**
- `neovim` - Modern Vim-based editor with LSP support
- `tmux` - Terminal multiplexer
- `lazygit` - Terminal UI for Git
- `btop` - Beautiful system resource monitor
- `yazi` - Fast terminal file manager with theming

**Development Tools:**
- `gh` - GitHub CLI for repository management
- `bitwarden` - Password manager CLI with vault integration
- `claude` - Claude Code integration for AI-assisted development

**Desktop Environment:**
- `fonts` - JetBrainsMono Nerd Font and system fonts
- `kitty` - GPU-accelerated terminal emulator
- `rofi` - Application launcher
- `hyprland` - Wayland tiling compositor
- `firefox` - Web browser
- `bluetui` - Bluetooth device manager (TUI)

**What's NOT Included (vs dev profile):**
- ❌ NVIDIA drivers (hardware-specific)
- ❌ Audio/multimedia packages (can be added as needed)
- ❌ Personal entertainment apps (Spotify, Discord)
- ❌ Hardware-specific configurations (fan control)
- ❌ Monitor configurations (ultrawide-specific settings)

**Deploy:**
```bash
fish install.fish --profile default --mode desktop
```

### Container Mode (`container.yaml`)

**Minimal terminal-only setup for devcontainers and servers:**

**Includes:**
- `essentials` - Core CLI utilities
- `neovim` - Editor with full plugin suite
- `tmux` - Terminal multiplexer
- `lazygit` - Git TUI
- `yazi` - File manager
- `gh` - GitHub CLI
- `bitwarden` - Password manager CLI
- `claude` - Claude Code integration

**Deploy:**
```bash
fish install.fish --profile default --mode container
```

---

## 🔌 Extending the Default Profile

### Adding Optional Modules

The default profile is intentionally minimal. Add modules based on your needs:

**Audio Support:**
```bash
fedpunk module deploy audio
```

**NVIDIA GPU Support:**
```bash
fedpunk module deploy nvidia
```

**Vertex AI for Claude:**
```bash
fedpunk module deploy vertex-ai
```

**Multimedia Tools:**
```bash
fedpunk module deploy multimedia
```

### Creating Profile Plugins

Add profile-specific tools without modifying the base profile:

```bash
# Create a plugin directory
mkdir -p profiles/default/plugins/my-tools

# Add module.yaml and config/
profiles/default/plugins/my-tools/
├── module.yaml
└── config/
    └── .config/my-tool/
```

**Add to mode:**
```yaml
# profiles/default/modes/desktop.yaml
modules:
  - essentials
  - neovim
  # ... other modules ...
  - plugins/my-tools  # Your custom plugin
```

See [`plugins/README.md`](plugins/README.md) for detailed plugin creation guide.

---

## 🎨 Themes

The default profile includes all 12 Fedpunk themes with instant switching:

```fish
fedpunk-theme-list              # List all available themes
fedpunk-theme-set catppuccin    # Switch to specific theme
fedpunk-theme-next              # Cycle to next theme
```

**Keyboard shortcuts (desktop mode):**
- `Super+T` - Theme selection menu
- `Super+Shift+T` - Next theme
- `Super+Shift+Y` - Previous theme

---

## ⌨️ Keybindings

The default profile uses Fedpunk's standard keyboard-driven workflow:

**Window Navigation:**
- `Super+H/J/K/L` - Focus window (vim-style)
- `Super+1-9` - Switch to workspace

**Window Management:**
- `Super+Shift+H/L` - Previous/next workspace
- `Super+Alt+H/J/K/L` - Move window
- `Super+Ctrl+H/J/K/L` - Resize window

**Applications:**
- `Super+Return` - Terminal (Kitty)
- `Super+Space` - Application launcher (Rofi)
- `Super+B` - Browser (Firefox)
- `Super+Q` - Close window

See [`docs/reference/keybindings.md`](../../docs/reference/keybindings.md) for complete reference.

---

## 🔄 Switching from Dev Profile

If you're currently using the `dev` profile and want to switch to `default`:

```bash
# Re-run installer with default profile
fish install.fish --profile default --mode desktop

# The installer will update module deployments automatically
```

**Note:** Your existing configurations will be updated via symlinks. The switch is safe and reversible.

---

## 🆚 Default vs Dev Profile

| Feature | Default | Dev |
|---------|---------|-----|
| **Core Tools** | ✅ Full suite | ✅ Full suite |
| **Desktop Environment** | ✅ Hyprland + apps | ✅ Hyprland + apps |
| **NVIDIA Drivers** | ❌ Not included | ✅ Included |
| **Audio/Multimedia** | ❌ Not included | ✅ Included |
| **Entertainment** | ❌ Not included | ✅ Spotify, Discord |
| **Hardware Config** | ❌ Generic | ✅ Fan control, ultrawide monitor |
| **Target Users** | 🎯 General users | 🎯 Personal development |
| **Customization** | 🔓 Clean slate | 🔒 Pre-configured |

---

## 📝 Customization Guide

### Adding Your Own Modules

1. **Identify what you need:**
   - Browse available modules: `fedpunk module list`
   - Check module details: `fedpunk module info <name>`

2. **Deploy individual modules:**
   ```bash
   fedpunk module deploy <module-name>
   ```

3. **Add to your mode permanently:**
   Edit `profiles/default/modes/desktop.yaml` and add the module to the list

4. **Create custom modules:**
   See [`docs/development/contributing.md`](../../docs/development/contributing.md)

### Monitor Configuration

Unlike the `dev` profile, `default` doesn't include monitor-specific configuration. To add yours:

```bash
# Create monitor config
cat > profiles/default/monitors.conf << EOF
# Your Hyprland monitor configuration
monitor=DP-1,1920x1080@144,0x0,1
EOF

# Hyprland will automatically load this if it exists
```

---

## 🚀 Getting Started

1. **Install Fedpunk with default profile:**
   ```bash
   curl -fsSL https://raw.githubusercontent.com/hinriksnaer/Fedpunk/main/boot.sh | bash
   # Choose "default" profile when prompted
   ```

2. **Explore installed tools:**
   ```bash
   # Modern shell with completions
   exec fish

   # Open Neovim
   nvim

   # Try lazygit
   lazygit

   # Browse files with yazi
   yazi
   ```

3. **Switch themes:**
   ```bash
   fedpunk-theme-list
   fedpunk-theme-set tokyo-night
   ```

4. **Add modules as needed:**
   ```bash
   # NVIDIA users
   fedpunk module deploy nvidia

   # Audio support
   fedpunk module deploy audio
   ```

---

## 📚 Documentation

- **Installation:** [`docs/guides/installation.md`](../../docs/guides/installation.md)
- **Customization:** [`docs/guides/customization.md`](../../docs/guides/customization.md)
- **Themes:** [`docs/guides/themes.md`](../../docs/guides/themes.md)
- **Keybindings:** [`docs/reference/keybindings.md`](../../docs/reference/keybindings.md)
- **Module System:** [`docs/design/DOTFILE_MODULES.md`](../../docs/design/DOTFILE_MODULES.md)

---

## 🤝 Contributing

Found something that should be in the default profile? Open an issue or PR!

**Guidelines for default profile:**
- Must work on any Fedora system (no hardware dependencies)
- Should appeal to 80% of users
- Keep it minimal - users can always add more
- Document what's excluded and why

---

**The `default` profile is your starting point for building the perfect Fedpunk setup.**
