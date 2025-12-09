# Fedpunk

<div align="center">

<pre style="color: #ee0000; font-weight: bold;">
███████╗███████╗██████╗ ██████╗ ██╗   ██╗███╗   ██╗██╗  ██╗
██╔════╝██╔════╝██╔══██╗██╔══██╗██║   ██║████╗  ██║██║ ██╔╝
█████╗  █████╗  ██║  ██║██████╔╝██║   ██║██╔██╗ ██║█████╔╝
██╔══╝  ██╔══╝  ██║  ██║██╔═══╝ ██║   ██║██║╚██╗██║██╔═██╗
██║     ███████╗██████╔╝██║     ╚██████╔╝██║ ╚████║██║  ██╗
╚═╝     ╚══════╝╚═════╝ ╚═╝      ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═╝
</pre>

### A Modular Configuration Engine for Fedora

**Not just dotfiles. A complete system orchestration framework.**

*Build your perfect development environment with modular packages, profile-based customization, and intelligent dependency resolution*

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Fedora](https://img.shields.io/badge/Fedora-39+-blue.svg)](https://getfedora.org/)
[![Fish Shell](https://img.shields.io/badge/Shell-Fish-green.svg)](https://fishshell.com/)

[Quick Start](#quick-start) • [Architecture](#architecture) • [Features](#why-fedpunk) • [Themes](#themes) • [Documentation](#documentation)

---

## See It In Action

[![Watch the demo](https://i.vimeocdn.com/video/2087154164-42913e946a9b98dc351ec6bb62ab47f5e651606ce934b35e2038324747d7cbfd-d_640)](https://vimeo.com/1140211449)

*Click to watch: Live theme switching, keyboard-driven workflow, and seamless module deployment*

### [**Watch Full Demo on Vimeo**](https://vimeo.com/1140211449)

</div>

---

## What is Fedpunk?

Fedpunk is a **next-generation configuration management system** that transforms Fedora into a productivity powerhouse. Unlike traditional dotfile managers, Fedpunk provides:

- **Modular Architecture** - Self-contained packages with automatic dependency resolution
- **Profile System** - Multiple environments (desktop/container/work) from a single codebase
- **Plugin Framework** - Extend profiles with custom modules scoped to your workflow
- **Lifecycle Hooks** - Execute scripts at any stage of deployment (before/after/install/update)
- **GNU Stow Integration** - Instant config deployment via symlinks (no generation step)
- **Live Theme Engine** - 12 themes that update across all apps without reloading
- **Fish-First** - Modern shell with intelligent completions and powerful scripting

**The result?** A keyboard-driven Hyprland environment with vim-style navigation, seamless theming, and a curated development toolset—all deployable in one command.

---

## Architecture Highlights

**v0.3.0** features a revolutionary modular system:

### Module System
Every package is self-contained with metadata, dependencies, and lifecycle hooks. Modules can be built-in, local, or external (git URLs):

```fish
modules/neovim/
├── module.yaml          # Metadata, dependencies & parameters
├── config/              # Dotfiles (stowed to $HOME)
│   └── .config/nvim/
├── cli/                 # CLI commands (optional)
│   └── neovim/
└── scripts/             # Lifecycle hooks
    ├── install          # Custom installation logic
    ├── before           # Pre-deployment
    └── after            # Post-deployment (plugins, etc)
```

**External modules** work seamlessly:
```yaml
# profiles/dev/modes/desktop/mode.yaml
modules:
  - essentials                                    # Built-in module
  - plugins/neovim-custom                         # Profile plugin
  - ~/gits/my-custom-module                       # Local path
  - https://github.com/org/module.git             # External git URL

  # With parameters
  - module: https://github.com/org/jira-module.git
    params:
      team_name: "platform"
      jira_url: "https://company.atlassian.net"
```

**Deploy anything:**
```fish
fedpunk module deploy neovim    # Handles deps, packages, configs automatically
fedpunk module list             # See all available modules
fedpunk module info fish        # Inspect module details
```

### Profiles & Modes

**Three profiles for different use cases:**

| Profile | Purpose | Best For |
|---------|---------|----------|
| `default` | General-purpose setup | New users, most workflows |
| `dev` | Personal reference config | Developers wanting examples |
| `example` | Template starter | Building custom profiles |

**Each profile supports multiple modes:**

```yaml
# profiles/default/modes/desktop/mode.yaml
modules:
  - essentials
  - neovim
  - hyprland
  - firefox
  # Clean, minimal setup

# profiles/default/modes/container/mode.yaml
modules:
  - essentials
  - neovim
  - tmux
  # Terminal-only for containers

# profiles/dev/modes/desktop/mode.yaml (reference implementation)
modules:
  - essentials
  - neovim
  - hyprland
  - nvidia              # Hardware-specific
  - audio
  - plugins/dev-extras  # Personal tools (Spotify, Discord)
  - plugins/fancontrol  # Hardware-specific
```

**Choose at install time:**
```bash
fish install.fish --profile default --mode desktop
fish install.fish --profile default --mode container
```

### Plugin System
Profile-scoped modules for personal/work-specific customization:

```
profiles/dev/
├── modes/              # Module lists per environment
└── plugins/            # Profile-specific modules
    └── dev-extras/     # Spotify, Discord, etc
        ├── module.yaml
        └── config/
```

**Plugins deploy just like regular modules:**
```fish
fedpunk module deploy plugins/dev-extras
```

### Automatic Dependency Resolution
Modules declare their dependencies—the system handles the rest:

```yaml
module:
  name: hyprland
  dependencies:
    - fonts
    - kitty
```

**No manual ordering required.** Fedpunk recursively deploys dependencies, prevents duplicates, and handles transitive dependencies automatically.

---

## Why Fedpunk?

### For Developers
- **Keyboard-First** - Vim-style navigation system-wide (H/J/K/L everywhere)
- **Zero Context Switching** - Terminal, editor, and compositor share keybindings
- **Distraction-Free** - Tiling WM, minimal UI, focus on code
- **Instant Reload** - Live config changes via symlinks (no rebuild)
- **Container-Ready** - Terminal-only mode for devcontainers

### For Power Users
- **Dual Layout Support** - Switch between dwindle (standard) and master (ultrawide)
- **Live Metrics** - btop integration with theme-aware styling
- **Bitwarden CLI** - Vault management with SSH/Claude credential backup
- **Profile Switching** - Multiple personas, one config
- **Extensible** - Plugin system for unlimited customization

### For System Architects
- **Package Abstraction** - DNF, Cargo, NPM, Flatpak in one manifest
- **Dependency DAG** - Automatic resolution with cycle detection
- **Lifecycle Hooks** - Full control over deployment stages
- **Modular Design** - Each component is independently deployable
- **Testable** - Deploy individual modules in isolation

---

## Quick Start

### DNF Install (COPR - Unstable) ⚡ NEW!

**Bleeding-edge builds from main branch** - for early adopters and testers:

```bash
sudo dnf copr enable hinriksnaer/fedpunk-unstable
sudo dnf install fedpunk
fedpunk install
```

⚠️ **Warning:** Unstable builds may contain bugs. See [COPR installation guide](docs/installation/copr-unstable.md) for details.

### Git Clone Install (Traditional)

```bash
curl -fsSL https://raw.githubusercontent.com/hinriksnaer/Fedpunk/main/boot.sh | bash
```

**Interactive prompts guide you through:**
1. **Profile Selection** - Choose your base profile:
   - `default` - Recommended for most users
   - `dev` - Reference implementation with personal preferences
   - `example` - Template for creating your own profile
2. **Mode Selection** - Desktop (full GUI) or Container (terminal-only)
3. **Optional Components** - Add modules as needed after installation

**Desktop Mode Includes:**
- Hyprland compositor with optimized tiling
- Kitty terminal (GPU-accelerated)
- Neovim with LSP, tree-sitter, modern plugins
- tmux, lazygit, btop, yazi (with theming)
- 12 complete themes with instant switching
- Rofi launcher, Mako notifications
- Waybar status bar, Zen Browser (privacy-focused)

**Container Mode Includes:**
- Fish shell with Starship prompt
- Neovim with full plugin suite
- tmux, lazygit, btop
- Theme system (terminal apps only)
- All development tools, no GUI components

---

## Themes

**12 carefully curated themes with instant live-reload:**

| Theme | Style | Best For |
|-------|-------|----------|
| **aetheria** | Ethereal purple/blue gradients | Creative work |
| **ayu-mirage** | Warm desert tones | Extended coding sessions |
| **catppuccin** | Soothing pastel (mocha) | Low-light environments |
| **catppuccin-latte** | Light mode elegance | Bright workspaces |
| **matte-black** | Pure minimalism | Distraction-free focus |
| **nord** | Arctic cool tones | Scandinavian aesthetic |
| **osaka-jade** | Vibrant teal/green | Energizing workflow |
| **ristretto** | Rich espresso browns | Coffee-fueled coding |
| **rose-pine** | Soft rose/pine palette | Gentle on the eyes |
| **rose-pine-dark** | Deep rose/pine | Dark mode variant |
| **tokyo-night** | Deep blues with neon | Cyberpunk vibes |
| **torrentz-hydra** | Bold high contrast | Maximum readability |

### Theme Previews

**Ayu Mirage** - Warm desert tones for extended coding
![Ayu Mirage Theme](themes/ayu-mirage/theme.png)

**Tokyo Night** - Deep blues with neon accents
![Tokyo Night Theme](themes/tokyo-night/preview.png)

**Torrentz Hydra** - Bold high-contrast scheme
![Torrentz Hydra Theme](themes/torrentz-hydra/preview.png)

### Theme Management

```fish
# CLI Commands
fedpunk-theme-list              # List all themes with previews
fedpunk-theme-set <name>        # Switch to specific theme
fedpunk-theme-next              # Cycle forward
fedpunk-theme-prev              # Cycle backward

# Keyboard Shortcuts
Super+T                         # Theme selection menu (Rofi)
Super+Shift+T                   # Next theme
Super+Shift+Y                   # Previous theme
Super+Shift+R                   # Refresh current theme
Super+Shift+W                   # Next wallpaper
```

**What Themes Control:**
- Hyprland - Border colors, gaps, shadows, blur
- Kitty - Terminal palette (live reload via SIGUSR1)
- Neovim - Editor colorscheme (live reload via RPC)
- btop - System monitor colors (live reload)
- Rofi - Launcher appearance
- Mako - Notification styling (live reload via SIGUSR2)
- Waybar - Status bar theme
- Wallpapers - Per-theme backgrounds

**Layout Persistence:**
Window layout preferences survive theme changes—no flickering, no disruption.

---

## Architecture

Fedpunk uses a **layered module system** with profile-based customization:

```
┌─────────────────────────────────────────────┐
│  Bootstrap (boot.sh)                        │
│  └─ Minimal deps: git, fish, stow, gum     │
├─────────────────────────────────────────────┤
│  Module System (lib/fish/)                  │
│  ├─ YAML parser                             │
│  ├─ Module manager (deploy/stow/packages)   │
│  ├─ Dependency resolver (recursive DAG)     │
│  └─ UI abstraction (gum wrapper)            │
├─────────────────────────────────────────────┤
│  Modules (modules/<package>/)               │
│  ├─ module.yaml - metadata & config         │
│  ├─ config/ - dotfiles (stowed to $HOME)    │
│  └─ scripts/ - lifecycle hooks              │
├─────────────────────────────────────────────┤
│  Profiles (profiles/<name>/)                │
│  ├─ modes/ - module lists per environment   │
│  ├─ plugins/ - profile-specific modules     │
│  └─ fedpunk.toml - extra packages/scripts   │
└─────────────────────────────────────────────┘
```

### Deployment Flow

1. **Profile/Mode Selection** - Interactive or CLI flag
2. **Dependency Resolution** - Recursive, prevents duplicates
3. **Package Installation** - DNF, Cargo, NPM, Flatpak from module.yaml
4. **Lifecycle: install** - Custom installation logic
5. **Lifecycle: before** - Pre-deployment setup
6. **Stow Deployment** - Symlink config/ to $HOME
7. **Lifecycle: after** - Post-deployment (plugins, services)

**Why GNU Stow?**
- Instant deployment (symlinks, not copies)
- Live config changes (edit once, active everywhere)
- Modular by design (multiple packages → same directory)
- Simple, standard tool (no custom abstractions)
- Easy rollback (unstow module)

### Key Design Decisions

**Profiles + Modes = Flexibility**
One profile supports multiple environments without code duplication.

**Plugin System = Extensibility**
Profile-scoped modules keep personal/work customizations separate from base config.

**Lifecycle Hooks = Power**
Full control over installation, deployment, and post-configuration without templating complexity.

**Dependency Resolution = Simplicity**
Modules are self-documenting—no manual dependency tracking required.

---

## What You Get

### Core Development Tools
| Tool | Purpose | Config Location |
|------|---------|----------------|
| **Fish Shell** | Modern shell with intelligent completions | `~/.config/fish/` |
| **Starship** | Fast, customizable prompt with git integration | `~/.config/starship.toml` |
| **Neovim** | Vim-based editor with LSP, tree-sitter | `~/.config/nvim/` |
| **Tmux** | Terminal multiplexer with sensible defaults | `~/.config/tmux/` |
| **Lazygit** | Terminal UI for git with vim bindings | `~/.config/lazygit/` |
| **btop** | Beautiful resource monitor | `~/.config/btop/` |
| **Yazi** | Fast terminal file manager | `~/.config/yazi/` |
| **GitHub CLI** | Official GitHub command-line tool | Built-in |
| **Bitwarden CLI** | Password manager with vault commands | Built-in |

### Desktop Environment (Desktop Mode)
| Component | Purpose | Config Location |
|-----------|---------|----------------|
| **Hyprland** | Tiling Wayland compositor | `~/.config/hypr/` |
| **Kitty** | GPU-accelerated terminal | `~/.config/kitty/` |
| **Rofi** | Application launcher | `~/.config/rofi/` |
| **Mako** | Notification daemon | `~/.config/mako/` |
| **Waybar** | Status bar | `~/.config/waybar/` |
| **swaybg** | Wallpaper manager | Per-theme |
| **Zen Browser** | Privacy-focused browser | System defaults |

### Hyprland Features
- **Smart Layouts** - Dwindle (standard tiling) and Master (ultrawide-optimized)
- **Layout Memory** - Remembers preference across sessions and theme changes
- **Vim Navigation** - H/J/K/L for all window operations
- **Workspace Management** - Direct switch (1-9), cycle (Shift+H/L), silent move (Ctrl+1-9)
- **Modifier Scheme** - Consistent Super/Shift/Alt/Ctrl for different operation types
- **Zero Flicker** - Theme changes preserve window positions and layouts

---

## Keybindings

### System Keybinding Philosophy

**Consistent modifier scheme:**
- `Super` - Navigation and launch
- `Super+Shift` - Move and modify
- `Super+Alt` - Advanced manipulation
- `Super+Ctrl` - Adjustments and silent ops

### Navigation (SUPER)
| Key | Action | Context |
|-----|--------|---------|
| `Super+H/J/K/L` | Focus windows | Vim-style |
| `Super+Arrows` | Focus windows | Arrows |
| `Super+1-9` | Switch workspace | Direct |
| `Super+Tab` | Last workspace | Toggle |

### Workspace Operations (SUPER+SHIFT)
| Key | Action | Effect |
|-----|--------|--------|
| `Super+Shift+H/L` | Cycle workspaces | Prev/Next |
| `Super+Shift+1-9` | Move window | With focus change |

### Window Manipulation (SUPER+ALT)
| Key | Action | Use Case |
|-----|--------|----------|
| `Super+Alt+H/J/K/L` | Move window | Rearrange layout |
| `Super+Alt+R` | Rotate split | Change split direction |
| `Super+Alt+Space` | Toggle layout | Dwindle ↔ Master |

### Adjustments (SUPER+CTRL)
| Key | Action | Benefit |
|-----|--------|---------|
| `Super+Ctrl+H/J/K/L` | Resize window | Fine-tune layout |
| `Super+Ctrl+1-9` | Silent move | No focus change |

### Applications
| Key | Application | Notes |
|-----|------------|-------|
| `Super+Return` | Kitty terminal | GPU-accelerated |
| `Super+Space` | Rofi launcher | Theme-aware |
| `Super+B` | Zen Browser | Privacy-focused |
| `Super+E` | File manager | Yazi in terminal |
| `Super+Shift+B` | Bluetooth | GUI manager |

### Window Management
| Key | Action | Description |
|-----|--------|-------------|
| `Super+Q` | Close window | Kill focused |
| `Super+V` | Toggle floating | Float/tile |
| `Super+F` | Toggle fullscreen | Maximize |
| `Super+P` | Pseudo tile | Floating in tile |

### Themes & Customization
| Key | Action | Speed |
|-----|--------|-------|
| `Super+T` | Theme menu | Rofi selector |
| `Super+Shift+T` | Next theme | Instant |
| `Super+Shift+Y` | Prev theme | Instant |
| `Super+Shift+R` | Refresh theme | Reload |
| `Super+Shift+W` | Next wallpaper | Cycle |

### Screenshots
| Key | Action | Output |
|-----|--------|--------|
| `Print` | Selection | Region screenshot |
| `Super+Print` | Full screen | Entire display |

**Full keybinding reference:** [`docs/reference/keybindings.md`](docs/reference/keybindings.md)

---

## Module Management

### CLI Commands

```fish
# Module Discovery
fedpunk module list                      # List all modules
fedpunk module info <name>               # Show module details

# Deployment
fedpunk module deploy <name>             # Full deployment (deps + packages + config)
fedpunk module stow <name>               # Config only (skip packages)
fedpunk module unstow <name>             # Remove config symlinks

# Package Management
fedpunk module install-packages <name>   # Packages only (skip config)

# Lifecycle Execution
fedpunk module run-lifecycle <name> <hook>  # Run specific hook (install/before/after)

# Examples
fedpunk module deploy neovim             # Deploy Neovim with all dependencies
fedpunk module deploy plugins/dev-extras # Deploy profile plugin
fedpunk module info fish                 # See fish module metadata
fedpunk module unstow hyprland           # Remove Hyprland configs (keep packages)
```

### Creating Custom Modules

```bash
# Module structure
modules/mymodule/
├── module.yaml
├── config/
│   └── .config/mymodule/
│       └── config.conf
└── scripts/
    ├── install
    └── after
```

**module.yaml:**
```yaml
module:
  name: mymodule
  description: My custom module
  dependencies:
    - fish

lifecycle:
  install:
    - install
  after:
    - after

packages:
  dnf:
    - mypackage
  cargo:
    - mytool

stow:
  target: $HOME
  conflicts: warn
```

**Lifecycle scripts** (Fish or Bash):
```fish
#!/usr/bin/env fish
# scripts/install
echo "Custom installation logic here"
sudo systemctl enable myservice
```

**Deploy it:**
```fish
fedpunk module deploy mymodule
```

### Creating Profile Plugins

```bash
# Profile plugin structure
profiles/dev/plugins/work-tools/
├── module.yaml
└── config/
    └── .config/work/
```

**Deploy with:**
```fish
fedpunk module deploy plugins/work-tools
```

**Add to mode:**
```yaml
# profiles/dev/modes/desktop/mode.yaml
modules:
  - fish
  - neovim
  - plugins/work-tools  # Auto-deployed with profile
```

---

## Built-in Integrations

### Bitwarden CLI
Password management with custom vault commands:

```fish
# Vault Management
fedpunk vault login              # Login to Bitwarden
fedpunk vault unlock             # Unlock vault
fedpunk vault status             # Check vault status

# SSH Key Management
fedpunk vault ssh-backup         # Backup SSH keys to vault (GPG encrypted)
fedpunk vault ssh-restore        # Restore SSH keys from vault
fedpunk vault ssh-load           # Load SSH keys into ssh-agent
fedpunk vault ssh-list           # List available SSH backups

# Claude Code Credentials
fedpunk vault claude-backup      # Backup Claude credentials
fedpunk vault claude-restore     # Restore Claude credentials

# New Machine Workflow
fedpunk vault unlock             # Unlock vault first
fedpunk vault ssh-restore        # Restore your SSH keys
fedpunk vault ssh-load           # Load keys into agent
gh auth login                    # Authenticate with GitHub
```

### GitHub CLI
Complete GitHub integration:

```fish
# Repository operations
gh repo create                   # Create new repo
gh repo clone <repo>            # Clone repository
gh repo view                     # View repo details

# Pull request workflow
gh pr create                     # Create PR with template
gh pr list                       # List all PRs
gh pr checkout <number>          # Checkout PR locally
gh pr view <number>              # View PR details

# Issue management
gh issue create                  # Create new issue
gh issue list                    # List issues
gh issue view <number>           # View issue details
```

### Claude Code
Neovim integration with Claude:

- Custom Claude Code plugin for Neovim
- Buffer-aware AI assistance
- Project context understanding
- Slash commands and workflow automation

---

## Updates & Maintenance

### Update System

```bash
# Update Fedpunk
cd ~/.local/share/fedpunk
git pull
./install.fish  # Re-run installer (safe to repeat)

# Update specific module
fedpunk module deploy neovim --force

# Update all packages
sudo dnf update -y
```

The installer is **re-run safe**—it detects existing components and only updates what's needed.

### Reload Configuration

```fish
# Reload all services
fedpunk-reload

# What it does:
# - Reloads Hyprland config (hyprctl reload)
# - Reloads Waybar (SIGUSR2)
# - Reloads Mako notifications (SIGUSR2)
# - Reloads Kitty config (SIGUSR1)

# Manual reload options
hyprctl reload                   # Hyprland only
killall -SIGUSR2 waybar         # Waybar only
exec fish                        # Restart shell
```

**Note:** Configs are live via Stow symlinks—edit once, active everywhere.

---

## Container/Server Deployment

### Terminal-Only Mode

Perfect for:
- Devcontainers
- Remote servers
- WSL environments
- Existing desktop setups

```bash
# Use container mode during install
curl -fsSL https://raw.githubusercontent.com/hinriksnaer/Fedpunk/main/boot.sh | bash
# Select "container" mode when prompted

# Or non-interactive with container mode
curl -fsSL https://raw.githubusercontent.com/hinriksnaer/Fedpunk/main/boot.sh | \
  FEDPUNK_MODE=container bash
```

**Installs:**
- Fish shell with modern tooling
- Neovim with full LSP support
- tmux, lazygit, btop, yazi
- Theme system (terminal apps only)
- All development tools

**Skips:**
- Hyprland compositor
- Kitty terminal
- Desktop applications
- GUI components
- NVIDIA drivers

### Devcontainer Configuration

```json
{
  "name": "Fedpunk Dev",
  "image": "fedora:40",
  "postCreateCommand": "curl -fsSL https://raw.githubusercontent.com/hinriksnaer/Fedpunk/main/boot.sh | FEDPUNK_MODE=container bash",
  "customizations": {
    "vscode": {
      "settings": {
        "terminal.integrated.defaultProfile.linux": "fish"
      }
    }
  }
}
```

---

## Documentation

**Complete documentation in [`docs/`](docs/):**

### Guides
- **[Architecture Guide](ARCHITECTURE.md)** - System design and philosophy ⭐ **Start Here**
- **[Installation Guide](docs/guides/installation.md)** - Detailed setup instructions
- **[Customization Guide](docs/guides/customization.md)** - Make it your own
- **[Themes Guide](docs/guides/themes.md)** - Theme system and creation

### Reference
- **[Keybindings](docs/reference/keybindings.md)** - Complete keyboard shortcut reference
- **[Configuration](docs/reference/configuration.md)** - All config files and structure
- **[Scripts](docs/reference/scripts.md)** - Utility scripts documentation

### Development
- **[Contributing](docs/development/contributing.md)** - How to contribute
- **[Roadmap](docs/ROADMAP.md)** - Future plans and progress

---

## System Requirements

- **OS:** Fedora Linux 39+
- **Arch:** x86_64
- **RAM:** 4GB minimum, 8GB recommended for desktop mode
- **Storage:** ~2GB free space
- **Optional:** NVIDIA GPU (proprietary drivers available)

---

## Troubleshooting

### Common Issues

**Fish shell not available after install:**
```bash
exec fish
# Or restart terminal
```

**Hyprland won't start:**
```bash
# Check logs
cat /tmp/hypr/$(ls -t /tmp/hypr/ | head -1)/hyprland.log

# NVIDIA users
lsmod | grep nvidia
```

**Audio not working:**
```bash
# Restart PipeWire
systemctl --user restart pipewire pipewire-pulse wireplumber
```

**Theme changes not applying:**
```fish
fedpunk-reload  # Reload all services
```

**Permission errors:**
```bash
# Fix ownership
sudo chown -R $USER:$USER ~/.config

# Fix SELinux contexts
sudo restorecon -R ~/.config
```

All installation logs saved to `/tmp/fedpunk-install-*.log`

**Full troubleshooting guide:** [`docs/guides/troubleshooting.md`](docs/guides/troubleshooting.md)

---

## Philosophy

Fedpunk is built on core principles:

**Keyboard-First**
Mouse is optional. Every action accessible via keybindings with consistent, memorable patterns.

**Consistency**
Similar operations use similar key combinations. Learn once, apply everywhere.

**Vim-Inspired**
H/J/K/L navigation throughout the system. Window manager, editor, terminal multiplexer—all speak the same language.

**Modular**
Components are independently deployable and composable. Mix and match to build your perfect setup.

**Fish-Powered**
Leverage Fish's modern features: intelligent completions, readable syntax, powerful scripting.

**Aesthetic**
Beautiful themes that work across all applications. Consistency breeds focus.

**Productive**
Optimized for developer workflows. Less time configuring, more time creating.

---

## Contributing

We welcome contributions!

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Test your changes: `fish install.fish`
4. Commit with clear messages
5. Submit a pull request

**Areas for contribution:**
- New themes
- Additional modules
- Window rules and keybindings
- Documentation improvements
- Bug fixes
- New features

**See:** [`docs/development/contributing.md`](docs/development/contributing.md)

---

## Acknowledgments

- [omarchy](https://github.com/basecamp/omarchy) - Theming framework inspiration
- [JaKooLit's Hyprland-Dots](https://github.com/JaKooLit/Fedora-Hyprland) - Package references
- [Fish Shell Community](https://fishshell.com/) - Amazing modern shell
- [Hyprland](https://hyprland.org/) - Revolutionary Wayland compositor
- The Fedora Project - Solid Linux foundation
- GNU Stow - Simple, powerful symlinking

---

## License

MIT License - See [LICENSE](LICENSE) file for details

---

<div align="center">

## Ready to Transform Your Workflow?

```bash
curl -fsSL https://raw.githubusercontent.com/hinriksnaer/Fedpunk/main/boot.sh | bash
```

**Fedpunk** - *Where modular configuration meets keyboard-driven productivity*

**Star this repo** if you find it useful!

</div>
