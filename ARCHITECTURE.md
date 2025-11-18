# Fedpunk Architecture

## Design Philosophy

Fedpunk uses a **three-layer configuration system** that prioritizes **fast switching** over pure declarative configuration. This is an intentional architectural choice optimized for environments where you frequently change profiles and themes.

```
┌─────────────────────────────────────────┐
│  Layer 1: Base Configuration (Chezmoi) │  ← Immutable, version-controlled
├─────────────────────────────────────────┤
│  Layer 2: Profile Overlays (Runtime)   │  ← Switchable without redeployment
├─────────────────────────────────────────┤
│  Layer 3: Theme Symlinks (Live)        │  ← Instant visual changes
└─────────────────────────────────────────┘
```

---

## Layer 1: Base Configuration (Chezmoi)

**Purpose:** Deploy core dotfiles to the system

**Location:** `home/` directory (chezmoi source)

**Managed Files:**
- Fish shell configuration
- Hyprland window manager
- Kitty terminal
- Neovim editor
- Tmux multiplexer
- Rofi launcher
- Waybar status bar
- btop system monitor
- Lazygit git TUI

**Deployment:**
```bash
chezmoi apply
```

**Key Features:**
- Template support for machine-specific configs (`.tmpl` files)
- Conditional deployment based on terminal-only mode
- Auto-detection of NVIDIA hardware
- Single source of truth for base configs

**Why Not Use Chezmoi for Everything?**

We *could* use chezmoi templates for profiles and themes:

```toml
# ~/.config/chezmoi/chezmoi.toml
[data]
    profile = "dev"
    theme = "nord"
```

```fish
# config.fish.tmpl
{{- if eq .profile "dev" }}
alias vault='fedpunk vault'
{{- end }}
```

**Trade-offs:**
- ✅ Pure infrastructure-as-code
- ✅ Single source of truth
- ❌ Requires `chezmoi apply` to switch (slow)
- ❌ No live theme experimentation
- ❌ Complex templates for dynamic behavior

**Our Choice:** Use chezmoi for base configs that rarely change, runtime overlays for configs that change frequently.

---

## Layer 2: Profile System (Runtime Overlays)

**Purpose:** Environment-specific customizations without modifying base configs

**Location:** `profiles/<name>/` directories

**How It Works:**
1. Active profile is symlinked: `.active-config -> profiles/dev`
2. Profile configs are **sourced at runtime**, not deployed
3. Fish shell sources `profiles/<active>/config.fish` on startup
4. Hyprland includes `profiles/<active>/keybinds.conf` on startup

**Profile Structure:**
```
profiles/dev/
├── fedpunk.toml      # Metadata and package list
├── config.fish       # Fish shell additions (sourced at runtime)
├── keybinds.conf     # Hyprland keybindings (included at runtime)
└── scripts/          # Profile-specific utilities (added to PATH)
```

**Switching Profiles:**
```bash
fedpunk profile activate work    # Instant switch
exec fish                        # Reload shell
```

**Why Runtime Sourcing Instead of Chezmoi?**

**Option A: Chezmoi Templates** (rejected)
```bash
chezmoi data set profile work
chezmoi apply  # SLOW: regenerates all templates
```

**Option B: Runtime Sourcing** (chosen)
```bash
ln -sf profiles/work .active-config
exec fish      # FAST: just reload shell
```

**Benefits:**
- ✅ Instant profile switching (no redeployment)
- ✅ Test new profiles without committing
- ✅ Perfect for work/personal/dev environments
- ✅ Scripts added to PATH dynamically

**Trade-offs:**
- ❌ Two sources of configuration (base + profile)
- ❌ Profile changes not visible in chezmoi diff
- ✅ This is acceptable for configs that change frequently

---

## Layer 3: Theme System (Symlink-Based)

**Purpose:** Live visual customization without redeployment

**Location:** `themes/<name>/` directories

**How It Works:**
1. Each app config includes a symlinked theme file
2. Theme symlink points to active theme: `~/.config/kitty/theme.conf -> themes/nord/kitty.conf`
3. Switching themes updates symlinks and reloads apps
4. No chezmoi deployment needed

**Theme Structure:**
```
themes/nord/
├── hyprland.conf    # Window manager colors
├── kitty.conf       # Terminal colors
├── rofi.rasi        # Launcher theme
├── waybar.css       # Status bar styling
├── mako.ini         # Notification styling
├── btop.theme       # System monitor colors
├── neovim.lua       # Editor colorscheme
└── backgrounds/     # Wallpapers
```

**Switching Themes:**
```bash
fedpunk theme set catppuccin    # Updates symlinks + reloads
# OR
fedpunk theme select            # Interactive picker (fzf)
# OR
fedpunk theme next              # Cycle through themes
```

**Why Symlinks Instead of Chezmoi?**

**Option A: Chezmoi Templates** (rejected)
```bash
chezmoi data set theme catppuccin
chezmoi apply  # SLOW: regenerates configs
# Apps need manual reload
```

**Option B: Symlinks** (chosen)
```bash
ln -sf themes/catppuccin/kitty.conf ~/.config/kitty/theme.conf
kitty @ set-colors ~/.config/kitty/theme.conf  # Live reload
```

**Benefits:**
- ✅ Instant theme switching
- ✅ Live reloading (terminal colors update immediately)
- ✅ Easy to test new themes
- ✅ Wallpapers bundled with themes

**Trade-offs:**
- ❌ Theme symlinks ignored by chezmoi (managed separately)
- ❌ 16 `fedpunk-theme-*` scripts to maintain
- ✅ Worth it for live experimentation

---

## Configuration Templating

### Machine-Specific Configs (Chezmoi Templates)

Some configs need to adapt to the machine environment:

**Auto-Detection:**
- NVIDIA graphics card → Add Wayland env vars
- Terminal-only mode → Skip desktop configs
- Cargo installed → Add to PATH

**Example: `installer-managed.fish.tmpl`**
```fish
# Rust/Cargo PATH
{{- if or (lookPath "cargo") (stat (joinPath .chezmoi.homeDir ".cargo" "bin" "cargo")) }}
fish_add_path -g $HOME/.cargo/bin
{{- end }}

# NVIDIA Wayland support (auto-detected)
{{- if or (lookPath "nvidia-smi") (stat "/proc/driver/nvidia/version") }}
set -gx LIBVA_DRIVER_NAME nvidia
set -gx XDG_SESSION_TYPE wayland
set -gx GBM_BACKEND nvidia-drm
set -gx __GLX_VENDOR_LIBRARY_NAME nvidia
set -gx WLR_NO_HARDWARE_CURSORS 1
{{- end }}
```

**Conditional Deployment: `.chezmoiignore.tmpl`**
```
{{- if eq (env "FEDPUNK_TERMINAL_ONLY") "true" }}
# Skip desktop configs in terminal-only mode
.config/hypr/**
.config/kitty/**
.config/waybar/**
{{- end }}
```

---

## Installation System

### Modular Installation Scripts

**Structure:**
```
install/
├── helpers/all.fish           # Shared functions (info, success, step)
├── preflight/                 # System setup (runs first)
│   └── shared/
│       ├── setup-system.fish  # DNF config, essentials
│       ├── setup-cargo.fish   # Rust toolchain
│       └── setup-fish.fish    # Fish shell, chezmoi, starship
├── terminal/                  # Terminal-only components
│   ├── packaging/             # Tool installation
│   │   ├── claude.fish        # Claude Code CLI
│   │   ├── gh.fish            # GitHub CLI
│   │   └── yazi.fish          # File manager
│   └── config/                # Configuration
│       ├── neovim.fish        # Editor setup
│       ├── tmux.fish          # Multiplexer setup
│       └── btop.fish          # System monitor
├── desktop/                   # Desktop components (conditional)
│   ├── preflight/
│   │   └── setup-desktop-system.fish
│   ├── packaging/
│   │   ├── fonts.fish
│   │   ├── nvidia.fish
│   │   ├── audio.fish
│   │   └── multimedia.fish
│   └── config/
│       ├── hyprland.fish
│       ├── kitty.fish
│       └── rofi.fish
└── post-install/              # Final setup
    ├── setup-themes.fish      # Theme system
    ├── setup-claude-code.fish # Claude integration
    └── optimize-system.fish   # Performance tuning
```

### Installation Flow

```
1. Preflight → System setup (cargo, fish, chezmoi)
   ├── DNF configuration
   ├── Rust toolchain
   ├── Fish shell + starship + fisher
   └── chezmoi installation

2. Terminal Packaging → CLI tools
   ├── Claude Code CLI
   ├── GitHub CLI
   ├── Yazi file manager
   └── Other Rust tools

3. Chezmoi Apply → Deploy base configs
   └── All dotfiles in home/ deployed

4. Terminal Config → Configure terminal apps
   ├── Neovim setup
   ├── Tmux plugin installation
   └── btop theme setup

5. Desktop Packaging → Desktop apps (if not --terminal-only)
   ├── Fonts
   ├── NVIDIA drivers
   ├── Audio system
   └── Multimedia tools

6. Desktop Config → Configure desktop (if not --terminal-only)
   ├── Hyprland setup
   ├── Kitty terminal
   └── Rofi launcher

7. Post-Install → Final configuration
   ├── Theme system setup
   ├── Claude Code integration
   └── System optimizations
```

---

## Why This Architecture?

### Use Case: Switching Profiles Daily

**Scenario:** You have work, personal, and dev profiles with different aliases, keybindings, and tools.

**Pure Chezmoi Approach:**
```bash
chezmoi data set profile work
chezmoi apply                    # Regenerates ALL configs (slow)
# Wait 5-10 seconds
```

**Fedpunk Approach:**
```bash
fedpunk profile activate work
exec fish                        # Instant (< 0.1s)
```

### Use Case: Experimenting with Themes

**Scenario:** You want to try different color schemes while working.

**Pure Chezmoi Approach:**
```bash
chezmoi data set theme catppuccin
chezmoi apply                    # Regenerates configs
kitty @ reload                   # Manual reload required
nvim +q                          # Restart editor
```

**Fedpunk Approach:**
```bash
fedpunk theme set catppuccin     # Updates symlinks + live reloads
# Terminal colors change instantly
# Keep working in same session
```

### Use Case: Server Deployment

**Scenario:** Deploy dotfiles to a headless server.

**Both Approaches Work:**
```bash
FEDPUNK_TERMINAL_ONLY=true ./boot-terminal.sh
# Chezmoi conditionally skips desktop configs
# Profile system works identically
```

---

## Design Trade-offs

### ✅ Advantages

1. **Fast Switching:** Profile and theme changes are instant
2. **Live Experimentation:** Try themes without commitment
3. **Clear Separation:** Base/Profile/Theme layers have distinct purposes
4. **Server Compatible:** Terminal-only mode skips desktop components
5. **Flexible:** Easy to add new profiles or themes

### ⚠️ Disadvantages

1. **Multiple Sources of Truth:** Base (chezmoi) + Profiles (overlays) + Themes (symlinks)
2. **Custom CLI Required:** `fedpunk` command wraps profile/theme management
3. **Not Pure IaC:** Profile changes not tracked in chezmoi
4. **Learning Curve:** Need to understand three-layer system

---

## When to Use Each Layer

### Modify Base Config (Chezmoi)
- Changing core application settings
- Adding new applications to dotfiles
- Updating configs that apply to all profiles

```bash
# Edit chezmoi source
nvim ~/.local/share/fedpunk/home/dot_config/fish/config.fish
# Apply changes
chezmoi apply
```

### Modify Profile (Runtime Overlay)
- Adding profile-specific aliases
- Customizing keybindings per environment
- Installing profile-specific tools

```bash
# Edit active profile
nvim ~/.local/share/fedpunk/profiles/dev/config.fish
# Reload shell
exec fish
```

### Switch Theme (Symlinks)
- Changing visual appearance
- Testing color schemes
- Matching wallpaper to mood

```bash
fedpunk theme set nord
# OR
fedpunk theme select    # Interactive picker
```

---

## Comparison to Other Approaches

### Pure Chezmoi (Everything Templated)

**Pros:**
- Single source of truth
- Pure infrastructure-as-code
- Git tracks everything

**Cons:**
- Slow switching (requires `chezmoi apply`)
- Complex templates for dynamic behavior
- No live theme reloading

**Best For:** Static configurations that rarely change

---

### GNU Stow (Symlinking Dotfiles)

**Pros:**
- Simple symlink management
- Fast deployment

**Cons:**
- No templating support
- No machine-specific configs
- Manual conflict resolution

**Best For:** Simple dotfile setups

---

### Fedpunk Hybrid Approach

**Pros:**
- Instant profile switching
- Live theme experimentation
- Templating for machine-specific configs
- Server deployment support

**Cons:**
- Multiple configuration systems
- Custom CLI to maintain
- Steeper learning curve

**Best For:** Users who frequently switch profiles/themes and value speed over pure IaC

---

## FAQ

**Q: Why not use chezmoi for profiles too?**

A: Profile switching would require `chezmoi apply` (5-10s), while our runtime overlay approach is instant (< 0.1s). For configs that change daily, runtime sourcing is more practical.

**Q: Why not use chezmoi for themes?**

A: Chezmoi can't reload terminal colors live. Our symlink approach allows `kitty @ set-colors` to update instantly without restarting applications.

**Q: Isn't this over-engineered?**

A: For users with one profile and one theme, yes. For users who switch contexts frequently (work/personal/dev) or experiment with themes daily, the speed gain is significant.

**Q: Can I still use pure chezmoi?**

A: Yes! You can ignore the profile and theme systems and just use chezmoi. The base layer works perfectly standalone.

**Q: How do I add a new profile?**

```bash
fedpunk profile create myprofile
# Edit the new profile
nvim ~/.local/share/fedpunk/profiles/myprofile/config.fish
# Activate it
fedpunk profile activate myprofile
exec fish
```

**Q: How do I add a new theme?**

```bash
# Copy an existing theme as a template
cp -r themes/nord themes/mytheme
# Edit theme files
nvim themes/mytheme/kitty.conf
# Apply it
fedpunk theme set mytheme
```

---

## Summary

Fedpunk's architecture is optimized for **speed and flexibility** at the cost of **purity and simplicity**. It's not the simplest dotfile system, but it's highly effective for users who:

- Switch between multiple environments (work/personal/dev)
- Experiment with different visual themes frequently
- Value instant switching over pure infrastructure-as-code
- Want both desktop and terminal-only deployment options

If you prioritize pure IaC and static configs, consider using pure chezmoi. If you prioritize speed and live customization, Fedpunk's three-layer system is a good fit.
