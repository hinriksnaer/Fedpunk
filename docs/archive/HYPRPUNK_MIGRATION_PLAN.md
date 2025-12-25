# Hyprpunk Migration Plan

**From:** Fedpunk main branch (dev profile)
**To:** hyprpunk external profile repository
**Engine:** Fedpunk unstable (minimal core)

## Key Design Decision ✅

**Theme Management:** Will be implemented as a hyprpunk-specific plugin (`plugins/theme-manager/`), NOT part of the fedpunk core engine. This keeps the core minimal and makes themes profile-specific.

- Themes live in `hyprpunk/themes/`
- Theme switching commands: `hyprpunk-theme-*`, `hyprpunk-wallpaper-*`
- Deployed as part of desktop mode via plugin dependency
- Fully self-contained within the hyprpunk profile

---

## 1. Current State Analysis

### Unstable Branch (Fedpunk Core Engine)
**Architecture:**
- Minimal core engine (~500 KB without git)
- External-first: All profiles/themes/modules are external
- Only 2 built-in modules: `essentials`, `ssh`
- YAML-based module system
- GNU Stow for symlink deployment
- Parameter system with interactive prompting
- External module support (git URLs, local paths)
- Profile deployment system

**Core Libraries:**
```
lib/fish/
├── cli-dispatch.fish         # CLI command dispatcher
├── config.fish               # Core configuration
├── deployer.fish             # Profile/module deployment orchestrator
├── external-modules.fish     # Git URL module cloning/caching
├── fedpunk-module.fish       # Module management commands
├── linker.fish               # GNU Stow wrapper
├── module-ref-parser.fish    # Parse module references with params
├── module-resolver.fish      # Resolve module paths (built-in/external)
├── module-utils.fish         # Module utility functions
├── param-injector.fish       # Parameter injection system
├── param-prompter.fish       # Interactive parameter prompting
├── paths.fish                # Path resolution (DNF/git installs)
├── profile-discovery.fish    # Profile discovery in ~/.config/fedpunk
├── ui.fish                   # gum wrapper for UI
└── yaml-parser.fish          # YAML parsing with yq
```

**Capabilities:**
- ✅ Deploy external profiles from git URLs
- ✅ Cache external modules in ~/.fedpunk/cache/external/
- ✅ Resolve dependencies recursively
- ✅ Interactive parameter prompting
- ✅ Profile plugins support
- ✅ Multiple modes per profile
- ✅ Lifecycle hooks (install, before, after)
- ✅ Package management (DNF, COPR, Cargo, NPM, Flatpak)

---

## 2. Dev Profile Inventory (Main Branch)

### Profile Structure
```
profiles/dev/
├── README.md
├── monitors.conf
├── modes/
│   ├── container/
│   │   └── mode.yaml
│   ├── desktop/
│   │   ├── mode.yaml
│   │   └── hypr.conf
│   └── laptop/
│       ├── mode.yaml
│       └── hypr.conf
└── plugins/
    ├── dev-extras/
    │   └── module.yaml
    ├── fancontrol/
    │   ├── module.yaml
    │   └── scripts/install
    ├── lvm-expand/
    │   ├── module.yaml
    │   └── scripts/expand-root.sh
    ├── neovim-custom/
    │   ├── module.yaml
    │   ├── config/.config/nvim/
    │   └── scripts/install
    └── vertex-ai/
        ├── module.yaml
        └── config/.config/fish/conf.d/vertex-ai.fish
```

### Modules by Mode

**Desktop Mode (23 modules):**
```yaml
modules:
  # Infrastructure
  - plugins/lvm-expand

  # Core essentials
  - essentials        # Meta-module (rust, fish, system-config, dev-tools, cli-tools)
  - ssh
  - languages

  # Terminal tools
  - plugins/neovim-custom
  - tmux
  - lazygit
  - btop
  - yazi
  - gh
  - bitwarden
  - claude
  - plugins/dev-extras  # Spotify, Discord, Slack, devcontainer-cli

  # Desktop environment
  - fonts
  - kitty
  - rofi
  - hyprland
  - hyprlock
  - audio
  - multimedia
  - zen-browser
  - nvidia
  - bluetui
  - wifi
  - plugins/fancontrol
```

**Container Mode (9 modules):**
```yaml
modules:
  - essentials
  - ssh
  - plugins/neovim-custom
  - tmux
  - lazygit
  - yazi
  - gh
  - bitwarden
  - claude
  - plugins/vertex-ai
```

**Laptop Mode (21 modules):**
Similar to desktop but excludes:
- nvidia
- zen-browser
And adds:
- plugins/vertex-ai

### Themes (12 total)
```
themes/
├── aetheria/
├── ayu-mirage/
├── catppuccin/
├── catppuccin-latte/
├── matte-black/
├── nord/
├── osaka-jade/
├── ristretto/
├── rose-pine/
├── rose-pine-dark/
├── tokyo-night/
└── torrentz-hydra/
```

Each theme contains:
- `hyprland.conf` - Compositor colors
- `kitty.conf` - Terminal colors (omarchy format)
- `rofi.rasi` - Launcher styling
- `btop.theme` - System monitor
- `mako.ini` - Notifications
- `neovim.lua` - Editor colorscheme
- `waybar.css` - Status bar
- `backgrounds/` - Wallpapers
- Additional: Alacritty, Ghostty, VS Code, Chromium configs

### Desktop-Specific Modules (Built-in on main)
These must be migrated to hyprpunk as they're removed from unstable:

**Core Modules (11):**
1. `audio` - PipeWire stack with Bluetooth audio
2. `bluetooth` - Bluetooth support
3. `bluetui` - Bluetooth TUI manager
4. `btop` - Resource monitor
5. `claude` - Claude Code CLI
6. `fonts` - Nerd Fonts
7. `gh` - GitHub CLI
8. `hyprland` - Wayland compositor
9. `hyprlock` - Screen locker
10. `kitty` - Terminal emulator
11. `rofi` - Application launcher

**Supporting Modules (13):**
12. `bitwarden` - Password manager CLI
13. `cli-tools` - lsd, ripgrep, bat, fd-find
14. `dev-tools` - GCC, Make, CMake, Git
15. `firefox` / `zen-browser` - Browser
16. `fish` - Fish shell with Starship
17. `flatpak` - Flatpak manager
18. `languages` - Programming language toolchains
19. `lazygit` - Git TUI
20. `multimedia` - Media codecs
21. `neovim` - Base Neovim (customized by plugin)
22. `nvidia` - NVIDIA drivers
23. `rust` - Rust toolchain
24. `system-config` - System configuration
25. `tmux` - Terminal multiplexer
26. `wifi` - WiFi management
27. `yazi` - File manager
28. `vm-testing` - VM utilities

### Profile Plugins (6)
1. **dev-extras** - Flatpak apps (Spotify, Discord, Slack) + devcontainer-cli
2. **fancontrol** - Aquacomputer Octo fan control
3. **lvm-expand** - LVM partition expansion
4. **neovim-custom** - Advanced Neovim config (40+ plugins)
5. **vertex-ai** - Google Vertex AI auth for Claude Code
6. **theme-manager** - Theme switching, wallpaper management, live reload (NEW)

---

## 3. Hyprpunk Repository Structure

```
hyprpunk/
├── README.md
├── modes/
│   ├── desktop/
│   │   ├── mode.yaml
│   │   └── hypr.conf
│   ├── laptop/
│   │   ├── mode.yaml
│   │   └── hypr.conf
│   └── container/
│       └── mode.yaml
├── plugins/
│   ├── dev-extras/
│   ├── fancontrol/
│   ├── lvm-expand/
│   ├── neovim-custom/
│   ├── theme-manager/      # NEW: Theme switching for hyprpunk
│   └── vertex-ai/
├── themes/
│   ├── aetheria/
│   ├── ayu-mirage/
│   ├── catppuccin/
│   ├── catppuccin-latte/
│   ├── matte-black/
│   ├── nord/
│   ├── osaka-jade/
│   ├── ristretto/
│   ├── rose-pine/
│   ├── rose-pine-dark/
│   ├── tokyo-night/
│   └── torrentz-hydra/
└── modules/
    ├── audio/
    ├── bitwarden/
    ├── bluetooth/
    ├── bluetui/
    ├── btop/
    ├── claude/
    ├── cli-tools/
    ├── dev-tools/
    ├── fish/
    ├── flatpak/
    ├── fonts/
    ├── gh/
    ├── hyprland/
    ├── hyprlock/
    ├── kitty/
    ├── languages/
    ├── lazygit/
    ├── multimedia/
    ├── neovim/
    ├── nvidia/
    ├── rofi/
    ├── rust/
    ├── system-config/
    ├── tmux/
    ├── wifi/
    ├── yazi/
    └── zen-browser/
```

---

## 4. Migration Steps

### Phase 1: Repository Setup
1. Clone hyprpunk repository
2. Create directory structure
3. Add MIT LICENSE
4. Create comprehensive README.md

### Phase 2: Migrate Themes (12 themes)
Copy all themes from `main:themes/` to `hyprpunk:themes/`
- Preserve wallpapers
- Preserve all config files
- Update themes/README.md

### Phase 3: Migrate Core Modules (27 modules)
Copy from `main:modules/` to `hyprpunk:modules/`:
- audio, bitwarden, bluetooth, bluetui, btop
- claude, cli-tools, dev-tools
- fish, flatpak, fonts
- gh, hyprland, hyprlock
- kitty, languages, lazygit
- multimedia, neovim, nvidia
- rofi, rust, system-config
- tmux, wifi, yazi, zen-browser

Update each module.yaml to ensure compatibility with unstable engine.

### Phase 4: Migrate Profile Plugins (5 plugins + 1 new)
Copy from `main:profiles/dev/plugins/` to `hyprpunk:plugins/`:
- dev-extras
- fancontrol
- lvm-expand
- neovim-custom
- vertex-ai

Create NEW plugin:
- **theme-manager** - Migrate theme switching logic from main branch bin/ scripts
  - Copy bin/fedpunk-theme-* scripts
  - Copy bin/fedpunk-wallpaper-* scripts
  - Rename to hyprpunk-theme-*/hyprpunk-wallpaper-*
  - Add module.yaml with hyprland/kitty/rofi dependencies

### Phase 5: Create Mode Configurations
Create mode.yaml for each mode:

**desktop/mode.yaml:**
```yaml
mode:
  name: desktop
  description: Full desktop environment with Hyprland

modules:
  - plugins/lvm-expand
  - essentials  # From fedpunk core
  - ssh         # From fedpunk core
  - languages
  - plugins/neovim-custom
  - tmux
  - lazygit
  - btop
  - yazi
  - gh
  - bitwarden
  - claude
  - plugins/dev-extras
  - fonts
  - kitty
  - rofi
  - hyprland
  - hyprlock
  - audio
  - multimedia
  - zen-browser
  - nvidia
  - bluetui
  - wifi
  - plugins/fancontrol
```

**container/mode.yaml:**
```yaml
mode:
  name: container
  description: Minimal development environment for containers

modules:
  - essentials
  - ssh
  - plugins/neovim-custom
  - tmux
  - lazygit
  - yazi
  - gh
  - bitwarden
  - claude
  - plugins/vertex-ai
```

**laptop/mode.yaml:**
Similar to desktop, exclude nvidia/zen-browser, add vertex-ai.

### Phase 6: Copy Hyprland Configurations
- `modes/desktop/hypr.conf`
- `modes/laptop/hypr.conf`
- monitors.conf (document in README)

---

## 5. Missing Features in Unstable

### Currently Supported ✅
1. External profile deployment from git URLs
2. Profile plugin discovery and resolution
3. External module caching
4. Mode selection (desktop/container/laptop)
5. Parameter system
6. Dependency resolution
7. Lifecycle hooks
8. Multi-package manager support

### Potential Enhancements 🔧

#### 1. Theme Management System ✅ DECIDED
**Status:** Will be implemented as hyprpunk plugin
**Location:** `hyprpunk/plugins/theme-manager/`

**Implementation:**
Theme management will be a hyprpunk-specific plugin, NOT part of fedpunk core. This keeps the core minimal and makes themes profile-specific.

```fish
# hyprpunk/plugins/theme-manager/module.yaml
module:
  name: theme-manager
  description: Theme switching and wallpaper management for Hyprland
  dependencies: [hyprland, kitty, rofi]

# hyprpunk/plugins/theme-manager/cli/
├── hyprpunk-theme-set.fish
├── hyprpunk-theme-list.fish
├── hyprpunk-theme-next.fish
├── hyprpunk-theme-prev.fish
├── hyprpunk-wallpaper-set.fish
└── hyprpunk-wallpaper-next.fish

# hyprpunk/plugins/theme-manager/scripts/
└── install  # Set up theme symlinks, initial theme
```

**Features:**
- Theme discovery in `hyprpunk/themes/`
- Live reload (hyprctl, kitty reload, etc.)
- Wallpaper cycling per theme
- Rofi theme selector menu
- Keyboard shortcuts integration

#### 2. Profile-Specific CLI Commands
**Status:** Supported via plugins/*/cli/
**Required for:** Custom hyprpunk commands

**Needed:**
- Auto-discover CLI commands in profile plugins
- Add to PATH during deployment
- Document in profile README

#### 3. Config Templating
**Status:** Partially supported via param-injector
**Required for:** Dynamic configuration based on parameters

**Check:** Does unstable support `${FEDPUNK_PARAM_*}` substitution in stowed configs?

#### 4. Profile-Level Lifecycle Hooks
**Status:** Unknown
**Required for:** Post-deployment profile setup

**Needed:**
- Profile-level install/before/after hooks
- Run after all modules deployed
- Theme initialization
- Service setup

---

## 6. Testing Plan

### Test 1: Basic Module Deployment
```bash
# From hyprpunk repo
fedpunk module deploy ~/gits/hyprpunk/modules/kitty
fedpunk module deploy ~/gits/hyprpunk/modules/hyprland
```

### Test 2: Profile Plugin Deployment
```bash
fedpunk module deploy ~/gits/hyprpunk/plugins/neovim-custom
```

### Test 3: Full Profile Deployment
```bash
fedpunk profile deploy ~/gits/hyprpunk --mode desktop
fedpunk profile deploy git@github.com:hinriksnaer/hyprpunk.git --mode desktop
```

### Test 4: Parameter Prompting
Ensure modules with parameters prompt correctly:
- vertex-ai module (Google Cloud credentials)
- Any parameterized modules

### Test 5: Theme System (Hyprpunk Plugin)
After deploying desktop mode with theme-manager plugin:
```bash
# Commands provided by hyprpunk/plugins/theme-manager/cli/
hyprpunk-theme-list
hyprpunk-theme-set catppuccin
hyprpunk-theme-next
hyprpunk-wallpaper-next

# Keyboard shortcuts (defined in hyprland config)
Super+T              # Theme selector menu
Super+Shift+T        # Next theme
Super+Shift+Y        # Previous theme
Super+Shift+W        # Next wallpaper
```

---

## 7. Implementation Checklist

### Repository Setup
- [ ] Create hyprpunk repository structure
- [ ] Add LICENSE (MIT)
- [ ] Create README.md with installation instructions
- [ ] Add .gitignore

### Content Migration
- [ ] Migrate 12 themes from main:themes/
- [ ] Migrate 27 core modules from main:modules/
- [ ] Migrate 5 profile plugins from main:profiles/dev/plugins/
- [ ] Create theme-manager plugin (NEW)
  - [ ] Copy theme switching scripts from main:bin/fedpunk-theme-*
  - [ ] Copy wallpaper scripts from main:bin/fedpunk-wallpaper-*
  - [ ] Rename to hyprpunk-* commands
  - [ ] Create module.yaml
  - [ ] Create install script for theme setup
- [ ] Create 3 mode.yaml files (desktop/laptop/container)
- [ ] Copy Hyprland configurations (hypr.conf)
- [ ] Copy monitors.conf or document it

### Module Validation
- [ ] Verify all module.yaml files are valid
- [ ] Check all dependencies exist
- [ ] Validate lifecycle scripts have execute permissions
- [ ] Test package installation commands

### Documentation
- [ ] README.md with installation guide
- [ ] Module list and descriptions
- [ ] Theme showcase with screenshots
- [ ] Migration guide for existing users
- [ ] Troubleshooting guide

### Testing
- [ ] Test module deployment (individual modules)
- [ ] Test plugin deployment
- [ ] Test full profile deployment (desktop mode)
- [ ] Test container mode deployment
- [ ] Test parameter prompting
- [ ] Test theme switching (if implemented)
- [ ] Test on fresh Fedora installation

---

## 8. Next Steps

1. **Immediate:** Create hyprpunk repository structure
2. **Copy themes:** Migrate all 12 themes
3. **Copy modules:** Migrate 27 core desktop modules
4. **Copy plugins:** Migrate 5 profile plugins
5. **Create modes:** Write mode.yaml for desktop/container/laptop
6. **Test locally:** Deploy with unstable engine
7. **Identify gaps:** Document any missing unstable features
8. **Implement fixes:** Add missing features to unstable if needed
9. **Document:** Write comprehensive README
10. **Release:** Push to GitHub and test full external deployment

---

**Priority:** Start with Phase 1-3 (themes + core modules), then test deployment to identify any missing unstable features before completing the migration.
