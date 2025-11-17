# Fedpunk Documentation

Complete documentation for Fedpunk - a modern, keyboard-driven Fedora development environment.

---

## 📚 Table of Contents

### 🚀 Getting Started
- **[Installation Guide](guides/installation.md)** - Quick start and post-installation steps
- **[Customization Guide](guides/customization.md)** - Make Fedpunk your own
- **[Themes Guide](guides/themes.md)** - Using and creating themes

### 📖 Reference
- **[Scripts Reference](reference/scripts.md)** - All bin scripts and their usage
- **[Keybindings Reference](reference/keybindings.md)** - Complete keyboard shortcuts
- **[Configuration Reference](reference/configuration.md)** - Config file locations and structure

### 🛠️ Development
- **[Validation Report](development/VALIDATION_REPORT.md)** - Complete codebase validation
- **[Simplification Summary](development/SIMPLIFICATION_SUMMARY.md)** - Recent architecture changes
- **[Devcontainer Guide](development/devcontainer.md)** - Testing in containers
- **[Contributing Guide](development/contributing.md)** - How to contribute

---

## 🎯 Quick Links

### First Time Setup
1. Read the [Installation Guide](guides/installation.md)
2. Choose your installation mode (desktop or terminal-only)
3. Run the bootstrap script
4. Follow [post-installation steps](guides/installation.md#post-installation)

### Customization
1. Read the [Customization Guide](guides/customization.md)
2. Everything goes in `profiles/dev/` directory
3. Available customizations:
   - Personal themes → `profiles/dev/themes/`
   - Personal scripts → `profiles/dev/scripts/`
   - Fish config → `profiles/dev/config.fish`
   - Hyprland keys → `profiles/dev/keybinds.conf`
   - Dotfiles → `profiles/dev/config/` (via Stow)

### Themes
1. Browse available themes: `fedpunk-theme-list`
2. Preview themes in `themes/*/preview.png`
3. Set theme: `fedpunk-theme-set <name>`
4. Create custom theme: See [Themes Guide](guides/themes.md)

---

## 📂 Documentation Structure

```
docs/
├── README.md                          ← You are here
│
├── guides/                            ← User guides
│   ├── installation.md                ← How to install
│   ├── customization.md               ← How to customize
│   └── themes.md                      ← Themes system
│
├── reference/                         ← Technical reference
│   ├── scripts.md                     ← Script documentation
│   ├── keybindings.md                 ← Keyboard shortcuts
│   └── configuration.md               ← Config file reference
│
└── development/                       ← Developer docs
    ├── VALIDATION_REPORT.md           ← Validation results
    ├── SIMPLIFICATION_SUMMARY.md      ← Architecture changes
    ├── devcontainer.md                ← Container testing
    └── contributing.md                ← Contribution guide
```

---

## 🎨 What is Fedpunk?

Fedpunk is a complete development environment for Fedora Linux featuring:

- **Hyprland Compositor** - Beautiful, fast Wayland tiling window manager
- **Modern Terminal Stack** - Fish shell, Neovim, Tmux, Lazygit
- **Live Theme System** - Switch themes instantly across all apps
- **Keyboard-First Workflow** - Vim-style navigation everywhere
- **Two Installation Modes:**
  - **Desktop Mode** - Full Hyprland environment
  - **Terminal Mode** - CLI tools only (servers, containers)

---

## 🔑 Key Features

### Installation
- ✅ One-command bootstrap installation
- ✅ Re-run safe (can update existing install)
- ✅ Comprehensive logging
- ✅ Optional components (NVIDIA, Bluetooth, etc.)

### Themes
- ✅ 12 built-in themes with instant switching
- ✅ Complete color coordination (terminal, editor, bar, launcher)
- ✅ Per-theme wallpapers
- ✅ Easy custom theme creation

### Customization
- ✅ Single `profiles/dev/` directory for all personalizations
- ✅ Gitignored (no merge conflicts on updates)
- ✅ Override any default configuration
- ✅ Stow-based dotfile management

### Developer-Friendly
- ✅ Fish shell with intelligent completions
- ✅ Neovim with LSP, autocompletion, syntax highlighting
- ✅ Tmux with plugin manager
- ✅ Lazygit for git workflows
- ✅ Modern CLI tools (ripgrep, fzf, bat, eza)

---

## 🚦 Installation Quick Start

### Desktop Installation (Full Hyprland)
```bash
curl -fsSL https://raw.githubusercontent.com/hinriksnaer/Fedpunk/main/boot.sh | bash
```

### Terminal-Only Installation (Servers, Containers)
```bash
curl -fsSL https://raw.githubusercontent.com/hinriksnaer/Fedpunk/main/boot-terminal.sh | bash
```

### From Cloned Repository
```bash
git clone https://github.com/hinriksnaer/Fedpunk.git ~/.local/share/fedpunk
cd ~/.local/share/fedpunk
fish install.fish                    # Full desktop
# OR
fish install.fish --terminal-only    # Terminal-only
```

See [Installation Guide](guides/installation.md) for detailed steps.

---

## 📋 System Requirements

- **OS:** Fedora Linux 39+
- **Architecture:** x86_64
- **RAM:** 4GB minimum, 8GB recommended
- **Storage:** ~2GB free space
- **Network:** Internet connection for installation
- **Optional:** NVIDIA GPU (proprietary drivers available)

---

## 🎓 Learning Path

### Day 1: Installation
1. Read [Installation Guide](guides/installation.md)
2. Run bootstrap script
3. Log into Hyprland
4. Explore with `Super+Space` (launcher)

### Day 2: Keybindings
1. Read [Keybindings Reference](reference/keybindings.md)
2. Practice window navigation (`Super+H/J/K/L`)
3. Practice workspace switching (`Super+1-9`)
4. Try theme switching (`Super+Shift+T`)

### Day 3: Customization
1. Read [Customization Guide](guides/customization.md)
2. Add personal aliases to `profiles/dev/config.fish`
3. Create custom keybindings in `profiles/dev/keybinds.conf`
4. Explore theme creation

### Week 1: Mastery
1. Create your own theme
2. Set up custom scripts
3. Configure dotfiles via Stow
4. Fine-tune your workflow

---

## 🆘 Getting Help

### Documentation
- **Installation issues?** → [Installation Guide](guides/installation.md)
- **Customization questions?** → [Customization Guide](guides/customization.md)
- **Theme problems?** → [Themes Guide](guides/themes.md)
- **Script usage?** → [Scripts Reference](reference/scripts.md)

### Logs
- Installation logs: `/tmp/fedpunk-install-*.log`
- Check with: `cat /tmp/fedpunk-install-*.log | less`

### Debugging
- Check Hyprland logs: `~/.local/share/hyprland/hyprland.log`
- Run startup diagnostics: `Super+Shift+D` (desktop mode)
- Test Fish config: `fish --debug`

### Community
- GitHub Issues: Report bugs and request features
- Discussions: Ask questions and share setups

---

## 🎯 Common Tasks

### Change Theme
```bash
fedpunk-theme-list              # List available themes
fedpunk-theme-set tokyo-night   # Set theme
```

### Add Personal Alias
```bash
echo "alias gs='git status'" >> profiles/dev/config.fish
exec fish  # Reload shell
```

### Create Custom Theme
```bash
cp -r themes/nord profiles/dev/themes/my-theme
vim profiles/dev/themes/my-theme/kitty.conf
fedpunk-theme-set my-theme
```

### Add Custom Keybinding
```bash
echo "bind = Super, M, exec, spotify" >> profiles/dev/keybinds.conf
hyprctl reload  # Reload Hyprland
```

### Manage Dotfiles
```bash
mkdir -p profiles/dev/config/git
vim profiles/dev/config/git/.gitconfig
fedpunk-stow-profile git  # Deploy with Stow
```

---

## 🔄 Updating Fedpunk

```bash
cd ~/.local/share/fedpunk
git pull
git submodule update --init --recursive
fish install.fish  # Re-run installer (safe)
```

The installer is re-run safe and will:
- Detect existing installations
- Only update what's needed
- Preserve your `profiles/dev/` directory

---

## 📊 Project Status

- ✅ **Validated** - All components tested
- ✅ **Documented** - Comprehensive guides
- ✅ **Production-Ready** - Ready for daily use
- ✅ **Actively Maintained** - Regular updates

See [Validation Report](development/VALIDATION_REPORT.md) for detailed analysis.

---

## 🤝 Contributing

Interested in contributing? See [Contributing Guide](development/contributing.md)

Areas where contributions are welcome:
- New themes
- Bug fixes
- Documentation improvements
- Feature requests
- Testing on different hardware

---

## 📜 License

See repository LICENSE file for details.

---

**Happy Hacking! 🚀**
