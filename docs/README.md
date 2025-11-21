# Fedpunk Documentation Hub

**Complete documentation for Fedpunk - A modular configuration engine for Fedora**

---

## 🎯 Documentation Overview

This directory contains comprehensive documentation for understanding, using, and extending Fedpunk.

**For Users:** Start with [guides/](#-guides)
**For Developers:** Start with [ARCHITECTURE.md](../ARCHITECTURE.md) then [development/](#️-development)
**For AI Assistants:** Read this entire README first for codebase understanding

---

## 📚 Table of Contents

### 🚀 Guides
User-focused tutorials and how-tos:
- **[Installation Guide](guides/installation.md)** - Bootstrap installation and post-install steps
- **[Customization Guide](guides/customization.md)** - Personalizing your Fedpunk setup
- **[Themes Guide](guides/themes.md)** - Using, creating, and managing themes

### 📖 Reference
Technical reference documentation:
- **[Keybindings Reference](reference/keybindings.md)** - Complete keyboard shortcut listing
- **[Scripts Reference](reference/scripts.md)** - All utility scripts and their usage
- **[Configuration Reference](reference/configuration.md)** - Config file locations and structure

### 🛠️ Development
Architecture and contribution docs:
- **[Contributing Guide](development/contributing.md)** - How to contribute to Fedpunk
- **[Roadmap](ROADMAP.md)** - Project status, phases, and future plans

---

## 🏗️ System Architecture (Quick Reference)

Fedpunk is built on a **modular, plugin-based architecture**:

```
┌─────────────────────────────────────────────┐
│  Bootstrap (boot.sh)                        │
│  └─ Install: git, fish, stow, gum          │
├─────────────────────────────────────────────┤
│  Module System (lib/fish/)                  │
│  ├─ YAML parser (toml-parser.fish)          │
│  ├─ Module manager (fedpunk-module.fish)    │
│  ├─ Module resolver (module-resolver.fish)  │
│  └─ UI abstraction (ui.fish)                │
├─────────────────────────────────────────────┤
│  Modules (modules/<package>/)               │
│  ├─ module.yaml - metadata & dependencies   │
│  ├─ config/ - dotfiles (stowed to $HOME)    │
│  └─ scripts/ - lifecycle hooks              │
├─────────────────────────────────────────────┤
│  Profiles (profiles/<name>/)                │
│  ├─ modes/ - module lists per environment   │
│  ├─ plugins/ - profile-specific modules     │
│  └─ fedpunk.toml - extra config             │
└─────────────────────────────────────────────┘
```

**Key Concepts:**
- **Modules** - Self-contained packages with configs, scripts, and dependencies
- **Profiles** - User-specific configurations (dev, work, personal)
- **Modes** - Environment variations (desktop, container, minimal)
- **Plugins** - Profile-scoped modules for custom tools
- **Stow** - Symlink-based config deployment (instant, live updates)

**Read More:** [../ARCHITECTURE.md](../ARCHITECTURE.md)

---

## 🎓 Learning Paths

### Path 1: New User (Just Want It Working)

1. **Install Fedpunk**
   - Read: [guides/installation.md](guides/installation.md)
   - Run: `curl -fsSL https://raw.githubusercontent.com/hinriksnaer/Fedpunk/main/boot.sh | bash`
   - Follow: Interactive prompts

2. **Learn Keybindings**
   - Read: [reference/keybindings.md](reference/keybindings.md)
   - Practice: `Super+Space` (launcher), `Super+H/J/K/L` (navigation)

3. **Try Themes**
   - Read: [guides/themes.md](guides/themes.md)
   - Try: `Super+Shift+T` (next theme), `fedpunk-theme-list`

4. **Basic Customization**
   - Read: [guides/customization.md](guides/customization.md)
   - Edit: `profiles/dev/modes/desktop.yaml` to add/remove modules

### Path 2: Power User (Want to Customize)

1. **Understand Module System**
   - Read: [../ARCHITECTURE.md](../ARCHITECTURE.md) - Module System section
   - Explore: `modules/` directory structure
   - Try: `fedpunk module info fish`

2. **Create Custom Modules**
   - Read: [development/contributing.md](development/contributing.md) - Module Creation
   - Copy: Existing module as template
   - Deploy: `fedpunk module deploy mymodule`

3. **Build Profile Plugins**
   - Read: [../profiles/dev/plugins/README.md](../profiles/dev/plugins/README.md)
   - Create: `profiles/dev/plugins/my-tools/`
   - Add to mode: Edit `profiles/dev/modes/desktop.yaml`

4. **Create Custom Themes**
   - Read: [guides/themes.md](guides/themes.md) - Theme Creation
   - Copy: `themes/nord/` as base
   - Customize: Colors, wallpapers, styles

### Path 3: Developer/Contributor (Want to Extend)

1. **Architecture Deep Dive**
   - Read: [../ARCHITECTURE.md](../ARCHITECTURE.md)
   - Read: [ROADMAP.md](ROADMAP.md)
   - Explore: `lib/fish/` infrastructure

2. **Module Development**
   - Read: Module yaml schema in ARCHITECTURE.md
   - Study: Existing modules (`modules/fish/`, `modules/neovim/`)
   - Create: New module with dependencies

3. **Fish Infrastructure**
   - Study: `lib/fish/fedpunk-module.fish` - module management
   - Study: `lib/fish/module-resolver.fish` - plugin path resolution
   - Study: `lib/fish/toml-parser.fish` - YAML parsing

4. **Contribute**
   - Read: [development/contributing.md](development/contributing.md)
   - Fork: Repository
   - Submit: Pull request

### Path 4: AI Assistant (Understanding Codebase)

1. **Core Concepts** (Read in order)
   - **[../ARCHITECTURE.md](../ARCHITECTURE.md)** - Source of truth for system design
   - **[../README.md](../README.md)** - User-facing features and overview
   - **[ROADMAP.md](ROADMAP.md)** - Current status and migration history

2. **Module System** (Critical for understanding deployments)
   - **Structure:** `modules/<name>/module.yaml` + `config/` + `scripts/`
   - **Deployment:** `fedpunk module deploy <name>` handles deps, packages, configs
   - **Dependencies:** Declared in `module.yaml`, auto-resolved recursively
   - **Lifecycle:** install → before → stow → after (scripts in `scripts/`)
   - **No Priority Field:** Modules do NOT have priority (common mistake)

3. **Profile System** (How users customize)
   - **Profiles:** Located in `profiles/<name>/`
   - **Modes:** `modes/*.yaml` lists modules for desktop/container/etc
   - **Plugins:** `plugins/<name>/` are profile-scoped modules
   - **Resolution:** `fedpunk module deploy plugins/foo` resolves to active profile

4. **Key Files for Code Changes**
   - **Module Management:** `lib/fish/fedpunk-module.fish`
   - **Path Resolution:** `lib/fish/module-resolver.fish`
   - **YAML Parsing:** `lib/fish/toml-parser.fish`
   - **Installation:** `install.fish` (orchestrator)
   - **Bootstrap:** `boot.sh` (minimal setup)

5. **Common Patterns**
   - **Configs via Stow:** Edit in module, symlinked to $HOME (live updates)
   - **Theme Switching:** Writes to gitignored files, reloads services via SIGUSR1/2
   - **Dependency Resolution:** Recursive with duplicate prevention
   - **Profile Activation:** Creates `.active-config` symlink

6. **Important Constraints**
   - **Never add "priority" to modules** (user explicitly requested removal)
   - **Use module-resolve-path for all module lookups** (handles plugins)
   - **Configs are live** (Stow symlinks, not copies)
   - **Lifecycle scripts are optional** (check before running)
   - **Fish shell preferred** (but Bash works for scripts)

---

## 🗂️ Directory Structure

```
docs/
├── README.md                    ← You are here
│
├── guides/                      ← User tutorials
│   ├── installation.md          ← How to install (bootstrap, modes)
│   ├── customization.md         ← How to customize (profiles, plugins)
│   └── themes.md                ← Theme system (usage, creation)
│
├── reference/                   ← Technical reference
│   ├── keybindings.md           ← All keyboard shortcuts
│   ├── scripts.md               ← Utility script documentation
│   └── configuration.md         ← Config file structure
│
├── development/                 ← Developer documentation
│   └── contributing.md          ← How to contribute
│
├── design/                      ← Design documents (historical)
│   └── DOTFILE_MODULES.md       ← Original module system design
│
└── ROADMAP.md                   ← Project phases and status
```

---

## 🎯 Quick Start Guides

### For First-Time Users

```bash
# 1. Install
curl -fsSL https://raw.githubusercontent.com/hinriksnaer/Fedpunk/main/boot.sh | bash

# 2. Choose profile and mode (interactive)
# Profile: dev
# Mode: desktop (or container for minimal)

# 3. After installation, log into Hyprland
# Press Super+Space to open launcher
# Press Super+Shift+T to try different themes
```

### For Customizers

```bash
# View active modules
cat ~/.local/share/fedpunk/profiles/dev/modes/desktop.yaml

# Add a module to your profile
echo "  - bitwarden" >> profiles/dev/modes/desktop.yaml
fedpunk module deploy bitwarden

# Create a custom plugin
mkdir -p profiles/dev/plugins/my-tools
# Add module.yaml and config/
fedpunk module deploy plugins/my-tools
```

### For Developers

```fish
# List all modules
fedpunk module list

# Inspect module details
fedpunk module info neovim

# Deploy with dependencies
fedpunk module deploy hyprland  # Auto-deploys fonts, kitty

# Test in container
podman run -it fedora:40
git clone https://github.com/hinriksnaer/Fedpunk.git ~/.local/share/fedpunk
cd ~/.local/share/fedpunk
fish install.fish --terminal-only --non-interactive
```

---

## 📋 System Requirements

- **OS:** Fedora Linux 39+ (x86_64)
- **RAM:** 4GB min, 8GB recommended (desktop mode)
- **Storage:** ~2GB free space
- **Network:** Internet connection for installation
- **Optional:** NVIDIA GPU (proprietary drivers supported)

---

## 🔑 Key Features

### Module System
- ✅ Self-contained packages with metadata, configs, and scripts
- ✅ Automatic dependency resolution (recursive, no duplicates)
- ✅ Lifecycle hooks (install, before, after, update)
- ✅ Package management (DNF, Cargo, NPM, Flatpak)
- ✅ GNU Stow integration (instant deployment via symlinks)

### Profile System
- ✅ Multiple profiles (dev, work, personal)
- ✅ Mode-based deployment (desktop, container, minimal)
- ✅ Plugin framework for profile-specific modules
- ✅ Gitignored customizations (no merge conflicts)
- ✅ Profile switching without reinstallation

### Theme System
- ✅ 11 curated themes with live switching
- ✅ Coordinated across all apps (terminal, editor, bar, launcher)
- ✅ Per-theme wallpapers
- ✅ Layout persistence (themes don't reset window layout)
- ✅ Easy custom theme creation

### Developer Experience
- ✅ Keyboard-first workflow (vim-style navigation)
- ✅ Modern tools (Fish, Neovim, Tmux, Lazygit)
- ✅ LSP support in Neovim
- ✅ Bitwarden CLI integration
- ✅ GitHub CLI integration

---

## 🆘 Troubleshooting

### Installation Issues

**Problem:** Bootstrap fails to download
```bash
# Check network connectivity
ping -c 3 github.com

# Manual clone
git clone https://github.com/hinriksnaer/Fedpunk.git ~/.local/share/fedpunk
cd ~/.local/share/fedpunk
fish install.fish
```

**Problem:** Module deployment fails
```bash
# Check logs
tail -100 /tmp/fedpunk-install-*.log

# Deploy specific module
fedpunk module deploy <module-name>

# Check module info
fedpunk module info <module-name>
```

### Configuration Issues

**Problem:** Changes not appearing
```bash
# Configs are symlinks - changes should be instant
# Reload services:
fedpunk-reload

# Or reload specific service:
hyprctl reload          # Hyprland
killall -SIGUSR2 waybar # Waybar
exec fish               # Shell
```

**Problem:** Theme changes not working
```fish
# Check theme exists
fedpunk-theme-list

# Set theme manually
fedpunk-theme-set <theme-name>

# Check theme files
ls ~/.local/share/fedpunk/themes/<theme-name>/
```

### Module System Issues

**Problem:** Plugin not found
```bash
# Plugins require active profile
ls ~/.local/share/fedpunk/.active-config  # Should be symlink

# Check plugin exists
ls ~/.local/share/fedpunk/profiles/dev/plugins/

# Deploy with full path
fedpunk module deploy plugins/<plugin-name>
```

**Problem:** Dependency resolution fails
```bash
# Check module dependencies
cat modules/<name>/module.yaml

# Deploy dependencies manually
fedpunk module deploy <dependency>
fedpunk module deploy <original-module>
```

---

## 📊 Documentation Status

- ✅ **Architecture** - Complete ([ARCHITECTURE.md](../ARCHITECTURE.md))
- ✅ **Installation** - Complete ([guides/installation.md](guides/installation.md))
- ✅ **Keybindings** - Complete ([reference/keybindings.md](reference/keybindings.md))
- ✅ **Themes** - Complete ([guides/themes.md](guides/themes.md))
- ✅ **Contributing** - Complete ([development/contributing.md](development/contributing.md))
- ⚠️ **Customization** - Needs update for v2.0 module system
- ⚠️ **Configuration Reference** - Needs expansion
- ⚠️ **Scripts Reference** - Needs completion

---

## 🤝 Contributing to Documentation

Documentation improvements are always welcome!

**Areas needing help:**
- Screenshots and visual examples
- Video tutorials
- More troubleshooting scenarios
- Theme creation tutorial expansion
- Module creation examples
- Translation to other languages

**How to contribute:**
1. Fork repository
2. Edit docs in `docs/` directory
3. Test markdown rendering
4. Submit pull request

See [development/contributing.md](development/contributing.md)

---

## 📜 License

MIT License - See [LICENSE](../LICENSE) file for details

---

## 🔗 Quick Links

- **Main README:** [../README.md](../README.md)
- **Architecture:** [../ARCHITECTURE.md](../ARCHITECTURE.md)
- **Roadmap:** [ROADMAP.md](ROADMAP.md)
- **GitHub:** [hinriksnaer/Fedpunk](https://github.com/hinriksnaer/Fedpunk)

---

**Documentation Version:** 2.0
**Last Updated:** 2025-01-20
**Fedpunk Version:** v2.0 (Modular Architecture)
