# Dotfile Module System Design

## Overview

Custom modular dotfile management system using GNU Stow for deployment. Replaces chezmoi with a more flexible, modular approach.

## Architecture

### Module Structure

```
modules/<package>/
├── module.toml          # Module metadata, dependencies, lifecycle config
├── config/              # Dotfiles to be stowed to $HOME
│   └── .config/...     # Follows XDG directory structure
└── scripts/             # Optional lifecycle hooks
    ├── install         # System package installation
    ├── update          # Update packages/plugins
    ├── before          # Pre-deployment hook
    └── after           # Post-deployment hook
```

### Module TOML Schema

```toml
[module]
name = "fish"
description = "Fish shell with modern tooling"
version = "1.0.0"
dependencies = ["starship", "fisher"]  # Other modules required
priority = 10  # Execution order (lower = earlier)

[lifecycle]
# Declares which lifecycle hooks are implemented
install = true   # Has scripts/install
update = true    # Has scripts/update
before = true    # Has scripts/before
after = true     # Has scripts/after

[packages]
# System packages to install
dnf = ["fish"]
cargo = []
npm = []
flatpak = []

[profile]
# Default availability in profiles
default = true
desktop = true
container = true

[stow]
# Stow-specific configuration
target = "$HOME"
conflicts = "warn"  # warn, skip, or overwrite
```

### Profile Integration

```
profiles/dev/
├── fedpunk.toml         # Profile metadata (existing)
└── modules.toml         # Module toggles

# modules.toml example:
[modules]
fish = true
neovim = true
tmux = true
hyprland = false  # Disabled in this profile
kitty = false
```

## Lifecycle Execution Model

### Dependency Resolution

1. Build dependency graph from module.toml files
2. Topological sort to determine execution order
3. Within same dependency level, sort by priority field
4. Execute lifecycle hooks in resolved order

### Lifecycle Phases

```
1. RESOLVE
   - Read all module.toml files
   - Build dependency graph
   - Check for circular dependencies
   - Filter by active profile

2. INSTALL (if --install flag)
   - For each module in order:
     - Run scripts/install (if lifecycle.install = true)
     - Install packages from [packages] section

3. BEFORE
   - For each module in order:
     - Run scripts/before (if lifecycle.before = true)

4. STOW
   - For each module in order:
     - Run: stow -d modules -t $HOME <package>
     - Handle conflicts based on stow.conflicts setting

5. AFTER
   - For each module in order:
     - Run scripts/after (if lifecycle.after = true)

6. UPDATE (if --update flag)
   - For each module in order:
     - Run scripts/update (if lifecycle.update = true)
```

### Script Interface

All lifecycle scripts receive environment variables:

```bash
#!/usr/bin/env bash
# Available environment variables:
# - MODULE_NAME: Module name
# - MODULE_DIR: Module directory path
# - PROFILE: Active profile name
# - FEDPUNK_ROOT: Repository root
# - HOME: User home directory
# - STOW_TARGET: Stow target directory (usually $HOME)
```

## Command Interface

```fish
# Module management
fedpunk module list                    # List all available modules
fedpunk module list --enabled          # List enabled modules in current profile
fedpunk module status <name>           # Show module status
fedpunk module deps <name>             # Show dependency tree

# Deployment
fedpunk module install <name>          # Install system packages only
fedpunk module stow <name>             # Deploy config only
fedpunk module deploy <name>           # Full: install + before + stow + after
fedpunk module deploy --all            # Deploy all enabled modules

# Updates
fedpunk module update <name>           # Run update hook
fedpunk module update --all            # Update all modules

# Removal
fedpunk module unstow <name>           # Remove symlinks
fedpunk module remove <name>           # Unstow + cleanup

# Profile integration
fedpunk module enable <name>           # Enable in current profile
fedpunk module disable <name>          # Disable in current profile

# Development
fedpunk module validate <name>         # Validate module.toml
fedpunk module create <name>           # Scaffold new module
```

## Migration from Chezmoi

### Phase 1: Parallel Operation
- Keep chezmoi for base configs
- Gradually move modules to new system
- Use both systems during transition

### Phase 2: Module Migration
For each component (fish, neovim, tmux, etc.):
1. Create modules/<name>/ directory
2. Move home/dot_config/<name> to modules/<name>/config/.config/<name>
3. Extract install logic to modules/<name>/scripts/install
4. Create module.toml
5. Test stow deployment
6. Update profile modules.toml

### Phase 3: Chezmoi Removal
- Migrate all remaining configs
- Remove chezmoi dependency
- Update boot scripts

## Example: Fish Module

```
modules/fish/
├── module.toml
├── config/
│   ├── .config/
│   │   └── fish/
│   │       ├── config.fish
│   │       ├── functions/
│   │       └── conf.d/
└── scripts/
    ├── install
    ├── update
    └── after

# module.toml
[module]
name = "fish"
description = "Fish shell with modern tooling"
dependencies = []
priority = 5

[lifecycle]
install = true
update = true
after = true

[packages]
dnf = ["fish"]

[profile]
default = true
desktop = true
container = true

# scripts/install
#!/usr/bin/env fish
sudo dnf install -y fish
chsh -s /usr/bin/fish

# scripts/update
#!/usr/bin/env fish
fisher update

# scripts/after
#!/usr/bin/env fish
# Install fisher plugins
fisher install jorgebucaran/fisher
```

## Benefits

1. **Modularity**: Each package is self-contained
2. **Flexibility**: Enable/disable per profile
3. **Transparency**: Clear lifecycle hooks
4. **Simplicity**: No templating complexity
5. **Standards**: Uses GNU Stow (standard tool)
6. **Speed**: Stow is instant, no generation step
7. **Portability**: Works on any Linux with stow
8. **Debuggability**: Simple shell scripts

## Trade-offs

1. **No templating**: Can't generate configs based on system
   - Solution: Use scripts/after for dynamic setup
2. **Manual dependency management**: Must define in TOML
   - Solution: Validation checks dependencies
3. **More files**: Each module has multiple files
   - Solution: Better organization, easier to maintain
