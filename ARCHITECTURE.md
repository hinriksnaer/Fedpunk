# Fedpunk Architecture

**Last Updated:** 2025-01-20
**Current System:** Module-based with GNU Stow deployment

---

## Design Philosophy

Fedpunk uses a **modular, plugin-based architecture** that enables:
- Clean separation of concerns (each package is a self-contained module)
- Profile-based customization with mode selection
- Fast deployment using GNU Stow
- Extensibility through profile plugins

This is the **source of truth** for Fedpunk's architecture. All implementation should align with this document.

---

## System Overview

```
┌─────────────────────────────────────────────┐
│  Bootstrap (boot.sh)                        │
│  ├─ Install: git, fish, stow, gum          │
│  └─ Execute: install.fish                   │
├─────────────────────────────────────────────┤
│  Module System (lib/fish/)                  │
│  ├─ TOML parser                             │
│  ├─ Module manager                          │
│  ├─ UI abstraction (gum wrapper)            │
│  └─ Installer orchestrator                  │
├─────────────────────────────────────────────┤
│  Modules (modules/<package>/)               │
│  ├─ module.toml - metadata & config         │
│  ├─ config/ - dotfiles (stowed to $HOME)    │
│  └─ scripts/ - lifecycle hooks              │
├─────────────────────────────────────────────┤
│  Profiles (profiles/<name>/)                │
│  ├─ modes/ - module lists per environment   │
│  └─ plugins/ - profile-specific modules     │
└─────────────────────────────────────────────┘
```

---

## Module System

### Module Structure

Every module follows this standardized structure:

```
modules/<package>/
├── module.toml          # Module metadata
├── config/              # Dotfiles to stow
│   └── .config/...      # XDG-compliant paths
└── scripts/             # Lifecycle hooks (optional)
    ├── install
    ├── update
    ├── before
    └── after
```

### module.toml Schema

```toml
[module]
name = "package-name"
description = "Human-readable description"
dependencies = ["dep1", "dep2"]  # Other modules required
priority = 10                     # Execution order (lower = earlier)

[lifecycle]
install = ["script-name"]        # Runs during installation
update = ["script-name"]         # Runs on update
before = ["script-name"]         # Pre-stow hook
after = ["script-name"]          # Post-stow hook

[packages]
copr = ["repo/name"]             # COPR repos to enable
dnf = ["package1", "package2"]   # DNF packages
cargo = ["tool"]                 # Cargo packages
npm = ["package"]                # NPM packages
flatpak = ["app.id"]             # Flatpak packages

[stow]
target = "$HOME"
conflicts = "warn"  # warn, skip, or overwrite
```

### Deployment Flow

1. **Dependency Resolution** (automatic, recursive)
   - Check module's `dependencies` array
   - Deploy each dependency if not already deployed
   - Prevents duplicate deployments in same session
   - Handles transitive dependencies (dep of dep)

2. **Package Installation** (auto from module.toml)
   - Enable COPR repos
   - Install DNF packages
   - Install cargo/npm/flatpak packages

3. **Lifecycle: install**
   - Custom installation logic
   - System configuration

4. **Lifecycle: before**
   - Pre-deployment setup

5. **Stow Deployment**
   - Symlink `config/` to `$HOME`

6. **Lifecycle: after**
   - Post-deployment configuration
   - Plugin installation

### Dependency Resolution

Dependencies are declared in module.toml and automatically resolved:

```toml
[module]
name = "fish"
dependencies = ["rust"]  # Rust will be deployed before fish
```

**How it works:**
- Before deploying a module, check its `dependencies` array
- Deploy each dependency recursively (handling transitive deps)
- Track deployed modules to prevent duplicates
- Fail-fast if a dependency is missing or fails

**Example dependency chain:**
```
User requests: fish
  → fish depends on: rust
    → rust depends on: (none)
    → Deploy rust first
  → Deploy fish second
```

**Benefits:**
- No need to manually list dependencies in profile modes
- Modules are self-documenting (declare what they need)
- Prevents deployment order issues
- Handles complex dependency trees automatically

---

## Profile System

### Structure

```
profiles/<profile-name>/
├── modes/
│   ├── desktop.toml    # Full desktop environment
│   ├── container.toml  # Minimal container setup
│   └── work.toml       # Custom mode
└── plugins/
    └── <module-structure>  # Profile-specific modules
```

### Mode Configuration

```toml
[mode]
name = "desktop"
description = "Full desktop environment with GUI"

[modules]
# Execution order = array order
enabled = [
    "fish",
    "neovim",
    "hyprland",
    "kitty"
]
```

### Profile Plugins

Plugins are modules scoped to a specific profile. They follow the exact same structure as global modules but are stored in `profiles/<name>/plugins/`.

**Use cases:**
- Work-specific tools
- Personal customizations
- Experimental features

---

## Bootstrap Process

### boot.sh (Minimal)

Only installs what's needed to run the module system:
- `git` - Clone repository
- `fish` - Run installer
- `stow` - Deploy configs
- `gum` - UI feedback

### install.fish (Orchestrator)

1. Load module system (`lib/fish/`)
2. Interactive profile/mode selection (via gum)
3. Read mode TOML for enabled modules
4. Deploy modules in order
5. Fail-fast on errors

---

## Infrastructure

### lib/fish/

- **toml-parser.fish** - Lightweight awk-based TOML parser
- **fedpunk-module.fish** - Module deployment commands
- **installer.fish** - Installation orchestrator
- **ui.fish** - Gum wrapper for UI abstraction

### Commands

```fish
# Module management
fedpunk module list                    # List all modules
fedpunk module info <name>             # Show module details
fedpunk module deploy <name>           # Full deployment
fedpunk module stow <name>             # Config only
fedpunk module install-packages <name> # Packages only
fedpunk module run-lifecycle <name> <hook>  # Run specific hook
```

---

## Key Design Decisions

### Why GNU Stow over Chezmoi?

**Stow Advantages:**
- ✅ Simple, standard tool
- ✅ No templating complexity
- ✅ Modular by design (multiple packages can contribute to same directory)
- ✅ Instant deployment (no generation step)
- ✅ Easy to understand and debug

**Trade-offs:**
- ❌ No built-in templating (use lifecycle scripts instead)
- ✅ This is acceptable - most "templates" are really environment detection

### Why Profile Modes?

Allows one profile to support multiple environments:
- `dev/desktop` - Full GUI environment
- `dev/container` - Minimal for devcontainers
- `dev/work` - Work-specific tools

### Why Lifecycle Scripts?

Provides flexibility for:
- Custom installation logic (e.g., downloading binaries)
- System configuration (e.g., `chsh`, enabling services)
- Plugin installation (e.g., fisher, tmux plugins)
- Environment detection and setup

### Why UI Abstraction?

- Wraps `gum` for easy refactoring
- Fallbacks for non-interactive environments
- Consistent UI across all scripts
- Major changes don't require code updates

---

## Example: Fish Module

```
modules/fish/
├── module.toml
├── config/
│   └── .config/fish/
│       ├── config.fish
│       ├── conf.d/
│       └── functions/
└── scripts/
    ├── install       # set default shell
    └── setup-fisher  # fisher + plugins
```

**Demonstrates:**
- Package management (DNF + COPR)
- Lifecycle hooks
- Config deployment via stow
- Plugin setup in after hook

---

## Future Direction

### Planned Features
- Module validation command
- Module marketplace/registry
- Profile import/export
- Migration helpers
- Circular dependency detection

### Not Planned
- Complex templating (use scripts instead)
- GUI installer (CLI with gum is sufficient)
- Windows support (Fedora-specific)

---

## Migration Notes

**Migration History:**
- System fully migrated from chezmoi to GNU Stow for config deployment
- New system uses modular approach with stow
- Profiles changed from install-based to mode-based
- See `docs/design/DOTFILE_MODULES.md` for detailed design

---

## References

- **Detailed Design:** `docs/design/DOTFILE_MODULES.md`
- **Installation Guide:** `docs/guides/installation.md`
- **Contributing:** `docs/development/contributing.md`
