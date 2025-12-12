# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Fedpunk is a modular configuration management system for Fedora Linux, built entirely in Fish shell. It provides a complete desktop environment based on Hyprland (Wayland compositor) with vim-style keybindings, live theming, and a plugin architecture for extensibility.

**Core Philosophy:**
- Modular architecture with automatic dependency resolution
- Profile-based configuration (desktop/container/custom modes)
- GNU Stow for instant symlink-based deployment (no generation step)
- Fish-first shell experience with modern tooling
- External module support (git URLs, local paths, profile plugins)

## Build and Test Commands

### Local Development

```fish
# Install Fedpunk from local checkout
fish install.fish

# Install with specific profile and mode
fish install.fish --profile default --mode desktop
fish install.fish --profile default --mode container

# Module management
fedpunk module list                    # List all modules
fedpunk module info <name>             # Show module details
fedpunk module deploy <name>           # Full deployment (deps + packages + config)
fedpunk module stow <name>             # Config only (symlink with stow)
fedpunk module unstow <name>           # Remove symlinks
fedpunk module install-packages <name> # Packages only
fedpunk module run-lifecycle <name> <hook>  # Run specific lifecycle hook
```

### Testing

```bash
# Build RPM package for local testing
bash test/build-rpm.sh

# Test RPM installation
bash test/test-rpm-install.sh

# Run specific workflow tests locally (requires container runtime)
# See .github/workflows/ for available tests:
# - test-default-container.yml
# - test-default-desktop.yml
# - test-dev-desktop.yml
# - test-rpm-build.yml
```

### Installation Paths

Fedpunk supports two installation modes that are auto-detected:

1. **DNF/RPM installation** (COPR packages):
   - System files: `/usr/share/fedpunk/`
   - User data: `~/.local/share/fedpunk/`
   - Environment variables set via `/etc/profile.d/fedpunk.sh`

2. **Git clone installation** (traditional):
   - All files: `~/.local/share/fedpunk/`
   - Environment variables set by Fish during shell initialization

The `lib/fish/paths.fish` library automatically detects which mode is active and sets `FEDPUNK_SYSTEM`, `FEDPUNK_USER`, and `FEDPUNK_ROOT` accordingly.

## Architecture

### Module System

Every component (neovim, tmux, hyprland, etc.) is a self-contained module with:

**Directory Structure:**
```
modules/<package>/
├── module.yaml          # Metadata, dependencies, parameters, packages
├── config/              # Dotfiles (stowed to $HOME via symlinks)
│   └── .config/...
├── cli/                 # Optional CLI commands
│   └── <package>/
│       └── <package>.fish
└── scripts/             # Optional lifecycle hooks
    ├── install          # Custom installation logic
    ├── before           # Pre-deployment hook
    └── after            # Post-deployment hook (plugins, services)
```

**module.yaml schema:**
```yaml
module:
  name: fish
  description: Fish shell with modern tooling
  dependencies:
    - rust      # Modules required before this one
  priority: 10  # Execution order (lower = earlier)

parameters:          # Optional: define module parameters
  param_name:
    type: string
    description: Parameter description
    default: value
    required: false

lifecycle:
  before: []         # Hook names to run before stow
  after:
    - install        # Hook names to run after stow

packages:
  copr:              # COPR repositories
    - atim/starship
  dnf:               # DNF packages
    - fish
  cargo: []          # Cargo packages
  npm: []            # NPM packages
  flatpak: []        # Flatpak packages

stow:
  target: $HOME
  conflicts: warn    # warn, skip, or overwrite
```

### Deployment Flow

1. **Profile/Mode Selection** - Choose profile (default/dev/example) and mode (desktop/container)
2. **Module List Resolution** - Load module list from `profiles/<name>/modes/<mode>/mode.yaml`
3. **External Module Resolution** - Clone/cache git URLs, resolve local paths, locate profile plugins
4. **Dependency Resolution** - Recursive topological sort, prevents duplicates
5. **Parameter Injection** - Generate Fish config for module parameters
6. **Package Installation** - DNF, COPR, Cargo, NPM, Flatpak from module.yaml
7. **Lifecycle: before** - Pre-deployment hooks
8. **GNU Stow Deployment** - Symlink `config/` directories to `$HOME`
9. **Lifecycle: after** - Post-deployment hooks (plugins, services, etc.)

**Key Design Decision:** GNU Stow provides instant deployment via symlinks. Editing a file in `modules/neovim/config/.config/nvim/` immediately affects `~/.config/nvim/` with no generation step.

### Profile System

**Three built-in profiles:**
- `default` - General-purpose setup (recommended for most users)
- `dev` - Personal reference implementation (example of advanced features)
- `example` - Template for creating custom profiles

**Each profile supports multiple modes:**
```
profiles/default/
├── modes/
│   ├── desktop/
│   │   └── mode.yaml      # Full desktop environment
│   └── container/
│       └── mode.yaml      # Terminal-only for containers
└── plugins/               # Profile-specific modules (optional)
    └── custom-module/
        ├── module.yaml
        └── config/
```

**mode.yaml structure:**
```yaml
mode:
  name: desktop
  description: Full desktop environment

modules:
  - essentials                            # Built-in module
  - neovim
  - plugins/custom-module                 # Profile plugin
  - ~/gits/my-module                      # Local path
  - https://github.com/org/module.git     # External git URL

  # With parameters
  - module: https://github.com/org/jira.git
    params:
      team_name: "platform"
      jira_url: "https://company.atlassian.net"
```

### External Module Support

Modules can be referenced from:
- **Built-in**: `modules/<name>/` (shipped with Fedpunk)
- **Profile plugins**: `plugins/<name>` (relative to profile directory)
- **Local paths**: `~/gits/module` or `/absolute/path`
- **Git URLs**: `https://github.com/org/repo.git` or `git@github.com:org/repo.git`

External modules are cached in `~/.fedpunk/cache/external/<host>/<org>/<repo>/`

### Parameter System

Modules can define parameters, profiles provide values, and Fedpunk generates Fish environment variables:

**Module defines (module.yaml):**
```yaml
parameters:
  api_endpoint:
    type: string
    required: true
    default: "https://api.example.com"
```

**Profile provides (mode.yaml):**
```yaml
modules:
  - module: my-api-tool
    params:
      api_endpoint: "https://custom.api.com"
```

**Fedpunk generates:**
```fish
# ~/.config/fish/conf.d/fedpunk-module-params.fish
set -gx FEDPUNK_PARAM_MY_API_TOOL_API_ENDPOINT "https://custom.api.com"
```

**Module accesses:**
```fish
echo $FEDPUNK_PARAM_MY_API_TOOL_API_ENDPOINT
```

## Core Libraries (lib/fish/)

The module system is built on these Fish libraries:

- **paths.fish** - Auto-detects DNF vs git installation, sets up environment variables
- **installer.fish** - Orchestrates profile/mode selection and module deployment
- **fedpunk-module.fish** - Main module management command (list, deploy, stow, etc.)
- **module-resolver.fish** - Resolves module paths (built-in, plugins, local, git URLs)
- **module-ref-parser.fish** - Parses module references with parameters from mode.yaml
- **external-modules.fish** - Handles cloning and caching of git-based modules
- **param-injector.fish** - Generates Fish environment variables from parameters
- **linker.fish** - GNU Stow wrapper for config deployment
- **yaml-parser.fish** - YAML parsing using yq
- **ui.fish** - gum wrapper for consistent UI (choose, confirm, input, etc.)

## Theme System

12 curated themes with live reload (no restart required):

**Theme switching:**
```fish
fedpunk-theme-set <name>    # Switch to specific theme
fedpunk-theme-next          # Cycle forward
fedpunk-theme-prev          # Cycle backward
```

**Keyboard shortcuts:**
- `Super+T` - Theme selection menu
- `Super+Shift+T` - Next theme
- `Super+Shift+Y` - Previous theme

**Theme structure:**
```
themes/<theme-name>/
├── kitty.conf          # Terminal colors (omarchy format)
├── hyprland.conf       # Compositor colors
├── rofi.rasi           # Launcher styling
├── btop.theme          # System monitor
├── mako.ini            # Notifications
├── neovim.lua          # Editor colorscheme
├── waybar.css          # Status bar
└── backgrounds/        # Wallpapers
```

Themes update across all applications via live reload (SIGUSR1/SIGUSR2 signals, hyprctl reload, Neovim RPC).

## RPM Packaging

**Spec file:** `fedpunk.spec`

Key features:
- Uses `{{{ git_dir_pack }}}` macro for COPR builds (rpkg template syntax)
- Falls back to standard `%autosetup` for local/CI builds
- Build script (`test/build-rpm.sh`) replaces templates appropriately
- Installs to `/usr/share/fedpunk/` with user data in `~/.local/share/fedpunk/`
- Creates wrapper script at `/usr/bin/fedpunk`
- Sets environment variables via `/etc/profile.d/fedpunk.sh`

**Building locally:**
```bash
bash test/build-rpm.sh          # Builds RPM in ~/rpmbuild/
bash test/test-rpm-install.sh   # Tests installation
```

## Important Conventions

### Fish Scripting
- Use 4 spaces for indentation
- Source dependencies at the top of each library file
- Use `set -l` for local variables, `set -g` for global
- Prefix Fedpunk functions with `fedpunk-` or `installer-` or `module-`
- Use descriptive variable names (`module_name`, not `mn`)

### Module Development
- Always define dependencies in `module.yaml` (even if empty: `dependencies: []`)
- Use lifecycle hooks for custom installation logic, not inline in packages
- Keep `config/` directory structure identical to target location (usually `$HOME`)
- CLI commands go in `cli/<package>/<package>.fish` and use Fish functions
- Test module deployment with `fedpunk module deploy <name>` before committing

### Profile Development
- Profile plugins should follow the same structure as built-in modules
- Use `plugins/` directory for profile-specific customizations
- External modules from git should be immutable (don't modify after cloning)
- Parameter names should be lowercase with underscores

### Error Handling
- Use `or return 1` after commands that might fail
- Echo errors to stderr with `>&2`
- Use `ui-error`, `ui-warn`, `ui-info` from ui.fish for consistency
- Validate module.yaml exists before parsing

### Stow Conflicts
- Default conflict handling is `warn` (shows warning, doesn't overwrite)
- Use `overwrite` only when module should take precedence
- Use `skip` for optional configs that shouldn't override existing files

## Common Gotchas

1. **Module path resolution**: Always use `module-resolve-path` to handle built-in, plugins, local, and git modules uniformly

2. **Stow targets**: All modules should use `target: $HOME` in module.yaml. Stow will preserve the directory structure from `config/`

3. **Lifecycle hook order**: `before` runs before stow, `after` runs after. Use `before` for prep work, `after` for plugin installation

4. **Dependency cycles**: Module resolver detects circular dependencies. If you see this error, check your module.yaml dependency chains

5. **External module caching**: Git modules are cloned once to `~/.fedpunk/cache/external/`. To update, delete the cache directory

6. **Parameter environment variables**: Parameters are UPPERCASE with module name prefix: `FEDPUNK_PARAM_<MODULE>_<PARAM>`

7. **DNF vs git installation**: Always use `FEDPUNK_SYSTEM` for system files and `FEDPUNK_USER` for user data. Never hardcode paths like `~/.local/share/fedpunk`

8. **Fish vs Bash**: Core libraries are Fish (faster, better syntax). Only `boot.sh` and lifecycle hooks can be Bash

## Testing Guidelines

- Test both DNF and git installation modes
- Test both desktop and container modes
- Verify module dependencies resolve correctly
- Check that stow symlinks are created in correct locations
- Ensure lifecycle hooks execute without errors
- Test theme switching if adding new themed components
- Verify external modules can be cloned and deployed
- Test parameter injection generates correct environment variables
