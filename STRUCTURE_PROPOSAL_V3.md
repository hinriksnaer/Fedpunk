# Fedpunk Structure Proposal V3
## Package-Centric Organization

### Concept

**Package as the primary organizational unit:**
- Each package gets its own directory under `packages/`
- `run_` prefix in script name defines execution semantics
- Clear, modular, easy to navigate

```
packages/neovim/
  ├── run_onchange_install.fish.tmpl      # Reruns when script changes
  └── run_onchange_treesitter.fish.tmpl   # Reruns when script changes

packages/podman/
  ├── run_once_install.fish.tmpl          # Runs once only
  └── run_once_configure.fish.tmpl        # Runs once only
```

---

## Directory Structure

```
home/
├── dot_config/                         # User configs (deploy to ~/.config/)
│   ├── fish/
│   ├── nvim/
│   ├── tmux/
│   ├── hypr/
│   └── ...
│
├── dot_local/                          # User local files (deploy to ~/.local/)
│   ├── bin/
│   └── ...
│
└── .install/                           # Installation infrastructure (isolated)
    ├── lib/
    │   └── helpers.fish                # Shared helper functions
    │
    ├── bootstrap/                      # Core system bootstrap
    │   ├── run_before_00-preflight.fish.tmpl
    │   ├── run_before_01-mode-config.fish.tmpl
    │   ├── run_before_10-desktop-init.fish.tmpl
    │   └── run_after_90-finalize.fish.tmpl
    │
    └── packages/                       # All packages (alphabetical)
        ├── audio/
        │   └── run_onchange_install.fish.tmpl
        │
        ├── bitwarden/
        │   └── run_once_configure.fish.tmpl
        │
        ├── bluetooth/
        │   └── run_onchange_install.fish.tmpl
        │
        ├── btop/
        │   └── run_onchange_install.fish.tmpl
        │
        ├── cli-tools/
        │   └── run_onchange_install.fish.tmpl
        │
        ├── claude/
        │   └── run_once_configure.fish.tmpl
        │
        ├── devcontainer/
        │   └── run_once_install.fish.tmpl
        │
        ├── extra-apps/
        │   └── run_onchange_install.fish.tmpl
        │
        ├── firefox/
        │   └── run_onchange_install.fish.tmpl
        │
        ├── fonts/
        │   └── run_onchange_install.fish.tmpl
        │
        ├── gh/
        │   └── run_onchange_install.fish.tmpl
        │
        ├── hyprland/
        │   ├── run_onchange_install.fish.tmpl
        │   └── run_onchange_plugins.fish.tmpl
        │
        ├── kitty/
        │   └── run_onchange_install.fish.tmpl
        │
        ├── languages/
        │   └── run_onchange_install.fish.tmpl
        │
        ├── lazygit/
        │   └── run_onchange_install.fish.tmpl
        │
        ├── multimedia/
        │   └── run_onchange_install.fish.tmpl
        │
        ├── neovim/
        │   ├── run_onchange_install.fish.tmpl
        │   └── run_onchange_treesitter.fish.tmpl
        │
        ├── nvidia/
        │   └── run_onchange_install.fish.tmpl
        │
        ├── nvim-mcp/
        │   └── run_once_install.fish.tmpl
        │
        ├── podman/
        │   ├── run_once_install.fish.tmpl
        │   └── run_once_configure.fish.tmpl
        │
        ├── rofi/
        │   └── run_onchange_install.fish.tmpl
        │
        ├── tmux/
        │   ├── run_onchange_install.fish.tmpl
        │   └── run_onchange_plugins.fish.tmpl
        │
        └── yazi/
            └── run_onchange_install.fish.tmpl
```

**Directory Separation:**
- `dot_config/`, `dot_local/` - Actual dotfiles that deploy to `~/`
- `.install/` - Installation infrastructure (scripts, helpers, bootstrap)
- Clear separation prevents confusion and accidental modifications

---

## Benefits

### 1. Package-Centric Navigation
```bash
ls packages/          # See all packages alphabetically
ls packages/neovim/   # See all neovim-related scripts
```

### 2. Clear Execution Semantics (from filename)
```
run_before_*    → Runs before file deployment (bootstrap)
run_onchange_*  → Runs when script content changes
run_once_*      → Runs once ever (tracked in state)
run_after_*     → Runs after file deployment (finalization)
```

### 3. Easy to Add/Remove Packages
```bash
# Add new package
mkdir packages/starship
cat > packages/starship/run_onchange_install.fish.tmpl

# Remove package
rm -rf packages/tmux
```

### 4. Component Modularity
Each package can have multiple scripts:
```
tmux/
  ├── run_onchange_install.fish.tmpl    # Install binary
  └── run_onchange_plugins.fish.tmpl    # Setup TPM
```

### 5. Template Conditionals Apply Per-Package
```fish
{{- if .install.neovim }}
# Entire packages/neovim/ directory only created when enabled
{{- end }}
```

---

## Naming Conventions

### Directory Names
- `.install/` - All installation infrastructure (dot-prefix keeps it separate)
- `.install/bootstrap/` - Core system initialization
- `.install/packages/` - All installable components
- `.install/lib/` - Shared utilities
- `dot_config/` - User configurations
- `dot_local/` - User local files

### Package Names
- Lowercase, kebab-case: `neovim`, `cli-tools`, `nvim-mcp`
- Descriptive: `extra-apps`, `multimedia`, `languages`

### Script Names
```
run_{when}_{purpose}.fish.tmpl

{when}     → before | onchange | once | after
{purpose}  → install | configure | plugins | treesitter | etc.
```

**Bootstrap scripts need ordering:**
```
run_before_00-preflight.fish.tmpl    # Order: 00
run_before_01-mode-config.fish.tmpl  # Order: 01
run_before_10-desktop-init.fish.tmpl # Order: 10
run_after_90-finalize.fish.tmpl      # Order: 90
```

**Package scripts (alphabetical order is fine):**
```
run_onchange_install.fish.tmpl       # No ordering needed
run_onchange_plugins.fish.tmpl       # Alphabetical is fine
```

**If package needs specific order:**
```
neovim/
  ├── run_onchange_00-install.fish.tmpl     # First
  ├── run_onchange_10-plugins.fish.tmpl     # Second
  └── run_onchange_20-treesitter.fish.tmpl  # Third
```

---

## Standardized Environment Variables

Set once in `.install/bootstrap/run_before_00-preflight.fish.tmpl`:

```fish
# Path variables
set -gx FEDPUNK_REPO_ROOT "{{ .chezmoi.workingTree }}"
set -gx FEDPUNK_HOME_DIR "{{ .chezmoi.sourceDir }}"
set -gx FEDPUNK_HELPERS "$FEDPUNK_REPO_ROOT/home/.install/lib/helpers.fish"

# Mode/config variables
set -gx FEDPUNK_MODE "{{ .mode.name }}"
set -gx FEDPUNK_LOG_FILE "/tmp/fedpunk-install-$(date +%Y%m%d-%H%M%S).log"
```

**All other scripts use:**
```fish
source "$FEDPUNK_HELPERS"
```

---

## Script Templates

### Bootstrap Script Template

```fish
#!/usr/bin/env fish
# ============================================================================
# BOOTSTRAP: <Purpose>
# ============================================================================
# Purpose:
#   - <What it does>
# Runs: <before|after> file deployment
# Order: <number>
# ============================================================================

# Set environment variables (only in 00-preflight)
set -gx FEDPUNK_REPO_ROOT "{{ .chezmoi.workingTree }}"
set -gx FEDPUNK_HELPERS "$FEDPUNK_REPO_ROOT/home/lib/helpers.fish"
set -gx FEDPUNK_MODE "{{ .mode.name }}"

source "$FEDPUNK_HELPERS"

section "<Section Name>"

# Implementation
subsection "Doing something"
step "Description" "command"

echo ""
box "Complete!" $GUM_SUCCESS
```

### Package Install Script Template

```fish
{{- if .install.package }}
#!/usr/bin/env fish
# ============================================================================
# Package: <Name>
# Purpose: <What this does>
# Category: <terminal|gui|system>
# ============================================================================

source "$FEDPUNK_HELPERS"

section "<Package> <Action>"

subsection "Installing <package>"
if command -v <binary> >/dev/null 2>&1
    success "<Package> already installed"
else
    step "Installing <package>" "sudo dnf install -qy <packages>"
end

echo ""
box "<Package> Installation Complete!" $GUM_SUCCESS
{{- end }}
```

### Package Setup Script Template

```fish
{{- if .install.package }}
#!/usr/bin/env fish
# ============================================================================
# Package: <Name>
# Purpose: <Configuration/setup>
# Category: <terminal|gui|system>
# ============================================================================

source "$FEDPUNK_HELPERS"

section "<Package> Setup"

subsection "Configuring <package>"
# Configuration logic

echo ""
box "<Package> Setup Complete!" $GUM_SUCCESS
{{- end }}
```

---

## Execution Flow

```
┌─────────────────────────────────────────────────────┐
│  .install/bootstrap/                                │
│    ├─ run_before_00-preflight     → Env, DNF       │
│    ├─ run_before_01-mode-config   → Load YAML      │
│    └─ run_before_10-desktop-init  → Desktop prep   │
├─────────────────────────────────────────────────────┤
│  📁 CHEZMOI APPLIES FILES                           │
│     dot_config/ → ~/.config/                        │
│     dot_local/ → ~/.local/                          │
├─────────────────────────────────────────────────────┤
│  .install/packages/ (alphabetical order)            │
│    ├─ audio/run_onchange_*                         │
│    ├─ bitwarden/run_once_*                         │
│    ├─ bluetooth/run_onchange_*                     │
│    ├─ btop/run_onchange_*                          │
│    ├─ cli-tools/run_onchange_*                     │
│    ├─ ... (all packages)                           │
│    ├─ tmux/run_onchange_*                          │
│    └─ yazi/run_onchange_*                          │
├─────────────────────────────────────────────────────┤
│  .install/bootstrap/                                │
│    └─ run_after_90-finalize       → Summary        │
└─────────────────────────────────────────────────────┘
```

**Note:** Chezmoi executes scripts in lexicographical order:
1. `bootstrap/run_before_*` (ordered by number)
2. Files deployed
3. `packages/*/run_onchange_*` (alphabetical by package)
4. `packages/*/run_once_*` (alphabetical by package)
5. `bootstrap/run_after_*` (ordered by number)

---

## Mode-Specific Package Management

### Mode YAML Configuration

**modes/desktop.yaml:**
```yaml
mode:
  name: desktop
  description: Full desktop environment

install:
  # Terminal tools (all modes)
  tmux: true
  neovim: true
  yazi: true
  btop: true
  gh: true
  lazygit: true
  cli-tools: true

  # GUI apps (desktop/laptop only)
  kitty: true
  hyprland: true
  firefox: true
  rofi: true
  fonts: true
  extra-apps: true

  # System components
  audio: true
  bluetooth: true
  multimedia: true
  nvidia: false  # Prompt if GPU detected
  languages: true

  # One-time setup
  podman: true
  devcontainer: true
  nvim-mcp: true
  claude: true
  bitwarden: true
```

**modes/container.yaml:**
```yaml
mode:
  name: container
  description: Minimal container environment

install:
  # Terminal tools only
  tmux: true
  neovim: true
  yazi: true
  btop: true
  gh: true
  lazygit: true
  cli-tools: true

  # No GUI
  kitty: false
  hyprland: false
  firefox: false
  rofi: false
  fonts: false
  extra-apps: false

  # No system components
  audio: false
  bluetooth: false
  multimedia: false
  nvidia: false
  languages: true

  # No setup tools
  podman: false
  devcontainer: false
  nvim-mcp: false
  claude: false
  bitwarden: false
```

### Template Conditionals

**Simple conditional (enabled in mode):**
```fish
{{- if .install.neovim }}
#!/usr/bin/env fish
# Script content
{{- end }}
```

**Conditional with mode check (GUI apps):**
```fish
{{- if and .install.hyprland (ne .mode.name "container") }}
#!/usr/bin/env fish
# Script content
{{- end }}
```

---

## Migration Plan

### Step 1: Create new structure
```bash
cd ~/.local/share/fedpunk

# Create .install directory structure
mkdir -p home/.install/lib
mkdir -p home/.install/bootstrap
mkdir -p home/.install/packages
```

### Step 2: Move helpers
```bash
git mv home/core/lib/helpers.fish home/.install/lib/helpers.fish
```

### Step 3: Move bootstrap scripts
```bash
git mv home/core/run_before_00_preflight.fish.tmpl \
       home/.install/bootstrap/run_before_00-preflight.fish.tmpl

git mv home/core/run_before_01_mode_config.fish.tmpl \
       home/.install/bootstrap/run_before_01-mode-config.fish.tmpl

git mv home/desktop/run_before_10_desktop_setup.fish.tmpl \
       home/.install/bootstrap/run_before_10-desktop-init.fish.tmpl

git mv home/post-install/run_after_50_finalize.fish.tmpl \
       home/.install/bootstrap/run_after_90-finalize.fish.tmpl
```

### Step 4: Create package directories and move scripts
```bash
# Helper function to create package and move script
create_package() {
  local pkg=$1
  local old_path=$2
  local new_name=$3

  mkdir -p home/.install/packages/$pkg
  git mv $old_path home/.install/packages/$pkg/$new_name
}

# Terminal packages
create_package tmux home/terminal/run_onchange_install_tmux.fish.tmpl run_onchange_install.fish.tmpl
create_package neovim home/terminal/run_onchange_install_neovim.fish.tmpl run_onchange_install.fish.tmpl
create_package yazi home/terminal/run_onchange_install_yazi.fish.tmpl run_onchange_install.fish.tmpl
create_package btop home/terminal/run_onchange_install_btop.fish.tmpl run_onchange_install.fish.tmpl
create_package gh home/terminal/run_onchange_install_gh.fish.tmpl run_onchange_install.fish.tmpl
create_package lazygit home/terminal/run_onchange_install_lazygit.fish.tmpl run_onchange_install.fish.tmpl
create_package cli-tools home/terminal/run_onchange_install_cli_tools.fish.tmpl run_onchange_install.fish.tmpl

# GUI packages
create_package hyprland home/gui/run_onchange_install_hyprland.fish.tmpl run_onchange_install.fish.tmpl
create_package kitty home/gui/run_onchange_install_kitty.fish.tmpl run_onchange_install.fish.tmpl
create_package firefox home/gui/run_onchange_install_firefox.fish.tmpl run_onchange_install.fish.tmpl
create_package rofi home/gui/run_onchange_install_rofi.fish.tmpl run_onchange_install.fish.tmpl
create_package fonts home/gui/run_onchange_install_fonts.fish.tmpl run_onchange_install.fish.tmpl
create_package extra-apps home/gui/run_onchange_install_extra_apps.fish.tmpl run_onchange_install.fish.tmpl

# System packages
create_package audio home/system/run_onchange_install_audio.fish.tmpl run_onchange_install.fish.tmpl
create_package bluetooth home/system/run_onchange_install_bluetooth.fish.tmpl run_onchange_install.fish.tmpl
create_package multimedia home/system/run_onchange_install_multimedia.fish.tmpl run_onchange_install.fish.tmpl
create_package nvidia home/system/run_onchange_install_nvidia.fish.tmpl run_onchange_install.fish.tmpl
create_package languages home/system/run_onchange_install_languages.fish.tmpl run_onchange_install.fish.tmpl

# Setup packages (run_once)
create_package podman home/setup/run_once_setup_podman.fish.tmpl run_once_install.fish.tmpl
create_package devcontainer home/setup/run_once_setup_devcontainer.fish.tmpl run_once_install.fish.tmpl
create_package nvim-mcp home/setup/run_once_install_nvim_mcp.fish.tmpl run_once_install.fish.tmpl
create_package claude home/setup/run_once_setup_claude.fish.tmpl run_once_configure.fish.tmpl
create_package bitwarden home/setup/run_once_setup_bitwarden.fish.tmpl run_once_configure.fish.tmpl
```

### Step 5: Update all scripts
- Set environment variables in `.install/bootstrap/run_before_00-preflight.fish.tmpl`
- Update FEDPUNK_HELPERS path: `$FEDPUNK_REPO_ROOT/home/.install/lib/helpers.fish`
- Replace all helper sourcing with `source "$FEDPUNK_HELPERS"`
- Standardize headers
- Verify template conditionals
- Update component references (e.g., "Component: Tmux" → "Package: tmux")

### Step 6: Clean up old directories
```bash
rmdir home/core/lib
rmdir home/core
rmdir home/terminal
rmdir home/gui
rmdir home/system
rmdir home/setup
rmdir home/desktop
rmdir home/post-install
```

### Step 7: Test
- Test container mode: `chezmoi apply --dry-run`
- Test desktop mode: `chezmoi apply --dry-run`
- Verify git history: `git log --follow home/packages/neovim/run_onchange_install.fish.tmpl`
- Check script execution order

---

## Examples

### Adding a New Package

**1. Create package directory:**
```bash
mkdir home/.install/packages/starship
```

**2. Create install script:**
```bash
cat > home/.install/packages/starship/run_onchange_install.fish.tmpl << 'EOF'
{{- if .install.starship }}
#!/usr/bin/env fish
# ============================================================================
# Package: starship
# Purpose: Install starship cross-shell prompt
# Category: terminal
# ============================================================================

source "$FEDPUNK_HELPERS"

section "Starship Installation"

subsection "Installing starship"
if command -v starship >/dev/null 2>&1
    success "Starship already installed"
else
    step "Enabling COPR" "sudo dnf copr enable -qy atim/starship"
    step "Installing starship" "sudo dnf install -qy starship"
end

echo ""
box "Starship Installation Complete!" $GUM_SUCCESS
{{- end }}
EOF
```

**3. Add to mode YAML:**
```yaml
install:
  starship: true
```

**Done!** Package is integrated.

### Multi-Script Package

**tmux package with multiple scripts:**

```
.install/packages/tmux/
  ├── run_onchange_00-install.fish.tmpl
  └── run_onchange_10-plugins.fish.tmpl
```

**run_onchange_00-install.fish.tmpl:**
```fish
{{- if .install.tmux }}
#!/usr/bin/env fish
# ============================================================================
# Package: tmux
# Purpose: Install tmux terminal multiplexer
# Category: terminal
# ============================================================================

source "$FEDPUNK_HELPERS"

section "Tmux Installation"

subsection "Installing tmux"
install_if_missing tmux tmux

echo ""
box "Tmux Installation Complete!" $GUM_SUCCESS
{{- end }}
```

**run_onchange_10-plugins.fish.tmpl:**
```fish
{{- if .install.tmux }}
#!/usr/bin/env fish
# ============================================================================
# Package: tmux
# Purpose: Install Tmux Plugin Manager (TPM)
# Category: terminal
# ============================================================================

source "$FEDPUNK_HELPERS"

section "Tmux Plugin Manager"

subsection "Installing TPM"
if test -d "$HOME/.tmux/plugins/tpm"
    success "TPM already installed"
else
    step "Cloning TPM" "git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm"
end

echo ""
box "TPM Installation Complete!" $GUM_SUCCESS
{{- end }}
```

Scripts run in order: `00-install` before `10-plugins`.

---

## Summary

### Key Principles

1. **Package-centric** - Each package is self-contained
2. **Clear execution semantics** - `run_` prefix tells you when it runs
3. **Alphabetical organization** - Easy to navigate
4. **Modular** - Packages can have multiple scripts
5. **Template conditionals** - Packages only created when enabled

### Structure Overview

```
home/
├── dot_config/                # User configs → ~/.config/
├── dot_local/                 # User local → ~/.local/
└── .install/                  # Installation infrastructure
    ├── lib/helpers.fish       # Shared utilities
    ├── bootstrap/             # Core system (ordered)
    │   ├── run_before_00-*
    │   ├── run_before_01-*
    │   ├── run_before_10-*
    │   └── run_after_90-*
    └── packages/              # All packages (alphabetical)
        ├── audio/
        ├── neovim/
        ├── podman/
        ├── tmux/
        └── ...
```

Simple, clean, intuitive, isolated!
