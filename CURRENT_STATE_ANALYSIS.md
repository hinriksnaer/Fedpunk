# Fedpunk Current State Analysis
**Date:** 2025-12-15
**Branch:** unstable (ahead of main)
**Status:** Clean working tree

---

## Executive Summary

Fedpunk has undergone significant architectural evolution in recent commits. The system is currently in the **unstable** branch with major CLI refactoring complete but not yet merged to main. The core functionality has been minimized and modularized, with desktop components moved to a dedicated profile system.

### Key Changes (Last 15 commits)

1. **CLI Auto-Discovery Pattern** - Zero-boilerplate CLI system for module commands
2. **Desktop Profile Separation** - Desktop modules moved from core to `profiles/desktop/plugins/`
3. **RPM Packaging Improvements** - Simplified spec file, cleaner builds
4. **Session Export Documentation** - Comprehensive context preservation guide added

---

## Current Architecture State

### Three-Tier Module System

**1. Core Modules** (`modules/` - minimal system)
- `essentials` - Base system utilities
- `ssh` - SSH configuration and management
- `claude` - Claude Code integration
- `bluetui` - Bluetooth TUI interface

**2. Profile System** (`profiles/`)

| Profile | Purpose | Module Count |
|---------|---------|--------------|
| `default` | General-purpose, minimal | ~15 modules (desktop mode) |
| `desktop` | Full desktop environment | ~26 plugins (desktop mode) |
| `dev` | Personal reference config | ~15+ (with custom plugins) |
| `example` | Template for custom profiles | Minimal |

**3. Profile Plugins** (e.g., `profiles/desktop/plugins/`)
- Desktop components: hyprland, kitty, rofi, waybar
- Dev tools: neovim, tmux, lazygit, gh
- Utilities: bitwarden, wifi, bluetooth, audio
- All formerly "core" desktop modules now live here

### Installation Modes

**DNF/RPM Installation** (COPR)
```
System:  /usr/share/fedpunk/
         ├── bin/fedpunk          # Main dispatcher
         ├── lib/fish/            # Core libraries
         ├── modules/             # 4 core modules only
         ├── profiles/            # default + desktop
         ├── themes/              # 12 themes
         └── cli/                 # Core CLI commands

User:    ~/.local/share/fedpunk/
         ├── cli/                 # Module-provided CLI commands
         └── .active-config       # Symlink to active profile
```

**Git Clone Installation** (Traditional)
```
~/.local/share/fedpunk/
├── All files (system + user combined)
└── Environment vars set by Fish during init
```

---

## Recent CLI Refactoring

### New Zero-Boilerplate Pattern

**Before** (old pattern):
```fish
#!/usr/bin/env fish

# Manual sourcing
if not functions -q cli-dispatch
    source "$FEDPUNK_SYSTEM/lib/fish/cli-dispatch.fish"
end

# Manual dispatcher setup
function mymodule --description "My module commands"
    set -l cmd_dir (dirname (status --current-filename))
    cli-dispatch mymodule $cmd_dir $argv
end

# Subcommands...

# Manual execution
mymodule $argv
```

**After** (new auto-dispatch):
```fish
#!/usr/bin/env fish
# cli-dispatch pre-loaded by bin/fedpunk!

# One-line main function
function mymodule --description "My module commands"
    # bin/fedpunk handles all routing
end

# Subcommands work normally
function subcmd --description "Subcommand description"
    # Implementation
end

# No execution line needed!
```

**For Core Commands** (module, profile, config, etc.):
```fish
# Stub function required for discovery
function module --description "Manage modules"
    # No-op: bin/fedpunk handles routing
end

# Subcommands work as normal
function deploy --description "Deploy a module"
    # Implementation
end
```

### bin/fedpunk Dispatcher

The new `bin/fedpunk` script:
- Auto-discovers commands from `$FEDPUNK_ROOT/cli/` AND `$FEDPUNK_USER/cli/`
- Sources all `.fish` files in command directories
- Routes to functions automatically
- Generates help text from `--description` flags
- Handles both core and module-provided commands uniformly

**Key functions:**
- `_discover_commands` - Finds available command groups
- `_discover_functions` - Finds subcommands within a group
- `_get_description` - Extracts help text from function definitions
- `_main` - Routes `fedpunk <cmd> <subcmd>` to appropriate functions

---

## Profile Architecture

### default Profile (Minimal, Recommended)

**Desktop Mode:**
- Core: essentials, ssh, languages
- Terminal: neovim, tmux, lazygit, btop, yazi
- Dev: gh, bitwarden, claude
- GUI: fonts, kitty, rofi, hyprland, hyprlock, firefox, bluetui, wifi

**Container Mode:**
- Core tools only, no GUI components
- Fish, neovim, tmux, lazygit
- Ideal for devcontainers, WSL, remote servers

### desktop Profile (Full Featured)

**Desktop Mode:**
- 4 core modules (from `modules/`)
- 26 profile plugins (from `profiles/desktop/plugins/`)
- Complete desktop environment
- Full multimedia stack
- Development toolchain
- System utilities

**Container Mode:**
- Subset of desktop plugins without GUI
- Terminal-only workflow

### dev Profile (Personal Reference)

**Modes:**
- Desktop mode
- Container mode
- Laptop mode (with custom hardware configs)

**Plugins:**
- dev-extras (Spotify, Discord, etc.)
- fancontrol (hardware-specific)
- neovim-custom (personal Neovim config)
- vertex-ai (work-specific tools)
- lvm-expand (disk management utilities)

---

## Deployment Flow (Current)

```
1. Profile/Mode Selection
   ↓
2. Module List Resolution (from mode.yaml)
   ↓
3. External Module Resolution
   - Git URLs → ~/.fedpunk/cache/external/
   - Local paths → direct reference
   - Profile plugins → relative to profile dir
   ↓
4. Dependency Resolution
   - Recursive topological sort
   - Duplicate prevention
   - Cycle detection
   ↓
5. Parameter Injection
   - Generate ~/.config/fish/conf.d/fedpunk-module-params.fish
   - Environment vars: FEDPUNK_PARAM_<MODULE>_<PARAM>
   ↓
6. Package Installation
   - DNF packages (including COPR repos)
   - Cargo, NPM, Flatpak
   ↓
7. Lifecycle: before
   - Pre-deployment hooks
   ↓
8. GNU Stow Deployment
   - Symlink config/ → $HOME
   - Instant, live config changes
   ↓
9. Lifecycle: after
   - Post-deployment hooks
   - Plugin installation
   - Service setup
```

---

## Key Libraries (lib/fish/)

| Library | Purpose | Key Functions |
|---------|---------|---------------|
| `paths.fish` | Environment detection | Auto-detect DNF vs git install |
| `installer.fish` | Orchestration | Profile/mode selection, deployment |
| `fedpunk-module.fish` | Module management | list, info, deploy, stow, unstow |
| `module-resolver.fish` | Path resolution | Built-in, plugins, local, git URLs |
| `module-ref-parser.fish` | YAML parsing | Extract module refs with parameters |
| `external-modules.fish` | Git module caching | Clone, cache, update external modules |
| `param-injector.fish` | Parameter handling | Generate Fish env vars from params |
| `linker.fish` | GNU Stow wrapper | Config deployment, state tracking |
| `yaml-parser.fish` | YAML utilities | Parse module.yaml, mode.yaml |
| `ui.fish` | UI abstraction | Gum wrapper for consistent UX |

---

## CLI Commands (Current)

### Core Commands (`cli/`)

```fish
fedpunk module <subcommand>    # Module management
  ├─ list                      # List available modules
  ├─ info <name>               # Show module details
  ├─ deploy [name]             # Deploy module (interactive if no name)
  ├─ remove <name>             # Unstow module config
  └─ state                     # Show deployment state

fedpunk profile <subcommand>   # Profile management
  ├─ list                      # List available profiles
  ├─ info [name]               # Show profile details
  ├─ switch <name>             # Switch to different profile
  └─ current                   # Show active profile

fedpunk config <subcommand>    # Configuration management
  ├─ show                      # Display current config
  ├─ edit                      # Edit config files
  └─ reload                    # Reload active config

fedpunk apply                  # Re-run installer (safe to repeat)
```

### Module-Provided Commands (`$FEDPUNK_USER/cli/`)

These commands are deployed by modules to `~/.local/share/fedpunk/cli/`:

```fish
fedpunk ssh <subcommand>       # SSH management (from modules/ssh)
  ├─ add                       # Add new SSH key
  ├─ list                      # List SSH keys
  └─ test <host>               # Test SSH connection

fedpunk vault <subcommand>     # Bitwarden vault (from bitwarden plugin)
  ├─ login                     # Login to Bitwarden
  ├─ unlock                    # Unlock vault
  ├─ ssh-backup                # Backup SSH keys to vault
  ├─ ssh-restore               # Restore SSH keys from vault
  ├─ claude-backup             # Backup Claude credentials
  └─ claude-restore            # Restore Claude credentials

fedpunk wifi <subcommand>      # WiFi management (from wifi plugin)
  ├─ connect                   # Connect to network
  ├─ list                      # List available networks
  └─ status                    # Show connection status

fedpunk bluetooth <subcommand> # Bluetooth (from bluetooth plugin)
  ├─ pair                      # Pair new device
  ├─ connect <device>          # Connect to device
  └─ list                      # List paired devices

fedpunk vm <subcommand>        # VM testing (from vm-testing plugin)
  ├─ create <name>             # Create test VM
  ├─ start <name>              # Start VM
  └─ destroy <name>            # Remove VM
```

---

## RPM Packaging (Current State)

### Spec File Highlights

```spec
Name:     fedpunk
Version:  0.5.0
Release:  0.%{build_timestamp}.unstable

# Uses GitHub tarball for unstable branch
Source0:  https://github.com/hinriksnaer/Fedpunk/archive/refs/heads/unstable.tar.gz

# Core minimal install:
- 4 core modules (ssh, essentials, claude, bluetui)
- 2 profiles (default, desktop)
- 12 themes
- All core libraries
- CLI commands

# Wrapper at /usr/bin/fedpunk calls bin/fedpunk
# Environment vars set via /etc/profile.d/fedpunk.sh
```

**Building locally:**
```bash
bash test/build-rpm.sh          # Builds in ~/rpmbuild/
bash test/test-rpm-install.sh   # Tests installation
```

---

## Theme System (12 Themes)

**Live-reload themes** (no restart required):

| Theme | Style | Files Updated |
|-------|-------|---------------|
| aetheria | Ethereal purple/blue | 8 config files |
| ayu-mirage | Warm desert tones | per theme |
| catppuccin | Soothing pastel (mocha) | → |
| catppuccin-latte | Light mode | → |
| matte-black | Pure minimalism | → |
| nord | Arctic cool | → |
| osaka-jade | Vibrant teal/green | → |
| ristretto | Rich espresso | → |
| rose-pine | Soft rose/pine | → |
| rose-pine-dark | Deep rose/pine | → |
| tokyo-night | Deep blues with neon | → |
| torrentz-hydra | Bold high contrast | → |

**Theme files per theme:**
```
themes/<name>/
├── kitty.conf          # Terminal colors
├── hyprland.conf       # Compositor
├── rofi.rasi           # Launcher
├── btop.theme          # System monitor
├── mako.ini            # Notifications
├── neovim.lua          # Editor
├── waybar.css          # Status bar
└── backgrounds/        # Wallpapers
```

**Live reload mechanisms:**
- Kitty: SIGUSR1 signal
- Mako: SIGUSR2 signal
- Hyprland: `hyprctl reload`
- Neovim: RPC call
- Others: Config file updates

---

## Differences: unstable vs main

### unstable branch is ahead with:

1. **CLI Auto-Discovery** - New bin/fedpunk dispatcher
2. **Desktop Profile Separation** - Modules moved to profile plugins
3. **RPM Spec Simplification** - Cleaner package structure
4. **Session Export Documentation** - SESSION_EXPORT.md added
5. **CLI Command Improvements** - Module/profile/config refactored
6. **User Space CLI Support** - Module commands work from $FEDPUNK_USER/cli

### main branch still has:

- Old CLI pattern with manual dispatch
- Desktop modules in core `modules/` directory
- More complex RPM spec with more files
- No SESSION_EXPORT.md
- Some removed libraries (cli-dispatch, deployer, config, profile-discovery)

**Recommendation:** The unstable branch represents the future architecture. Once tested via COPR, it should be merged to main.

---

## External Module Support

Modules can be referenced from:

**1. Built-in** - `modules/<name>/`
```yaml
modules:
  - essentials
  - neovim
```

**2. Profile Plugins** - `plugins/<name>`
```yaml
modules:
  - plugins/custom-tool
  - plugins/work-config
```

**3. Local Paths** - Absolute or `~` paths
```yaml
modules:
  - ~/gits/my-module
  - /opt/shared-config
```

**4. Git URLs** - HTTPS or SSH
```yaml
modules:
  - https://github.com/org/module.git
  - git@github.com:org/module.git

  # With parameters
  - module: https://github.com/org/jira.git
    params:
      team_name: "platform"
      jira_url: "https://company.atlassian.net"
```

**Caching:** Git modules cached at `~/.fedpunk/cache/external/<host>/<org>/<repo>/`

---

## Parameter System

**Module defines** (in `module.yaml`):
```yaml
parameters:
  api_endpoint:
    type: string
    required: true
    default: "https://api.example.com"
  debug_mode:
    type: boolean
    default: false
```

**Profile provides** (in `mode.yaml`):
```yaml
modules:
  - module: my-api-tool
    params:
      api_endpoint: "https://custom.api.com"
      debug_mode: true
```

**Fedpunk generates** (`~/.config/fish/conf.d/fedpunk-module-params.fish`):
```fish
set -gx FEDPUNK_PARAM_MY_API_TOOL_API_ENDPOINT "https://custom.api.com"
set -gx FEDPUNK_PARAM_MY_API_TOOL_DEBUG_MODE "true"
```

**Module accesses**:
```fish
echo $FEDPUNK_PARAM_MY_API_TOOL_API_ENDPOINT
# https://custom.api.com

if test "$FEDPUNK_PARAM_MY_API_TOOL_DEBUG_MODE" = "true"
    echo "Debug mode enabled"
end
```

---

## Documentation Status

### Current Documentation

| File | Status | Notes |
|------|--------|-------|
| `README.md` | ⚠️ Partially outdated | References old architecture |
| `CLAUDE.md` | ✅ Up to date | Removed in main, exists in unstable |
| `ARCHITECTURE.md` | ❌ Missing | No longer exists |
| `SESSION_EXPORT.md` | ✅ Current | Comprehensive session context |
| `docs/` | ⚠️ Mixed | Some guides outdated |

### Outdated Information in README.md

1. **Profile descriptions** - Need update for desktop profile
2. **Module count** - Core reduced to 4, not ~30
3. **Architecture diagram** - Doesn't reflect plugin separation
4. **CLI examples** - Some commands changed
5. **File paths** - Some module locations changed

### Documentation Needs

- [ ] Update README.md with new profile structure
- [ ] Document bin/fedpunk dispatcher architecture
- [ ] Update module development guide for new CLI pattern
- [ ] Add profile plugin development guide
- [ ] Document RPM vs git installation differences
- [ ] Update architecture diagrams
- [ ] Add COPR installation best practices

---

## Testing Status

### Available Tests

```bash
# RPM build tests
bash test/build-rpm.sh           # Local RPM build
bash test/test-rpm-install.sh    # Test RPM installation

# GitHub Actions workflows
.github/workflows/
├── test-default-container.yml   # Test default/container
├── test-default-desktop.yml     # Test default/desktop
├── test-dev-desktop.yml         # Test dev/desktop
└── test-rpm-build.yml           # Test RPM packaging
```

### What Tests Cover

- Profile installation (default, desktop, dev)
- Mode selection (desktop, container, laptop)
- Module deployment
- Dependency resolution
- RPM packaging
- COPR build process

### What Needs Testing

- [ ] CLI auto-discovery with module commands
- [ ] User space CLI command sourcing
- [ ] Parameter injection system
- [ ] External module cloning/caching
- [ ] Profile switching
- [ ] Theme live-reload
- [ ] DNF installation vs git clone parity

---

## Known Issues & Considerations

### 1. Documentation Lag

README.md and docs/ don't reflect recent architectural changes. Users may be confused by outdated information.

### 2. Branch Divergence

unstable branch is significantly ahead of main. Need testing and merge plan.

### 3. Desktop Profile Confusion

Having both `profiles/default` (minimal) and `profiles/desktop` (full) might confuse users. Consider renaming or clearer documentation.

### 4. Core Module Selection

Only 4 modules in core (`modules/`) seems very minimal. Consider if `essentials` should be split or if more tools belong in core.

### 5. COPR Build Readiness

Recent changes need COPR rebuild to test DNF installation path, especially:
- bin/fedpunk dispatcher changes
- User space CLI discovery
- Desktop profile structure

### 6. Migration Path

Users on older versions (with desktop modules in core) need migration guide to new profile structure.

---

## Recommended Next Steps

### Immediate (Testing Phase)

1. **COPR Build** - Trigger unstable COPR build to test packaging
2. **DNF Installation Test** - Verify all recent changes work with RPM install
3. **CLI Command Test** - Deploy module with CLI, verify auto-discovery works
4. **Documentation Sprint** - Update README.md with current architecture

### Short Term (Stabilization)

1. **Profile Naming** - Clarify default vs desktop vs dev profiles
2. **Migration Guide** - Document upgrade path from old structure
3. **Test Coverage** - Add tests for new CLI pattern
4. **Architecture Docs** - Recreate ARCHITECTURE.md or equivalent

### Long Term (Enhancement)

1. **Profile Manager** - TUI for profile/mode selection
2. **Module Registry** - Centralized module discovery
3. **Version Locking** - Pin module versions for stability
4. **Dependency Visualization** - Graph of module dependencies
5. **Rollback System** - Snapshot and restore capability

---

## Conclusion

Fedpunk is in a transitional state between old and new architecture. The unstable branch contains significant improvements:

- **Cleaner CLI pattern** with zero boilerplate
- **Better modularity** with profile-based desktop components
- **Improved packaging** with minimal core and profile separation
- **Enhanced extensibility** with user space CLI support

The system is production-ready but needs:
1. COPR build validation
2. Documentation updates
3. Testing of new patterns
4. Clear migration path for existing users

The architecture is sound and represents a significant improvement in maintainability and extensibility.
