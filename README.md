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

[Quick Start](#quick-start) • [Modules](#module-system) • [Profiles](#external-profiles) • [Documentation](#documentation)

---

</div>

## What is Fedpunk?

Fedpunk is **end-to-end system orchestration** for Fedora Linux. It handles everything needed to configure and reproduce your environment:

- **Dotfiles** - Symlink-based deployment via GNU Stow (edit once, apply everywhere)
- **Packages** - DNF, COPR, Cargo, NPM, and Flatpak from declarative YAML
- **Environment Variables** - Auto-generated Fish config from module parameters
- **Custom CLI** - Drop Fish functions into `cli/` and they're available system-wide
- **Lifecycle Scripts** - Run custom logic before/after deployment
- **Dependencies** - Automatic resolution with topological sorting

Each module is self-contained and reproducible. Deploy from git URLs, local paths, or built-in modules with full dependency tracking.

Use external profiles like [hyprpunk](https://github.com/hinriksnaer/hyprpunk) to deploy complete desktop environments built on Fedpunk.

---

## Quick Start

### DNF Install (COPR) ⚡ Recommended

**Stable builds:**

```bash
# Enable COPR repository
sudo dnf copr enable hinriksnaer/fedpunk

# Install Fedpunk core
sudo dnf install fedpunk

# Deploy the fish module
fedpunk module deploy fish

# Deploy external modules
fedpunk module deploy https://github.com/user/module.git
```

**What's installed:**
- Core engine at `/usr/share/fedpunk`
- Only 1 built-in module: `fish`
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

## Configuration

Fedpunk stores its configuration at `~/.config/fedpunk/fedpunk.yaml`:

```yaml
# ~/.config/fedpunk/fedpunk.yaml

profile:
  name: hyprpunk                                      # Profile name (for local lookup)
  source: https://github.com/hinriksnaer/hyprpunk.git # Git URL (for fetching/updates)
  mode: desktop                                       # Active mode (desktop, container, etc)

sources:                       # Multi-module git repositories
  - https://gitlab.com/org/fedpunk-modules.git

modules:
  enabled:                     # Modules to deploy
    - fish                     # Simple module reference
    - module: jira             # Module with parameters
      params:
        jira_url: "https://company.atlassian.net"
        team_name: "platform"
  disabled: []                 # Modules to skip during deployment

environment:                   # User environment variables (override module defaults)
  MY_CUSTOM_VAR: "value"
  DEBUG_MODE: "true"

last_deployed: 2024-03-13T10:30:00+00:00
```

For local profiles (no git source):
```yaml
profile:
  name: my-local-profile
  source: null
  mode: desktop
```

**Directory structure:**
```
~/.config/fedpunk/
├── fedpunk.yaml       # Main configuration
├── profiles/          # Cloned profile repositories
├── sources/           # Cloned source repositories
└── modules/           # Cloned external modules
```

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

environment:           # Environment variables (exported to shell)
  MY_API_URL: "https://api.example.com"
  DEBUG_MODE: "false"

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
fedpunk module deploy https://github.com/user/module.git

# GitLab
fedpunk module deploy https://gitlab.com/user/module.git

# With parameters (in mode.yaml or fedpunk.yaml)
modules:
  - module: https://github.com/user/jira-module.git
    params:
      jira_url: "https://company.atlassian.net"
      team_name: "platform"
```

**External modules are stored** in `~/.config/fedpunk/modules/<repo-name>/` for easy editing.

To update: `cd ~/.config/fedpunk/modules/<repo-name> && git pull`

### Module Sources

For teams with shared module collections, use source repositories:

```fish
# Add a source repository (contains multiple modules)
fedpunk module sources add https://gitlab.com/org/fedpunk-modules.git

# List configured sources
fedpunk module sources list

# Sync all sources (clone/update)
fedpunk module sources sync

# List modules from all sources
fedpunk module sources modules

# Remove a source
fedpunk module sources remove https://gitlab.com/org/fedpunk-modules.git
```

Sources are stored in `~/.config/fedpunk/sources/<repo-name>/` and synced automatically before deployment.

---

## Built-in Modules

Fedpunk ships with only 1 minimal module:

### fish
Modern Fish shell with Starship prompt:
- Fish shell with modern tooling
- Starship cross-shell prompt
- Fisher plugin manager
- Basic Fish configuration

```fish
fedpunk module deploy fish
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
├── modules/               # Profile-specific modules
│   └── custom-module/
└── README.md
```

---

## Architecture

```
┌─────────────────────────────────────────────┐
│  Core Engine (/usr/share/fedpunk)           │
│  ├─ Module system (YAML-based)              │
│  ├─ External module loader (git URLs)       │
│  ├─ Parameter system (env var injection)    │
│  ├─ Dependency resolver (recursive DAG)     │
│  └─ GNU Stow wrapper (symlink deployment)   │
├─────────────────────────────────────────────┤
│  Built-in Modules (1 only)                  │
│  └─ fish (Fish shell + Starship prompt)     │
├─────────────────────────────────────────────┤
│  External Modules (git URLs or local)       │
│  ├─ https://github.com/user/module.git      │
│  ├─ ~/gits/my-custom-module                 │
│  └─ Stored in ~/.config/fedpunk/modules/    │
├─────────────────────────────────────────────┤
│  User Configuration (~/.config/fedpunk)     │
│  ├─ fedpunk.yaml (module config + params)   │
│  └─ profiles/ (external profiles cloned)    │
└─────────────────────────────────────────────┘
```

**Module Resolution Priority:**
1. Profile modules (`profiles/<name>/modules/`)
2. Source repositories (`~/.config/fedpunk/sources/`)
3. External git URLs (`~/.config/fedpunk/modules/`)
4. Built-in modules (`modules/`)

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
