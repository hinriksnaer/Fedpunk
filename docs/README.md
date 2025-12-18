# Fedpunk Documentation

**Core documentation for the minimal configuration engine**

---

## Quick Links

- [Main README](../README.md) - Quick start and overview
- [CLAUDE.md](../CLAUDE.md) - Full architecture and development guide
- [Module Development](MODULE_DEVELOPMENT.md) - Creating custom modules

---

## What is Fedpunk?

Fedpunk is a **minimal configuration engine** for Fedora Linux. It provides the core infrastructure for deploying and managing system configurations through a modular, external-first architecture.

**This is NOT:**
- ❌ A desktop environment
- ❌ A theme manager
- ❌ A complete dotfile collection

**This IS:**
- ✅ A configuration engine
- ✅ A module deployment system
- ✅ A foundation for building profiles
- ✅ A git-native configuration manager

---

## Installation

### DNF Install (Recommended)

```bash
# Enable COPR repository
sudo dnf copr enable hinriksnaer/fedpunk

# Install Fedpunk core
sudo dnf install fedpunk

# Deploy core modules
fedpunk module deploy essentials
fedpunk module deploy ssh
```

**What's installed:**
- Core engine at `/usr/share/fedpunk`
- Only 2 built-in modules: `essentials` and `ssh`
- No profiles, no themes (external only)
- Environment variables configured for all shells

### Unstable Builds

For latest development builds from unstable branch:

```bash
sudo dnf copr enable hinriksnaer/fedpunk-unstable
sudo dnf install fedpunk
```

⚠️ **Warning:** Unstable builds may contain breaking changes.

---

## Architecture

Fedpunk uses a **minimal core + external modules** architecture:

```
┌─────────────────────────────────────────────┐
│  Core Engine (/usr/share/fedpunk)           │
│  ├─ Module system (YAML-based)              │
│  ├─ External module loader (git URLs)       │
│  ├─ Parameter system (interactive prompts)  │
│  ├─ Dependency resolver (recursive DAG)     │
│  └─ GNU Stow wrapper (symlink deployment)   │
├─────────────────────────────────────────────┤
│  Built-in Modules (2 only)                  │
│  ├─ essentials (fish, starship, ripgrep)    │
│  └─ ssh (SSH configuration)                 │
├─────────────────────────────────────────────┤
│  External Modules (git URLs or local)       │
│  ├─ https://github.com/user/module.git      │
│  ├─ ~/gits/my-custom-module                 │
│  └─ Cached in ~/.fedpunk/cache/external/    │
├─────────────────────────────────────────────┤
│  User Configuration (~/.config/fedpunk)     │
│  ├─ fedpunk.yaml (module config + params)   │
│  └─ profiles/ (external profiles cloned)    │
└─────────────────────────────────────────────┘
```

### Key Design Decisions

**External-First:**
All profiles, themes, and most modules are external. The core is minimal (~500 KB without git).

**Git-Native:**
External modules are git repositories. Clone, cache, and deploy seamlessly.

**YAML Configuration:**
Simple, readable module definitions with dependency declarations.

**Parameter System:**
Interactive prompts for module configuration, saved to `fedpunk.yaml`.

---

## Module System

Every module is self-contained with metadata, dependencies, and lifecycle hooks:

```
modules/mymodule/
├── module.yaml          # Metadata, dependencies & parameters
├── config/              # Dotfiles (stowed to $HOME)
│   └── .config/mymodule/
├── cli/                 # CLI commands (optional)
│   └── mymodule/
└── scripts/             # Lifecycle hooks
    ├── install          # Custom installation logic
    ├── before           # Pre-deployment
    └── after            # Post-deployment (plugins, etc)
```

### module.yaml Schema

```yaml
module:
  name: mymodule
  description: My custom module
  dependencies:
    - essentials      # Modules required before this one

parameters:
  api_key:
    type: string
    description: API key for service
    required: true
    prompt: true      # Prompt user if missing

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

### Module Management

```fish
# List all available modules
fedpunk module list

# Show module details
fedpunk module info essentials

# Deploy a module (handles deps, packages, configs automatically)
fedpunk module deploy essentials

# Deploy external module from git URL
fedpunk module deploy https://github.com/user/module.git

# Deploy from local path
fedpunk module deploy ~/gits/my-custom-module

# Remove module configs
fedpunk module unstow mymodule
```

---

## External Modules

Deploy modules from any git repository:

```fish
# GitHub HTTPS
fedpunk module deploy https://github.com/user/module.git

# GitHub SSH
fedpunk module deploy git@github.com:user/module.git

# With parameters (in fedpunk.yaml)
modules:
  - module: https://github.com/user/jira-module.git
    params:
      jira_url: "https://company.atlassian.net"
      team_name: "platform"
```

**External modules are cached** in `~/.fedpunk/cache/external/<host>/<org>/<repo>/`

---

## Built-in Modules

Fedpunk ships with only 2 universal modules:

### essentials
Universal system tools for modern development:
- Fish shell with modern tooling
- Starship prompt
- ripgrep, fd, bat, eza
- Basic Fish configuration

```fish
fedpunk module deploy essentials
```

### ssh
Universal SSH configuration:
- SSH config structure
- Key management helpers

```fish
fedpunk module deploy ssh
```

**That's it!** Everything else is external.

---

## External Profiles

Profiles are complete environments maintained in external repositories.

### Example: hyprpunk
Full desktop environment with Hyprland, themes, and desktop modules:
```fish
fedpunk profile deploy https://github.com/hinriksnaer/hyprpunk --mode desktop
```

### Creating Custom Profiles

```
my-profile/
├── modes/
│   ├── desktop/
│   │   └── mode.yaml      # Module list for desktop
│   └── container/
│       └── mode.yaml      # Module list for containers
├── plugins/               # Profile-specific modules
│   └── custom-module/
└── README.md
```

---

## System Requirements

- **OS:** Fedora Linux 40+
- **Arch:** x86_64
- **RAM:** 2GB minimum
- **Storage:** ~500 KB (core only, excluding git)

---

## Documentation

### Core Documentation
- [`CLAUDE.md`](../CLAUDE.md) - Full project architecture and development guide
- [`MODULE_DEVELOPMENT.md`](MODULE_DEVELOPMENT.md) - Creating modules

### External Profiles
- [hyprpunk](https://github.com/hinriksnaer/hyprpunk) - Desktop environment with Hyprland
- [fedpunk-minimal](https://github.com/hinriksnaer/fedpunk-minimal) - Minimal reference profile

---

## Philosophy

Fedpunk follows these core principles:

**Minimal Core**
Ship only what's absolutely necessary. Everything else is external.

**External-First**
Profiles, themes, and most modules live in external repositories.

**Git-Native**
Use git as the distribution mechanism. Clone, cache, deploy.

**Modular**
Every component is independently deployable and composable.

**YAML-Based**
Simple, readable configuration over complex DSLs.

**Fish-Powered**
Leverage Fish's modern features for cleaner, faster scripts.

---

## License

MIT License - See [LICENSE](../LICENSE) file for details

---

**Fedpunk** - *Minimal core. Maximum flexibility.*
