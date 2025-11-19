# Fedpunk

**A modern, modular Fedora development environment powered by chezmoi**

Transform Fedora into a productivity powerhouse featuring tiling window management, seamless theming, and a curated development stack—all managed through a composable module system that adapts to your workflow.

---

## Why Fedpunk?

**🚀 Zero-friction setup** - One command installs everything from compositor to terminal to themes
**⚡ Blazing fast workflow** - Hyprland compositor with optimized keybindings and vim-style navigation
**🎨 Live theme switching** - Complete themes that update across all applications instantly
**🐟 Fish-first design** - Modern shell with intelligent completions and powerful scripting
**🖥️ Flexible deployment** - Desktop, laptop, or container modes adapt to your environment
**📦 Modular architecture** - Self-contained modules with configs, scripts, and dependencies
**🔄 Dynamic configuration** - Modules enable/disable based on your profile and environment
**🎯 Profile-driven** - Compose your perfect setup from base, dev, or custom profiles

---

## Quick Start

### One-Line Installation

```bash
curl -fsSL https://raw.githubusercontent.com/hinriksnaer/Fedpunk/main/bootstrap.sh | bash
```

**That's it!** The bootstrap will:
1. Install essentials (chezmoi, fish, gum)
2. Launch Fedpunk installation
3. Auto-detect your environment (desktop/laptop/container)
4. Prompt for profile selection (base/dev)
5. Install and configure everything

### Manual Installation

If you already have chezmoi, fish, and gum:

```bash
# Interactive installation (prompts for mode/profile)
chezmoi init --apply https://github.com/hinriksnaer/Fedpunk.git

# Explicit mode and profile
FEDPUNK_MODE=desktop FEDPUNK_PROFILE=dev chezmoi init --apply https://github.com/hinriksnaer/Fedpunk.git
```

---

## Modes

Choose your deployment target:

| Mode | Environment | Desktop | Use Case |
|------|-------------|---------|----------|
| **🖥️ Desktop** | Full system | ✅ Hyprland + GUI apps | Workstation, gaming rig |
| **💻 Laptop** | Mobile system | ✅ Hyprland + power mgmt | On-the-go development |
| **📦 Container** | Minimal environment | ❌ Terminal only | Docker, WSL, remote servers |

**Auto-detection**: Fedpunk automatically detects your environment:
- Container: Checks for `/.dockerenv`, `/run/.containerenv`, or `$CONTAINER`
- Laptop: Detects battery via `/sys/class/power_supply/BAT0`
- Desktop: Default fallback

---

## Themes

Fedpunk includes a dynamic theme system with **11+ beautiful themes** (desktop/laptop modes):

### Theme Previews

**Catppuccin Mocha**
![Catppuccin Theme](themes/catppuccin/preview.png)

**Nord**
![Nord Theme](themes/nord/preview.png)

**Tokyo Night**
![Tokyo Night Theme](themes/tokyo-night/preview.png)

**Ayu Mirage**
![Ayu Mirage Theme](themes/ayu-mirage/theme.png)

**Rose Pine**
![Rose Pine Theme](themes/rose-pine/preview.png)

**Torrentz Hydra**
![Torrentz Hydra Theme](themes/torrentz-hydra/preview.png)

**Osaka Jade**
![Osaka Jade Theme](themes/osaka-jade/preview.png)

**Aetheria**
![Aetheria Theme](themes/aetheria/preview.png)

**Ristretto**
![Ristretto Theme](themes/ristretto/preview.png)

**Matte Black**
![Matte Black Theme](themes/matte-black/preview.png)

**Catppuccin Latte** (Light theme)
![Catppuccin Latte Theme](themes/catppuccin-latte/preview.png)

### Switch Themes

```bash
# List available themes
fedpunk-theme-list

# Switch theme instantly
fedpunk-theme-set catppuccin-mocha

# Get current theme
fedpunk-theme-get
```

**Themes update instantly across:**
- Hyprland (window decorations, gaps, borders)
- Kitty (terminal colors)
- Waybar (status bar colors)
- Rofi (launcher colors)
- Btop (system monitor)
- Neovim (editor colors)

---

## Profiles

Compose your perfect environment:

### 📦 Base Profile
**Essential terminal and desktop experience**

**Modules**: `core`, `cli-tools`, `tmux`, `nvim`, `languages`, `hyprland`, `kitty`, `themes`, `fonts`, `audio`

**What you get**:
- **Core**: Fish shell, Git, Cargo, Gum, DNF optimizations
- **CLI Tools**: eza, fd, ripgrep, fzf, bat, btop, yazi, lazygit
- **Terminal**: tmux with TPM plugin manager
- **Editor**: Neovim with lazy.nvim and LSP support
- **Languages**: Go, Node.js, Python toolchains
- **Desktop** (desktop/laptop only): Hyprland, Kitty, Rofi, Waybar, Mako
- **Theming** (desktop/laptop only): 11+ themes with instant switching
- **Fonts**: JetBrainsMono Nerd Font, system fonts
- **Audio** (desktop/laptop only): PipeWire, pavucontrol

### 🚀 Dev Profile
**Full development environment (inherits base + adds tools)**

**Additional Modules**: `podman`, `git-tools`, `claude`

**What you get** (on top of base):
- **Podman**: Container runtime with Docker CLI compatibility
- **Git Tools**: Delta diff viewer, advanced Git config
- **Claude**: Claude Code CLI and integrations

### 🎨 Create Your Own
Profiles are composable! Create `profiles/myprofile/fedpunk.yaml`:

```yaml
profile:
  name: myprofile
  description: My custom setup

inherit: base  # Start with base, add your modules

modules:
  - custom-module

module_params:
  languages:
    install_rust: true
    install_go: false
```

---

## Architecture

### Module-Centric Design

Fedpunk uses a **module-centric architecture** where each module is completely self-contained:

```
fedpunk/
├── modules/                    # Self-contained modules
│   ├── nvim/
│   │   ├── module.yaml        # Metadata, dependencies, hooks, params
│   │   ├── install.fish       # Installation script
│   │   ├── setup-plugins.fish # Post-install setup
│   │   └── config/            # Module's dotfiles
│   │       └── dot_config/
│   │           └── nvim/      # Deployed to ~/.config/nvim
│   │               ├── init.lua
│   │               └── lua/
│   ├── tmux/
│   │   ├── module.yaml
│   │   ├── install.fish
│   │   ├── setup-plugins.fish
│   │   └── config/
│   │       └── dot_config/tmux/
│   └── hyprland/
│       ├── module.yaml
│       ├── install.fish
│       └── config/
│           └── dot_config/
│               ├── hypr/
│               ├── waybar/
│               └── rofi/
│
├── profiles/                   # Composition layer
│   ├── base/
│   │   └── fedpunk.yaml       # Lists modules to enable
│   └── dev/
│       └── fedpunk.yaml       # Inherits base + adds more
│
├── lib/                        # Shared libraries
│   ├── helpers.fish           # Logging, installation helpers
│   └── modules.fish           # Module loader/executor
│
├── dot_config/                 # Dynamic symlinks (created automatically)
├── .chezmoi.toml.tmpl         # Orchestration engine
└── bootstrap.sh               # Bootstrap installer
```

### How It Works

```
┌──────────────────────────────────────────────────────────────┐
│ 1. Bootstrap Phase                                            │
│    • Install: chezmoi, fish, gum                             │
│    • Launch: chezmoi init --apply                            │
└──────────────────────────────────────────────────────────────┘
                             │
                             ▼
┌──────────────────────────────────────────────────────────────┐
│ 2. Template Processing (.chezmoi.toml.tmpl)                  │
│    • Auto-detect mode (container/laptop/desktop)             │
│    • Load profile manifest (default: dev)                    │
│    • Resolve module dependencies                             │
│    • Build execution plan (hooks + configs)                  │
│    • Export module environment variables                     │
└──────────────────────────────────────────────────────────────┘
                             │
                             ▼
┌──────────────────────────────────────────────────────────────┐
│ 3. Dynamic Configuration Setup (run_before_00)               │
│    • For each enabled module:                                │
│      - Check if module has config/ directory                 │
│      - Create symlinks: dot_config/nvim -> modules/nvim/...  │
│    • Result: Module configs available for deployment         │
└──────────────────────────────────────────────────────────────┘
                             │
                             ▼
┌──────────────────────────────────────────────────────────────┐
│ 4. Installation Phase (run_before_01)                        │
│    • Execute before_apply hooks for each module:             │
│      - core: DNF config, install Fish, Git, Gum              │
│      - cli-tools: Install eza, fd, ripgrep, fzf, etc.        │
│      - tmux: Install tmux, set up TPM                        │
│      - nvim: Install Neovim                                  │
│      - languages: Install Go, Node.js, Python                │
│      - hyprland: Install compositor + GUI apps (if desktop)  │
└──────────────────────────────────────────────────────────────┘
                             │
                             ▼
┌──────────────────────────────────────────────────────────────┐
│ 5. Dotfile Deployment (chezmoi apply)                        │
│    • Follow symlinks in dot_config/                          │
│    • Deploy to ~/.config/, ~/.local/, ~/                     │
│    • Result: All configs in place                            │
└──────────────────────────────────────────────────────────────┘
                             │
                             ▼
┌──────────────────────────────────────────────────────────────┐
│ 6. Post-Installation (run_once_after)                        │
│    • Execute after_apply hooks:                              │
│      - tmux: Install TPM plugins                             │
│      - nvim: Bootstrap lazy.nvim, install plugins            │
└──────────────────────────────────────────────────────────────┘
                             │
                             ▼
┌──────────────────────────────────────────────────────────────┐
│ 7. Theme Setup (run_onchange_after)                          │
│    • Execute on_change hooks (runs on theme updates)         │
│    • Initialize theme system                                 │
└──────────────────────────────────────────────────────────────┘
```

### Key Features

**🔗 Dynamic Module Linking**
- Module configs live inside `modules/*/config/`
- Symlinks created automatically during installation
- Only enabled modules get linked
- Updates handled gracefully on `chezmoi apply`

**🎯 Declarative Composition**
- Profiles declare which modules to enable
- Modules declare dependencies, hooks, and parameters
- Template engine orchestrates everything
- No imperative scripting in user code

**🔧 Flexible Parameterization**
- Modules expose parameters via `module.yaml`
- Profiles override parameters for customization
- Environment variables exported automatically
- Example: `FEDPUNK_MODULE_NVIM_SETUP_PLUGINS=true`

**📊 Mode-Aware Execution**
- Modules can disable themselves per mode
- Example: Hyprland disabled in container mode
- Automatic detection + manual override supported

---

## Modules

### Core System Modules

#### 🔧 core
Essential system setup and shell configuration

**Installs**: Fish shell, Git, Cargo, Gum, starship prompt
**Configures**: DNF parallel downloads, Fish config, starship prompt
**Depends**: None (foundation module)

#### 🛠️ cli-tools
Modern CLI utilities for development

**Installs**: eza, fd, ripgrep, fzf, bat, btop, yazi, lazygit, lazydocker
**Configures**: Tool configs with sensible defaults
**Depends**: `core`

#### 📺 tmux
Terminal multiplexer with plugin manager

**Installs**: tmux, TPM (plugin manager)
**Configures**: Vim-style keybindings, plugins (sensible, resurrect, continuum)
**Depends**: `core`

#### ✏️ nvim
Neovim editor with LSP and plugin ecosystem

**Installs**: Neovim, lazy.nvim plugin manager
**Configures**: LSP, Treesitter, Telescope, file explorer
**Depends**: `core`, `languages`
**Parameters**:
- `package_name`: Package to install (default: `neovim`)
- `setup_plugins`: Auto-install plugins (default: `true`)

#### 💻 languages
Programming language toolchains

**Installs**: Go, Node.js, Python
**Configures**: Version managers, package managers
**Depends**: `core`
**Parameters**:
- `install_go`: Install Go toolchain (default: `true`)
- `install_nodejs`: Install Node.js (default: `true`)
- `install_python`: Install Python (default: `true`)

### Desktop Modules

#### 🪟 hyprland
Wayland compositor and window management

**Installs**: Hyprland, Waybar, Rofi, Mako, Wayland utils
**Configures**: Window rules, keybindings, workspaces, animations
**Depends**: `core`, `kitty`, `themes`
**Modes**: Desktop, Laptop only

#### 🖥️ kitty
GPU-accelerated terminal emulator

**Installs**: Kitty terminal
**Configures**: Font rendering, colors, keybindings
**Depends**: `core`, `fonts`
**Modes**: Desktop, Laptop only

#### 🎨 themes
Dynamic theme system with instant switching

**Installs**: Theme assets, wallpapers
**Configures**: 11+ themes for Hyprland, Kitty, Waybar, Rofi, btop
**Depends**: `hyprland`, `kitty`
**Modes**: Desktop, Laptop only

**Available themes**: catppuccin-mocha, nord, dracula, gruvbox, tokyo-night, and more

#### 🔤 fonts
System fonts and Nerd Fonts

**Installs**: JetBrainsMono Nerd Font, system fonts
**Configures**: Font rendering, fontconfig
**Depends**: `core`

#### 🔊 audio
Audio stack for desktop

**Installs**: PipeWire, pavucontrol, audio plugins
**Configures**: Audio routing, volume control
**Depends**: `core`
**Modes**: Desktop, Laptop only

### Development Modules

#### 🐳 podman
Container runtime and management

**Installs**: Podman, podman-compose, Docker CLI compatibility
**Configures**: Rootless containers, registries
**Depends**: `core`

#### 🌿 git-tools
Enhanced Git workflow

**Installs**: Delta (diff viewer), Git extras
**Configures**: Advanced Git config, aliases, diff highlighting
**Depends**: `core`

#### 🤖 claude
Claude Code CLI integration

**Installs**: Claude Code CLI
**Configures**: Claude integrations, settings
**Depends**: `core`

---

## Creating Modules

Modules are self-contained with configs, scripts, and metadata:

### 1. Create Module Structure

```bash
mkdir -p modules/mymodule/config/dot_config/myapp
```

### 2. Write Module Manifest

**modules/mymodule/module.yaml**:
```yaml
module:
  name: mymodule
  description: My custom module

depends:
  - core  # Dependencies

params:
  enable_feature: true  # Configurable parameters
  package_name: myapp

hooks:
  before_apply:
    - install.fish  # Installation script
  after_apply:
    - setup.fish    # Post-install setup

modes:
  container:
    enabled: true
  desktop:
    enabled: true
  laptop:
    enabled: true
```

### 3. Write Installation Script

**modules/mymodule/install.fish**:
```fish
#!/usr/bin/env fish

info "Installing mymodule"

# Access module parameters
set package $FEDPUNK_MODULE_MYMODULE_PACKAGE_NAME

# Install package
install_package $package

success "mymodule installed"
```

### 4. Add Module Configs

**modules/mymodule/config/dot_config/myapp/config.conf**:
```
# Your app configuration
# Deployed to ~/.config/myapp/config.conf
```

### 5. Use Module in Profile

**profiles/custom/fedpunk.yaml**:
```yaml
profile:
  name: custom

inherit: base

modules:
  - mymodule

module_params:
  mymodule:
    enable_feature: false
    package_name: myapp-nightly
```

---

## Theme Management

Fedpunk includes a dynamic theme system (desktop/laptop modes):

### Switch Themes

```bash
# List available themes
fedpunk-theme-list

# Switch theme
fedpunk-theme-set catppuccin-mocha

# Get current theme
fedpunk-theme-get
```

### Available Themes

- **catppuccin-mocha** - Soothing pastel theme (default)
- **nord** - Arctic, north-bluish color palette
- **dracula** - Dark theme with bright colors
- **gruvbox-dark** - Retro groove colors
- **tokyo-night** - Clean dark theme
- **one-dark** - Atom's iconic theme
- **solarized-dark** - Precision colors
- And more!

### Theme Previews

**Catppuccin Mocha**
![Catppuccin Theme](themes/catppuccin/preview.png)

**Nord**
![Nord Theme](themes/nord/preview.png)

**Tokyo Night**
![Tokyo Night Theme](themes/tokyo-night/preview.png)

**Ayu Mirage**
![Ayu Mirage Theme](themes/ayu-mirage/theme.png)

**Rose Pine**
![Rose Pine Theme](themes/rose-pine/preview.png)

**Torrentz Hydra**
![Torrentz Hydra Theme](themes/torrentz-hydra/preview.png)

**Osaka Jade**
![Osaka Jade Theme](themes/osaka-jade/preview.png)

**Aetheria**
![Aetheria Theme](themes/aetheria/preview.png)

**Ristretto**
![Ristretto Theme](themes/ristretto/preview.png)

**Matte Black**
![Matte Black Theme](themes/matte-black/preview.png)

**Catppuccin Latte** (Light theme)
![Catppuccin Latte Theme](themes/catppuccin-latte/preview.png)

Themes update instantly across:
- Hyprland (window decorations, gaps, borders)
- Kitty (terminal colors)
- Waybar (status bar colors)
- Rofi (launcher colors)
- Btop (system monitor)
- Neovim (editor colors)

---

## Configuration

### Environment Variables

Control Fedpunk behavior:

```bash
# Mode selection (auto-detected if not set)
export FEDPUNK_MODE=desktop|laptop|container

# Profile selection (default: dev)
export FEDPUNK_PROFILE=base|dev|custom

# Non-interactive mode (skip prompts)
export FEDPUNK_NON_INTERACTIVE=1
```

### Module Parameters

Modules expose parameters in `.chezmoi.toml`:

```toml
[data.module.nvim]
  ENABLED = "true"
  PACKAGE_NAME = "neovim"
  SETUP_PLUGINS = true

[data.module.languages]
  ENABLED = "true"
  INSTALL_GO = true
  INSTALL_NODEJS = true
  INSTALL_PYTHON = false  # Override to disable Python
```

### Accessing Parameters in Scripts

Module parameters are exported as environment variables:

```fish
# Format: FEDPUNK_MODULE_<MODULE>_<PARAM>
echo $FEDPUNK_MODULE_NVIM_PACKAGE_NAME  # "neovim"
echo $FEDPUNK_MODULE_NVIM_SETUP_PLUGINS # "true"
```

---

## Updating

Keep your Fedpunk installation up to date:

```bash
# Update chezmoi source (pulls latest changes)
chezmoi update

# Re-apply configurations (updates symlinks, runs changed hooks)
chezmoi apply

# Full refresh (re-run all installation)
chezmoi init --apply https://github.com/hinriksnaer/Fedpunk.git
```

**What gets updated**:
- Module configs (via symlinks)
- Changed dotfiles
- Hook scripts marked as `run_onchange` or `run_once`

**What doesn't re-run**:
- Package installations (unless you remove chezmoi state)
- `run_once` scripts that haven't changed

---

## Troubleshooting

### Check Installation Logs

```bash
# View installation log
tail -f /tmp/fedpunk-install-*.log

# View post-installation log
tail -f /tmp/fedpunk-after-*.log

# View theme change log
tail -f /tmp/fedpunk-onchange-*.log
```

### Verify Module Configuration

```bash
# Check loaded configuration
chezmoi data | jq '.profile'

# View modules
chezmoi data | jq '.profile.modules'

# View module parameters
chezmoi data | jq '.module'
```

### Debug Symlinks

```bash
# Check symlinks in source directory
ls -la ~/.local/share/chezmoi/dot_config/

# Should show symlinks like:
# nvim -> /path/to/chezmoi/modules/nvim/config/dot_config/nvim
```

### Reset Installation

```bash
# Remove chezmoi state
rm -rf ~/.local/share/chezmoi ~/.config/chezmoi

# Fresh installation
chezmoi init --apply https://github.com/hinriksnaer/Fedpunk.git
```

### Common Issues

**Module configs not appearing**:
- Check symlinks were created: `ls -la ~/.local/share/chezmoi/dot_config/`
- Verify module is enabled: `chezmoi data | jq '.profile.modules'`
- Re-run symlink setup: `chezmoi apply`

**Package installation fails**:
- Check DNF configuration: `/etc/dnf/dnf.conf`
- View installation logs: `tail -f /tmp/fedpunk-install-*.log`
- Verify network connectivity

**Theme switching doesn't work**:
- Desktop/laptop mode only (not available in container mode)
- Check theme exists: `fedpunk-theme-list`
- View theme logs: `tail -f /tmp/fedpunk-onchange-*.log`

---

## Reference

### Helper Functions

Available in all module scripts via `lib/helpers.fish`:

**Logging**:
- `info "message"` - Blue info message
- `success "message"` - Green success message
- `warning "message"` - Yellow warning
- `error "message"` - Red error (doesn't exit)
- `section "title"` - Section header

**Package Management**:
- `install_package pkg [pkg...]` - Install with spinner + logging
- `install_package_group @group` - Install package group

**Spinners**:
- `start_spinner "message"` - Start loading spinner
- `stop_spinner 0` - Stop spinner (0=success, 1=failure)
- `spinner_with_command "message" command args` - Run with spinner

**Conditionals**:
- `if is_container` - Check if in container mode
- `if is_desktop` - Check if in desktop mode
- `if is_laptop` - Check if in laptop mode

### Module Loader Functions

Available via `lib/modules.fish`:

- `should_run_module "module_name"` - Check if module should execute
- `execute_module_hook "module" "script" "phase"` - Run module hook

### Chezmoi Template Variables

Available in `.tmpl` files:

```go
{{ .mode.name }}              // "desktop", "laptop", "container"
{{ .profile.name }}           // "base", "dev", etc.
{{ .profile.path }}           // Full path to profile directory
{{ .profile.modules }}        // List of enabled modules
{{ .profile.before_apply_hooks }}  // List of installation hooks
{{ .profile.after_apply_hooks }}   // List of setup hooks
{{ .module.nvim.ENABLED }}    // Module-specific parameters
{{ .chezmoi.sourceDir }}      // ~/.local/share/chezmoi
{{ .chezmoi.homeDir }}        // ~
```

### Module Manifest Schema

```yaml
module:
  name: string              # Module identifier
  description: string       # Human-readable description

depends:                    # Module dependencies
  - string[]

params:                     # Configurable parameters
  key: value

hooks:
  before_apply:             # Installation phase
    - script.fish[]
  after_apply:              # Post-install phase
    - script.fish[]
  on_change:                # Re-run when files change
    - script.fish[]

modes:                      # Mode-specific settings
  container:
    enabled: bool
  desktop:
    enabled: bool
  laptop:
    enabled: bool

auto_detect:                # Optional auto-detection
  command: string           # Command to check if installed
  prompt: string            # User prompt
  default: yes|no           # Default answer
```

### Profile Manifest Schema

```yaml
profile:
  name: string              # Profile identifier
  description: string       # Human-readable description

inherit: string             # Optional parent profile (base)

modules:                    # Modules to enable
  - string[]

mode_modules:               # Mode-specific modules
  desktop:
    - string[]
  laptop:
    - string[]

module_params:              # Parameter overrides
  module_name:
    param: value
```

---

## Contributing

Fedpunk is designed to be extended! Contributions welcome:

1. **Create modules** - Add new functionality
2. **Improve themes** - Design new color schemes
3. **Enhance docs** - Help others get started
4. **Report issues** - Found a bug? Let us know
5. **Share configs** - Post your customizations

**Repository**: https://github.com/hinriksnaer/Fedpunk

---

## License

MIT License - See LICENSE file for details

---

## Credits

Built with:
- [chezmoi](https://www.chezmoi.io/) - Dotfile manager
- [Fish](https://fishshell.com/) - Modern shell
- [Hyprland](https://hyprland.org/) - Wayland compositor
- [Neovim](https://neovim.io/) - Text editor
- [Gum](https://github.com/charmbracelet/gum) - TUI library

Inspired by the Fedora community and developers who value efficiency, aesthetics, and automation.

---

**Made with ❤️ for developers who want their environment to just work.**
