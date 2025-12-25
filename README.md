# Fedpunk

<div align="center">

<pre style="color: #ee0000; font-weight: bold;">
███████╗███████╗██████╗ ██████╗ ██╗   ██╗███╗   ██╗██╗  ██╗
██╔════╝██╔════╝██╔══██╗██╔══██╗██║   ██║████╗  ██║██║ ██╔╝
█████╗  █████╗  ██║  ██║██████╔╝██║   ██║██╔██╗ ██║█████╔╝
██╔══╝  ██╔══╝  ██║  ██║██╔═══╝ ██║   ██║██║╚██╗██║██╔═██╗
██║     ███████╗██████╔╝██║     ╚██████╔╝██║ ██████║██║  ██╗
╚═╝     ╚══════╝╚═════╝ ╚═╝      ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═╝
</pre>

### A Minimal Configuration Engine for Fedora Linux

**The lightweight core that powers modular system configuration**

*External-first architecture • YAML-based modules • Git-native deployment*

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Fedora](https://img.shields.io/badge/Fedora-40+-blue.svg)](https://getfedora.org/)
[![Fish Shell](https://img.shields.io/badge/Shell-Fish-green.svg)](https://fishshell.com/)

[Quick Start](#quick-start) • [Architecture](#architecture) • [Modules](#module-system) • [Documentation](#documentation)

---

</div>

## What is Fedpunk?

Fedpunk is a **minimal configuration engine** for Fedora Linux. It provides the core infrastructure for deploying and managing system configurations through a modular, external-first architecture.

**Core capabilities:**
- **Modular Architecture** - Self-contained modules with automatic dependency resolution
- **External Module Support** - Deploy from git URLs, local paths, or built-in modules
- **YAML Configuration** - Simple, declarative module definitions
- **Parameter System** - Interactive prompting with persistent configuration
- **GNU Stow Integration** - Symlink-based deployment (instant, no generation)
- **Fish-First** - Modern shell with intelligent completions

**What Fedpunk is NOT:**
- ❌ A desktop environment (use external profiles like [hyprpunk](https://github.com/hinriksnaer/hyprpunk))
- ❌ A theme manager (themes live in profiles)
- ❌ A complete dotfile collection (minimal core only)

**What Fedpunk IS:**
- ✅ A configuration engine
- ✅ A module deployment system
- ✅ A foundation for building profiles
- ✅ A git-native configuration manager

---

## Quick Start

### DNF Install (COPR) ⚡ Recommended

**Stable builds:**

```bash
# Enable COPR repository
sudo dnf copr enable hinriksnaer/fedpunk

# Install Fedpunk core
sudo dnf install fedpunk

# Deploy core modules
fedpunk module deploy fish
fedpunk module deploy ssh

# Deploy external modules
fedpunk module deploy https://github.com/user/module.git
```

**What's installed:**
- Core engine at `/usr/share/fedpunk`
- Only 3 built-in modules: `fish`, `ssh`, and `ssh-clusters`
- No profiles, no themes (external only)
- Environment variables configured for all shells

### Unstable Builds (Bleeding Edge)

For latest development builds from main branch:

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
│  Built-in Modules (3 only)                  │
│  ├─ fish (Fish shell + Starship prompt)     │
│  ├─ ssh (SSH configuration)                 │
│  └─ ssh-clusters (SSH cluster management)   │
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

**External-First**
All profiles, themes, and most modules are external. The core is minimal (~500 KB without git).

**Git-Native**
External modules are git repositories. Clone, cache, and deploy seamlessly.

**YAML Configuration**
Simple, readable module definitions with dependency declarations.

**Parameter System**
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

**module.yaml schema:**
```yaml
module:
  name: mymodule
  description: My custom module
  dependencies:
    - fish      # Modules required before this one

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
fedpunk module info fish

# Deploy a module (handles deps, packages, configs automatically)
fedpunk module deploy fish

# Deploy external module from git URL
fedpunk module deploy https://github.com/user/module.git

# Deploy from local path
fedpunk module deploy ~/gits/my-custom-module

# Remove module configs
fedpunk module unstow mymodule
```

### Creating Custom Modules

1. **Create module structure:**
```bash
mkdir -p my-module/{config,cli,scripts}
```

2. **Write module.yaml:**
```yaml
module:
  name: my-module
  description: My custom module
  dependencies: []

packages:
  dnf:
    - tool1
    - tool2
```

3. **Add configs:**
```bash
mkdir -p my-module/config/.config/my-tool
echo "setting=value" > my-module/config/.config/my-tool/config.conf
```

4. **Deploy:**
```fish
fedpunk module deploy ~/path/to/my-module
```

---

## External Modules

Deploy modules from any git repository:

```fish
# GitHub HTTPS
fedpunk module deploy https://github.com/user/module.git

# GitHub SSH
fedpunk module deploy git@github.com:user/module.git

# GitLab
fedpunk module deploy https://gitlab.com/user/module.git

# With parameters (in mode.yaml or fedpunk.yaml)
modules:
  - module: https://github.com/user/jira-module.git
    params:
      jira_url: "https://company.atlassian.net"
      team_name: "platform"
```

**External modules are cached** in `~/.fedpunk/cache/external/<host>/<org>/<repo>/`

To update: delete cache and re-deploy.

---

## Built-in Modules

Fedpunk ships with only 3 minimal modules:

### fish
Modern Fish shell with Starship prompt:
- Fish shell with modern tooling
- Starship cross-shell prompt
- Fisher plugin manager
- Basic Fish configuration

```fish
fedpunk module deploy fish
```

### ssh
SSH client configuration:
- Opinionated SSH config
- Connection multiplexing
- Key management CLI (`fedpunk ssh load`)

```fish
fedpunk module deploy ssh
```

### ssh-clusters
SSH cluster management (optional):
- Cluster-based SSH configuration
- Multi-host management

```fish
fedpunk module deploy ssh-clusters
```

**That's it!** Everything else is external.

---

## External Profiles

Profiles are complete environments maintained in external repositories. Examples:

### hyprpunk
Full desktop environment with Hyprland, themes, and desktop modules:
```fish
fedpunk profile deploy https://github.com/hinriksnaer/hyprpunk --mode desktop
```

### fedpunk-minimal
Minimal reference profile for containers:
```fish
fedpunk profile deploy https://github.com/hinriksnaer/fedpunk-minimal --mode container
```

**Create your own profile:**
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

**Core Documentation:**
- [`CLAUDE.md`](CLAUDE.md) - Full project architecture and development guide
- [`docs/MODULE_DEVELOPMENT.md`](docs/MODULE_DEVELOPMENT.md) - Creating modules

**External Profiles:**
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

## Contributing

We welcome contributions!

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Test your changes
4. Commit with clear messages
5. Submit a pull request

**Areas for contribution:**
- Core engine improvements
- Documentation improvements
- Bug fixes
- External module creation (in separate repos)

---

## License

MIT License - See [LICENSE](LICENSE) file for details

---

<div align="center">

## Ready to Build Your System?

```bash
sudo dnf copr enable hinriksnaer/fedpunk
sudo dnf install fedpunk
fedpunk module deploy fish
```

**Fedpunk** - *Minimal core. Maximum flexibility.*

**Star this repo** if you find it useful!

</div>
