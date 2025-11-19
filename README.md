# Fedpunk

**A modern, modular Fedora development environment powered by chezmoi**

Fedpunk transforms Fedora into a productivity-focused workspace featuring tiling window management, seamless theming, and a curated set of development tools—all configured through a composable module system and managed by chezmoi.

---

## Table of Contents

- [Quick Start](#quick-start)
- [Architecture](#architecture)
- [Profiles](#profiles)
- [Modules](#modules)
- [Modes](#modes)
- [Creating Modules](#creating-modules)
- [Creating Profiles](#creating-profiles)
- [Configuration](#configuration)
- [Themes](#themes)
- [Troubleshooting](#troubleshooting)
- [Reference](#reference)

---

## Quick Start

### Installation

```bash
# Clone and initialize (interactive mode selection)
chezmoi init --apply https://github.com/hinriksnaer/Fedpunk.git

# Or specify mode explicitly
FEDPUNK_MODE=desktop FEDPUNK_PROFILE=dev chezmoi init --apply https://github.com/hinriksnaer/Fedpunk.git
```

**What happens:**
1. Chezmoi clones the repository
2. Mode detection (or prompts you to choose: desktop/laptop/container)
3. Profile manifest loaded (default: `dev`)
4. Module dependencies resolved
5. Before-apply hooks execute (installs packages)
6. Dotfiles deployed to `~/.config/`
7. After-apply hooks execute (plugin setup, optimizations)

### Available Profiles

| Profile | Description | Modules |
|---------|-------------|---------|
| **base** | Essential terminal + desktop | core, cli-tools, tmux, nvim, languages, hyprland, kitty, themes, fonts, audio |
| **dev** | Development environment (inherits base) | + podman, git-tools, claude |

### Modes

| Mode | Environment | Desktop Components | Use Case |
|------|-------------|-------------------|----------|
| **desktop** | Full desktop | ✅ Hyprland, themes, audio | Workstation |
| **laptop** | Desktop + power mgmt | ✅ + battery optimizations | Mobile |
| **container** | Terminal only | ❌ No GUI components | Devcontainers, WSL, remote |

---

## Architecture

Fedpunk uses a **module-centric architecture** where functionality is organized into self-contained, composable modules managed by profiles.

### Directory Structure

```
fedpunk/
├── modules/              # Self-contained functionality modules
│   ├── core/
│   │   ├── module.yaml   # Module metadata, deps, hooks, params
│   │   └── install.fish  # Installation script
│   ├── nvim/
│   │   ├── module.yaml
│   │   ├── install.fish
│   │   └── setup-plugins.fish
│   └── hyprland/
│       ├── module.yaml
│       └── install.fish
│
├── profiles/             # Composable configuration profiles
│   ├── base/
│   │   ├── fedpunk.yaml  # Profile manifest (lists modules)
│   │   └── modes/        # Mode-specific settings
│   │       ├── desktop.yaml
│   │       ├── laptop.yaml
│   │       └── container.yaml
│   └── dev/
│       └── fedpunk.yaml  # Inherits base, adds dev modules
│
├── lib/                  # Shared libraries
│   ├── helpers.fish      # Logging, installation helpers
│   └── modules.fish      # Module loader/executor
│
├── home/                 # Chezmoi source directory
│   ├── .chezmoi.toml.tmpl           # Template engine
│   ├── run_before_install.fish.tmpl # Execute before_apply hooks
│   ├── run_once_after_setup.fish.tmpl # Execute after_apply hooks
│   └── dot_config/                  # Dotfiles
│
└── themes/               # Theme definitions
    ├── ayu-mirage/
    ├── tokyo-night/
    └── ...
```

### How It Works

```
┌─────────────────────────────────────────────────────────────┐
│ 1. chezmoi init --apply                                      │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│ 2. .chezmoi.toml.tmpl processes                             │
│    ├─ Detects/prompts for mode (desktop/laptop/container)   │
│    ├─ Loads profile manifest (profiles/<profile>/fedpunk.yaml)│
│    ├─ Resolves module dependencies                          │
│    ├─ Merges module parameters                              │
│    └─ Builds execution plan (hooks + env vars)              │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│ 3. run_before_install.fish executes                         │
│    └─ Runs before_apply hooks for each module               │
│       ├─ core:install.fish (DNF, Fish, Git, Cargo, Gum)     │
│       ├─ cli-tools:install.fish (ripgrep, fd, bat, eza)     │
│       ├─ tmux:install.fish                                  │
│       ├─ nvim:install.fish                                  │
│       ├─ languages:install.fish (Node, Python, Go)          │
│       └─ hyprland:install.fish (desktop/laptop only)        │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│ 4. chezmoi apply                                            │
│    └─ Deploys dotfiles to ~/.config/                        │
└─────────────────────┬───────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────┐
│ 5. run_once_after_setup.fish executes                       │
│    └─ Runs after_apply hooks for each module                │
│       ├─ tmux:setup-plugins.fish (TPM setup)                │
│       ├─ nvim:setup-plugins.fish (lazy.nvim)                │
│       └─ ... (other post-installation tasks)                │
└─────────────────────────────────────────────────────────────┘
```

---

## Profiles

Profiles are collections of modules with specific configurations. They define **what** gets installed and **how** it's configured.

### Profile Manifest

**profiles/dev/fedpunk.yaml:**
```yaml
profile:
  name: dev
  description: Development environment with containers and tools
  author: hinriksnaer
  version: 1.0.0

# Inherit modules from another profile
inherit: base

# Additional modules for this profile
modules:
  - podman
  - git-tools
  - claude

# Override module parameters
module_params:
  languages:
    install_rust: true  # Base has false, dev enables Rust

  podman:
    setup_rootless: true
    install_compose: true
```

### Profile Inheritance

Profiles can inherit from other profiles:

```yaml
# base profile provides: core, cli-tools, tmux, nvim, languages
inherit: base

# dev profile adds: podman, git-tools, claude
# Final module list: core, cli-tools, tmux, nvim, languages, podman, git-tools, claude
```

**Inheritance rules:**
- Modules are merged (base + profile)
- Module parameters can be overridden
- Mode-specific modules are additive
- Profile's parameters take precedence over base

### Mode-Specific Modules

Profiles can specify modules that only load in certain modes:

```yaml
modules:
  - core      # Loads in all modes
  - tmux      # Loads in all modes
  - nvim      # Loads in all modes

mode_modules:
  desktop:
    - hyprland   # Only in desktop mode
    - kitty      # Only in desktop mode

  laptop:
    - hyprland   # Only in laptop mode
    - kitty      # Only in laptop mode

  container:
    # No additional modules in container mode
```

---

## Modules

Modules are self-contained units of functionality. Each module can:
- Install packages
- Configure services
- Run setup tasks
- Declare dependencies
- Accept parameters
- Auto-detect hardware

### Module Structure

**modules/nvim/module.yaml:**
```yaml
module:
  name: nvim
  description: Neovim text editor with lazy.nvim plugin manager

# Dependencies (installed first)
depends:
  - core        # Requires core system setup
  - languages   # Requires LSP support

# Module parameters (can be overridden in profiles)
params:
  package_name: neovim    # DNF package name
  setup_plugins: true     # Install lazy.nvim

# Installation hooks
hooks:
  before_apply:
    - install.fish          # Runs before configs deployed
  after_apply:
    - setup-plugins.fish    # Runs after configs deployed

# Mode availability
modes:
  container:
    enabled: true
  desktop:
    enabled: true
  laptop:
    enabled: true
```

**modules/nvim/install.fish:**
```fish
#!/usr/bin/env fish
# NVIM MODULE: Install Neovim

source "$FEDPUNK_LIB_PATH/helpers.fish"

subsection "Installing Neovim"

# Access module parameter
set -q FEDPUNK_MODULE_NVIM_PACKAGE_NAME; or set FEDPUNK_MODULE_NVIM_PACKAGE_NAME "neovim"

install_if_missing nvim $FEDPUNK_MODULE_NVIM_PACKAGE_NAME

success "Neovim installed"
```

### Built-in Modules

| Module | Description | Dependencies | Hooks |
|--------|-------------|--------------|-------|
| **core** | System essentials (DNF, Fish, Git, Cargo, Gum) | None | before_apply |
| **cli-tools** | CLI utilities (ripgrep, fd, bat, eza, fzf) | core | before_apply |
| **tmux** | Terminal multiplexer with TPM | core | before_apply, after_apply |
| **nvim** | Neovim with lazy.nvim | core, languages | before_apply, after_apply |
| **languages** | Programming toolchains (Node, Python, Go) | core | before_apply |
| **hyprland** | Wayland compositor | core | before_apply |
| **nvidia** | NVIDIA proprietary drivers (auto-detects GPU) | core | before_apply |

### Module Parameters

Parameters allow customizing module behavior from profiles:

**In module.yaml:**
```yaml
params:
  install_nodejs: true
  install_python: true
  install_go: true
  install_rust: false  # Default: disabled
```

**Override in profile:**
```yaml
module_params:
  languages:
    install_rust: true  # Enable Rust
```

**Access in module script:**
```fish
# Exported as FEDPUNK_MODULE_<MODULE>_<PARAM>
set -q FEDPUNK_MODULE_LANGUAGES_INSTALL_RUST; or set FEDPUNK_MODULE_LANGUAGES_INSTALL_RUST "false"

if test "$FEDPUNK_MODULE_LANGUAGES_INSTALL_RUST" = "true"
    install_packages rust cargo
end
```

### Auto-Detection

Modules can auto-detect hardware and prompt for installation:

**modules/nvidia/module.yaml:**
```yaml
auto_detect:
  command: "lspci | grep -i nvidia >/dev/null 2>&1"
  prompt: "NVIDIA GPU detected. Install proprietary drivers?"
  default: "yes"
```

The module loader checks the command. If it succeeds, it prompts the user (using `gum confirm`).

---

## Modes

Modes determine which components get installed based on your environment.

### Mode Configuration

**profiles/base/modes/desktop.yaml:**
```yaml
mode:
  name: desktop
  description: Full desktop environment with all development tools

# Module-specific settings (exported as FEDPUNK_MODULE_<MODULE>_<KEY>)
module_config:
  core:
    system_upgrade: true
    firmware_update: true

  hyprland:
    enable_copr: true
    install_extras: true

  multimedia:
    install_codecs: true
    enable_hw_accel: true
```

### Mode Detection

Auto-detection priority:
1. **Explicit**: `FEDPUNK_MODE=desktop` environment variable
2. **Interactive**: Prompts user to choose (if terminal is interactive)
3. **Auto-detect**:
   - Container: Checks for `/.dockerenv`, `/run/.containerenv`, or `$CONTAINER` env
   - Laptop: Checks for `/sys/class/power_supply/BAT0`
   - Desktop: Default fallback

---

## Creating Modules

### Step 1: Create Module Directory

```bash
mkdir -p modules/my-module
```

### Step 2: Define Module Manifest

**modules/my-module/module.yaml:**
```yaml
module:
  name: my-module
  description: Brief description of what this module does

# Dependencies
depends:
  - core  # List modules that must run before this one

# Parameters with defaults
params:
  some_option: true
  package_name: "my-package"

# Hooks
hooks:
  before_apply:
    - install.fish
  after_apply:
    - configure.fish

# Mode availability
modes:
  container:
    enabled: true
  desktop:
    enabled: true
  laptop:
    enabled: true
```

### Step 3: Create Installation Script

**modules/my-module/install.fish:**
```fish
#!/usr/bin/env fish
# MY-MODULE: Install packages

source "$FEDPUNK_LIB_PATH/helpers.fish"

subsection "Installing my-module"

# Access parameters
set -q FEDPUNK_MODULE_MY_MODULE_PACKAGE_NAME; or set FEDPUNK_MODULE_MY_MODULE_PACKAGE_NAME "my-package"

# Use helper functions
install_if_missing my-command $FEDPUNK_MODULE_MY_MODULE_PACKAGE_NAME

success "my-module installed"
```

### Step 4: Add to Profile

**profiles/my-profile/fedpunk.yaml:**
```yaml
modules:
  - my-module
```

### Helper Functions Reference

Available in all module scripts (via `$FEDPUNK_LIB_PATH/helpers.fish`):

```fish
# Logging
section "Section Title"          # Major section header
subsection "Subsection Title"    # Minor section header
info "Info message"              # Informational message
success "Success message"        # Success indicator
warning "Warning message"        # Warning indicator
error "Error message"            # Error indicator
box "Boxed message" $GUM_SUCCESS # Boxed message with style

# Installation
install_packages pkg1 pkg2 ...   # Install multiple packages with DNF
install_if_missing cmd pkg       # Install pkg if cmd not found
step "Description" "command"     # Run command with spinner + logging

# System detection
detect_gpu                       # Returns: nvidia, amd, intel, or unknown
get_cpu_cores                    # Returns: number of CPU cores

# User interaction
confirm "Question?" "yes"        # Prompt yes/no (requires gum)
```

---

## Creating Profiles

### Step 1: Create Profile Directory

```bash
mkdir -p profiles/my-profile/modes
```

### Step 2: Create Profile Manifest

**profiles/my-profile/fedpunk.yaml:**
```yaml
profile:
  name: my-profile
  description: Custom profile for my use case
  author: your-name
  version: 1.0.0

# Optionally inherit from another profile
inherit: base

# List modules to include
modules:
  - core
  - tmux
  - nvim
  - my-custom-module

# Mode-specific modules
mode_modules:
  desktop:
    - hyprland
    - kitty

  laptop:
    - hyprland
    - kitty

  container:
    # Container mode has no additional modules

# Override module parameters
module_params:
  nvim:
    setup_plugins: true

  tmux:
    setup_tpm: true

  languages:
    install_nodejs: true
    install_python: true
    install_go: true
```

### Step 3: Create Mode Configurations

**profiles/my-profile/modes/desktop.yaml:**
```yaml
mode:
  name: desktop
  description: Full desktop environment

module_config:
  core:
    system_upgrade: true
    firmware_update: true

  hyprland:
    enable_copr: true
    install_extras: true
```

**profiles/my-profile/modes/laptop.yaml:**
```yaml
mode:
  name: laptop
  description: Desktop with power optimizations

module_config:
  core:
    system_upgrade: true
    firmware_update: true

  hyprland:
    enable_copr: true
    install_extras: true
```

**profiles/my-profile/modes/container.yaml:**
```yaml
mode:
  name: container
  description: Minimal terminal environment

module_config:
  core:
    system_upgrade: false
    firmware_update: false
```

### Step 4: Use Your Profile

```bash
FEDPUNK_PROFILE=my-profile chezmoi init --apply <repo>
```

---

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `FEDPUNK_MODE` | auto-detect | Force mode: `desktop`, `laptop`, or `container` |
| `FEDPUNK_PROFILE` | `dev` | Profile to use |
| `FEDPUNK_NON_INTERACTIVE` | - | Skip interactive prompts, use auto-detection |

### Runtime Paths

During installation, these variables are available:

| Variable | Value | Description |
|----------|-------|-------------|
| `$FEDPUNK_PATH` | Repository root | Base path to fedpunk |
| `$FEDPUNK_LIB_PATH` | `$FEDPUNK_PATH/lib` | Helper libraries |
| `$FEDPUNK_MODE` | Mode name | Current mode |
| `$FEDPUNK_PROFILE_PATH` | Profile directory | Path to active profile |
| `$FEDPUNK_CURRENT_MODULE` | Module name | Currently executing module |
| `$FEDPUNK_MODULE_PATH` | Module directory | Path to current module |

### Module Environment Variables

Module parameters are exported as:
```
FEDPUNK_MODULE_<MODULE_NAME>_<PARAMETER_NAME>
```

Examples:
```fish
FEDPUNK_MODULE_NVIM_SETUP_PLUGINS=true
FEDPUNK_MODULE_TMUX_SETUP_TPM=true
FEDPUNK_MODULE_LANGUAGES_INSTALL_NODEJS=true
```

---

## Themes

Fedpunk includes 11 curated themes that update all applications simultaneously.

### Theme Management

```fish
fedpunk-theme-list              # List all themes
fedpunk-theme-current           # Show current theme
fedpunk-theme-set <name>        # Switch to specific theme
fedpunk-theme-set-desktop <name> # Desktop apps only
fedpunk-theme-set-terminal <name> # Terminal apps only
```

### Available Themes

- **aetheria** - Ethereal purple and blue gradients
- **ayu-mirage** - Warm, muted desert tones (default)
- **catppuccin** - Soothing pastel palette (mocha)
- **catppuccin-latte** - Light mode variant
- **matte-black** - Pure minimalist black
- **nord** - Arctic-inspired cool tones
- **osaka-jade** - Vibrant teal and green
- **ristretto** - Rich espresso browns
- **rose-pine** - Soft rose and pine palette
- **tokyo-night** - Deep blues with neon accents
- **torrentz-hydra** - Bold contrast scheme

### What Themes Control

- **Hyprland** - Border colors, gaps, decorations
- **Kitty** - Terminal colors (live reload)
- **Neovim** - Editor colorscheme (live reload)
- **btop** - System monitor colors (live reload)
- **tmux** - Status bar theme
- **Rofi** - Launcher appearance
- **Mako** - Notification styling
- **Wallpapers** - Per-theme backgrounds

---

## Troubleshooting

### Debugging Installation

All installation logs are saved:
```bash
# View installation logs
tail -f /tmp/fedpunk-install-*.log
tail -f /tmp/fedpunk-after-*.log
```

### Module Execution

Check which modules are loaded:
```bash
chezmoi data | jq '.profile.modules'
chezmoi data | jq '.profile.before_apply_hooks'
chezmoi data | jq '.profile.after_apply_hooks'
```

### Module Parameters

Check exported parameters for a module:
```bash
chezmoi data | jq '.module.nvim'
chezmoi data | jq '.module.languages'
```

### Re-running Installation

```bash
# Force re-init (re-runs all installation)
rm -rf ~/.local/share/chezmoi ~/.config/chezmoi
FEDPUNK_MODE=desktop FEDPUNK_PROFILE=dev chezmoi init --apply <repo>

# Update existing installation
chezmoi update
```

### Common Issues

**Fish not available:**
```bash
exec fish  # Or restart terminal
```

**Hyprland won't start:**
```bash
# Check driver issues
dmesg | grep -i error

# NVIDIA users
lsmod | grep nvidia

# Check logs
cat /tmp/hypr/$(ls -t /tmp/hypr/ | head -1)/hyprland.log
```

**Module failed to install:**
```bash
# Check module script directly
cd /path/to/fedpunk
source lib/helpers.fish
fish modules/<module>/install.fish
```

---

## Reference

### Module Manifest Schema

```yaml
module:
  name: string              # Module identifier (kebab-case)
  description: string       # Brief description

depends: [string]           # List of module dependencies

params:                     # Default parameters
  param_name: value         # Can be overridden in profiles

hooks:
  before_apply: [string]    # Scripts run before config deployment
  after_apply: [string]     # Scripts run after config deployment
  on_change: [string]       # Scripts run when files change

auto_detect:                # Optional auto-detection
  command: string           # Shell command to detect (exit 0 = detected)
  prompt: string            # Question to ask user
  default: string           # Default answer (yes/no)

modes:                      # Mode availability
  container:
    enabled: bool
  desktop:
    enabled: bool
  laptop:
    enabled: bool
```

### Profile Manifest Schema

```yaml
profile:
  name: string              # Profile identifier
  description: string       # Brief description
  author: string            # Author name
  version: string           # Semantic version

inherit: string|null        # Base profile to inherit from

modules: [string]           # List of modules to include

mode_modules:               # Mode-specific modules
  desktop: [string]
  laptop: [string]
  container: [string]

module_params:              # Module parameter overrides
  module-name:
    param_name: value
```

### Execution Hooks

Hooks are strings in the format `"module:script"`:
```toml
before_apply_hooks = ["core:install.fish", "nvim:install.fish"]
after_apply_hooks = ["nvim:setup-plugins.fish", "tmux:setup-plugins.fish"]
```

Split and execute:
```fish
set parts (string split ":" $hookStr)
set moduleName (index $parts 0)
set script (index $parts 1)
execute_module_hook $moduleName $script "before_apply"
```

---

## Philosophy

Fedpunk is built around core principles:

- **Modular** - Functionality organized into composable modules
- **Declarative** - Profiles declare intent, modules handle implementation
- **Idempotent** - Safe to run multiple times
- **Mode-aware** - Adapts to environment (desktop/laptop/container)
- **Parameter-driven** - Customizable without code changes
- **Dependency-aware** - Modules declare and resolve dependencies
- **Keyboard-first** - Mouse optional, everything via keybindings
- **Aesthetic** - Beautiful themes across all applications

---

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/new-module`
3. Test in a VM or container
4. Submit a pull request

**Contribution areas:**
- New modules (databases, editors, tools)
- New profiles (specialized workflows)
- New themes
- Documentation improvements
- Bug fixes

**Module contribution checklist:**
- [ ] `module.yaml` with complete metadata
- [ ] Installation script with error handling
- [ ] Uses helper functions from `lib/helpers.fish`
- [ ] Declares all dependencies
- [ ] Mode-awareness configured
- [ ] Parameters documented
- [ ] Tested in all applicable modes

---

## License

MIT License - See LICENSE file for details

---

**Fedpunk - Modular, composable Fedora configuration**
