# Fedpunk Layered Architecture

## The Problem

**Images are static (build-time). Modules are dynamic (runtime).**

How do we reconcile:
- ✅ Reproducible base images (declarative, bit-identical)
- ✅ Community module ecosystem (dynamic, user-chosen)
- ✅ Personal customization (unique per user)

## The Solution: Three-Tier Architecture

```
┌─────────────────────────────────────┐
│  Tier 3: User Overrides (Personal) │  ← Highest priority
├─────────────────────────────────────┤
│  Tier 2: Modules (Dynamic)          │  ← Community, plugins, opt-in
├─────────────────────────────────────┤
│  Tier 1: Base Image (Static)        │  ← Reproducible foundation
└─────────────────────────────────────┘
```

### Tier 1: Base Image (Package Foundation)

**What it provides:**
- Package sets (Hyprland, Fish, dev tools, etc.)
- Minimal default configs in `/etc/skel`
- Fedpunk CLI tools
- System-level setup

**What it does NOT provide:**
- User-specific configs
- Community themes
- Personal tweaks
- Optional features

**Example images:**
```
fedpunk/base        - Minimal (Fish + core utils)
fedpunk/hyprland    - Hyprland desktop (compositor + essentials)
fedpunk/dev         - Developer workstation (languages + tools)
```

**Key insight:** Images provide **package infrastructure**, not complete environments.

### Tier 2: Modules (Configuration Layer)

**Deployed at runtime via `fedpunk module deploy`**

**Types of modules:**

1. **Base modules** (shipped with image)
   - Default Hyprland config
   - Default Waybar theme
   - Fish shell defaults
   - In `/etc/skel` (starting point for new users)

2. **Community modules** (user installs)
   - Themes (tokyo-night, catppuccin, nord)
   - Tweaks (gaming optimizations, NVIDIA fixes)
   - Alternative configs (different Waybar layouts)
   - User runs: `fedpunk module deploy community/xyz`

3. **Plugins** (profile-specific)
   - User's personal plugins
   - Not in base image
   - Deployed from profile: `plugins/my-custom-stuff`

**Module types:**

```yaml
# Type A: Config-only module (no packages)
module:
  name: tokyo-night-theme
  type: config-only

packages:
  # NONE - image already has packages

configs:
  .config/hypr/themes/tokyo-night.conf
  .config/waybar/tokyo-night.css

# Deployed via linker to $HOME
# Overrides /etc/skel defaults
```

```yaml
# Type B: Package module (requires layering or image fork)
module:
  name: nvidia-tweaks
  type: package-required

packages:
  dnf:
    - nvidia-driver
    - nvidia-settings

configs:
  .config/hypr/nvidia.conf

# User has two options:
# 1. Layer package (quick but breaks reproducibility)
# 2. Fork image and rebuild (maintains reproducibility)
```

### Tier 3: User Overrides (Personal)

**Location:** `~/.config/fedpunk/overrides/`

**What it is:**
- User's personal tweaks
- Overrides everything else
- Not tracked by fedpunk
- User's responsibility

**Example:**
```bash
# User wants different Hyprland keybindings
vim ~/.config/hypr/hyprland.conf

# Or structured overrides
~/.config/fedpunk/overrides/
  ├── hyprland/
  │   └── keybindings.conf  # Sourced by main config
  └── waybar/
      └── my-modules.json
```

## How the Layers Work Together

### Example 1: User wants Tokyo Night theme

```bash
# Image provides packages
rpm-ostree rebase fedpunk/hyprland:latest
systemctl reboot

# User adds community module (runtime)
fedpunk module deploy community/tokyo-night-theme

# Linker deploys configs:
# ~/.config/hypr/themes/tokyo-night.conf
# ~/.config/waybar/tokyo-night.css

# Result: Image (packages) + Module (theme config)
```

**Flow:**
```
1. Image (/etc/skel) has default configs
2. User's first login: defaults copied to $HOME
3. User deploys tokyo-night module
4. Linker overlays tokyo-night configs
5. User gets themed environment
```

### Example 2: User wants NVIDIA drivers

**Option A: Layer package (quick, breaks reproducibility)**
```bash
# User rebased to fedpunk/hyprland
# Now needs NVIDIA drivers

# Layer the driver
rpm-ostree install nvidia-driver
systemctl reboot

# Deploy NVIDIA module (configs)
fedpunk module deploy community/nvidia-tweaks

# Result: Works, but system diverges from base image
```

**Option B: Fork image (maintains reproducibility)**
```bash
# User forks fedpunk-images repo
# Edits recipe.yml:
install:
  - hyprland
  - waybar
  - nvidia-driver  # ADD THIS

# Pushes to GitHub
# Actions builds: ghcr.io/username/fedpunk-hyprland-nvidia

# Rebase to custom image
rpm-ostree rebase docker://ghcr.io/username/fedpunk-hyprland-nvidia:latest
systemctl reboot

# Deploy NVIDIA module (configs)
fedpunk module deploy community/nvidia-tweaks

# Result: Fully reproducible custom image
```

**Recommendation:** Option B for power users, Option A for testing.

### Example 3: User wants personal plugin

```bash
# User has plugin in their fedpunk fork
# profiles/dev/plugins/fancontrol/

# Deploy from profile
fedpunk profile activate dev
fedpunk module deploy plugins/fancontrol

# Linker deploys plugin configs
# Plugin scripts run

# Result: Personal plugin on top of base image
```

## Module System Evolution

### Before (Traditional Install)

```yaml
# modules/hyprland/module.yaml
packages:
  dnf:
    - hyprland
    - waybar
    - kitty

configs:
  .config/hypr/hyprland.conf
  .config/waybar/config

lifecycle:
  install:
    - setup-hyprland.sh
```

**Both packages AND configs** installed at runtime.

### After (Image-Based)

**Base Module (in image):**
```yaml
# modules/hyprland/module.yaml
module:
  name: hyprland
  type: base

# Packages: MOVED TO IMAGE RECIPE
# (not here anymore)

configs:
  .config/hypr/hyprland.conf  # Minimal defaults
  .config/waybar/config       # Basic setup

lifecycle:
  install:
    - setup-hyprland.sh
```

Installed in image build, deployed to `/etc/skel`.

**Community Module (runtime):**
```yaml
# community/catppuccin-hyprland/module.yaml
module:
  name: catppuccin-hyprland
  type: config-only
  requires: hyprland  # Base module must exist

packages:
  # NONE - image already has Hyprland

configs:
  .config/hypr/themes/catppuccin.conf
  .config/waybar/catppuccin.css

lifecycle:
  after:
    - select-theme.sh  # Switch to catppuccin
```

User runs: `fedpunk module deploy community/catppuccin-hyprland`

## Community Module Ecosystem

### Module Registry

```
fedpunk-modules/  (separate repo)
├── themes/
│   ├── tokyo-night/
│   ├── catppuccin/
│   ├── nord/
│   └── gruvbox/
├── tweaks/
│   ├── nvidia/
│   ├── gaming/
│   └── battery-saver/
├── tools/
│   ├── screenshot-utils/
│   ├── screen-recording/
│   └── vpn-configs/
└── index.yml  # Module registry
```

**Installation:**
```bash
# Add community registry
fedpunk registry add https://github.com/fedpunk/modules

# Browse available modules
fedpunk module search theme

# Install community module
fedpunk module deploy community/tokyo-night

# Module downloaded, configs deployed
# No rebuild needed!
```

### Module Types in Registry

**1. Config-only modules** (no packages)
- Themes
- Keybinding sets
- Launcher configs
- Works on any image

**2. Package-optional modules** (packages recommended but optional)
- Screenshot tools (can work with built-in scrot, better with flameshot)
- File managers (Hyprland has default, module adds yazi)
- User can layer package or use without

**3. Package-required modules** (must have packages)
- NVIDIA drivers
- Gaming optimizations
- Marks: "Requires fork/layer"

## Opt-in Features

### Feature Flags (Runtime)

```yaml
# ~/.config/fedpunk/config.yml
features:
  nvidia: true          # Enable NVIDIA tweaks
  gaming: true          # Gaming optimizations
  battery-saver: false  # Disable on desktop
```

**Modules check flags:**
```fish
# module script
if test (fedpunk feature-enabled nvidia)
    # Apply NVIDIA configs
end
```

**Benefits:**
- No image rebuild
- Toggle at runtime
- User controls

### Conditional Modules in Profile

```yaml
# profiles/dev/modes/desktop.yaml
modules:
  - hyprland
  - waybar
  - kitty

  # Optional modules
  - if: has-nvidia
    then: community/nvidia-tweaks

  - if: has-wacom
    then: community/wacom-config
```

Deployed conditionally based on hardware detection.

## Personal Customization

### User Fork Workflow

**For heavy customization:**

```bash
# 1. Fork fedpunk-images
git clone github.com/fedpunk/images myname/fedpunk-custom

# 2. Customize recipe
vim config/recipe.yml

install:
  - hyprland
  - waybar
  - MY_CUSTOM_PACKAGES  # Add yours

modules:
  - hyprland
  - MY_CUSTOM_MODULES   # Add yours

# 3. Push (auto-builds)
git push

# 4. Use your custom image
rpm-ostree rebase docker://ghcr.io/myname/fedpunk-custom:latest

# Result: Your perfect image, fully reproducible
```

**For light customization:**
```bash
# Just use runtime modules
fedpunk module deploy community/xyz
fedpunk module deploy plugins/abc

# Plus user overrides
vim ~/.config/hypr/hyprland.conf
```

## Image Inheritance

**Base → Variant → Personal**

```
fedpunk/base (uCore + Fish + essentials)
  ├─→ fedpunk/hyprland (+ Hyprland packages)
  │     ├─→ fedpunk/hyprland-nvidia (+ NVIDIA)
  │     └─→ user/hyprland-custom (+ personal)
  └─→ fedpunk/dev (+ dev tools)
        └─→ user/dev-custom (+ personal)
```

**Build recipes inherit:**
```yaml
# fedpunk-hyprland-nvidia.yml
base-image: ghcr.io/fedpunk/hyprland:latest

# Only add NVIDIA stuff
install:
  - nvidia-driver
  - nvidia-settings

# Inherits all Hyprland packages from parent
```

## Decision Matrix: When to Use What

| Use Case | Solution | Reproducible? | Effort |
|----------|----------|---------------|--------|
| Want base Hyprland | Rebase to fedpunk/hyprland | ✅ Yes | Low |
| Want different theme | Deploy community module | ✅ Yes | Low |
| Want NVIDIA (testing) | Layer package | ❌ No | Low |
| Want NVIDIA (permanent) | Fork image, rebuild | ✅ Yes | Medium |
| Want personal tweaks | User overrides | ⚠️ Partial | Low |
| Want shareable custom setup | Fork image, publish | ✅ Yes | High |

## Benefits of This Architecture

✅ **Reproducible base** - Images are bit-identical
✅ **Dynamic customization** - Modules deploy at runtime
✅ **Community ecosystem** - Anyone can publish modules
✅ **Personal freedom** - User overrides anything
✅ **No rebuild required** - For config-only changes
✅ **Rebuild available** - For package changes (maintains reproducibility)

## Example User Journeys

### Journey 1: Casual User
```bash
# Day 1: Get started
rpm-ostree rebase fedpunk/hyprland:latest
systemctl reboot

# Day 5: Want different theme
fedpunk module deploy community/catppuccin

# Day 30: Tweak keybindings
vim ~/.config/hypr/keybindings.conf

# No rebuilds, fully customized
```

### Journey 2: Power User
```bash
# Fork fedpunk-images
# Add: NVIDIA, gaming tools, personal packages
# Build custom image

rpm-ostree rebase myuser/fedpunk-gaming:latest
systemctl reboot

# Perfect gaming rig, reproducible
# Share with friends: "Use myuser/fedpunk-gaming"
```

### Journey 3: Theme Creator
```bash
# Create community module
fedpunk-modules/themes/my-awesome-theme/
  ├── module.yaml
  └── configs/

# Publish to fedpunk-modules repo
# Users install: fedpunk module deploy community/my-awesome-theme

# No image rebuild needed!
```

## Implementation Notes

### Module Metadata

```yaml
# module.yaml
module:
  name: tokyo-night-theme
  type: config-only  # NEW FIELD
  requires:          # NEW FIELD
    - hyprland
  conflicts:         # NEW FIELD
    - community/catppuccin

packages:
  dnf: []  # Empty for config-only

configs:
  # Same as before
```

### Linker Enhancements

```fish
# linker.fish
function linker-deploy
    # Check if module type is config-only
    if module-type-is config-only
        # Deploy configs only
        deploy-configs-to-home
    else
        # Module has packages
        if is-atomic-desktop
            echo "⚠️  This module requires packages."
            echo "Options:"
            echo "  1. Layer packages (quick, breaks reproducibility)"
            echo "  2. Fork image and rebuild (maintains reproducibility)"
            prompt-user-choice
        end
    end
end
```

## Summary

**Images ≠ Complete Environments**
**Images = Package Foundation**

**Customization Layers:**
1. **Image** - Reproducible package base
2. **Modules** - Dynamic config layer
3. **User** - Personal overrides

**This preserves:**
- ✅ Reproducibility (images)
- ✅ Ecosystem (modules)
- ✅ Flexibility (user overrides)
- ✅ Community (module registry)

**Bottom line:** We're not forgetting the ecosystem - we're making it better by separating package infrastructure (static, reproducible) from configuration (dynamic, customizable).
