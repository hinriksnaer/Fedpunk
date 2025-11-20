# Fedpunk Script Structure Refactor Proposal

## Current Issues

### 1. Inconsistent Path Handling
- **3 different helper sourcing patterns:**
  - `source "{{ .chezmoi.sourceDir }}/core/lib/helpers.fish"` (14 files)
  - `source "$FEDPUNK_PATH/core/lib/helpers.fish"` (11 files)
  - `source "$FEDPUNK_PATH/home/core/lib/helpers.fish"` (2 files)

- **FEDPUNK_PATH points to different things:**
  - Core scripts: `.chezmoi.workingTree` (repo root)
  - Install scripts: `.chezmoi.sourceDir` (home/ directory)
  - Confusing and error-prone

### 2. Inconsistent Script Structure
- Some scripts have detailed headers, others minimal
- Mix of inline conditionals vs runtime checks
- No standard sections/ordering

### 3. Variable Naming Confusion
- `FEDPUNK_PATH` - unclear what it points to
- Mix of `FEDPUNK_MODE` and `.mode.name`
- Inconsistent use of environment variables

## Proposed Solution

### 1. Standardized Environment Variables

Set once in preflight, used everywhere:

```fish
# Path variables (set in run_before_00_preflight.fish)
FEDPUNK_REPO_ROOT    → {{ .chezmoi.workingTree }}  # /repo
FEDPUNK_HOME_DIR     → {{ .chezmoi.sourceDir }}    # /repo/home
FEDPUNK_HELPERS      → $FEDPUNK_REPO_ROOT/home/core/lib/helpers.fish

# Mode/config variables
FEDPUNK_MODE         → {{ .mode.name }}            # container|desktop|laptop
FEDPUNK_LOG_FILE     → /tmp/fedpunk-*.log
```

### 2. Standardized Script Structure

**Template for install scripts:**

```fish
{{- if .install.component }}
#!/usr/bin/env fish
# ============================================================================
# Component: <Name>
# Description: <What it does>
# Category: <terminal|gui|system|setup>
# Mode: {{ .mode.name }}
# ============================================================================

source "$FEDPUNK_HELPERS"

section "<Component> Installation"

subsection "Installing <component>"
# Installation logic here

echo ""
box "<Component> Installation Complete!" $GUM_SUCCESS
{{- end }}
```

**Template for core scripts:**

```fish
#!/usr/bin/env fish
# ============================================================================
# CORE: <Purpose>
# ============================================================================
# Purpose:
#   - <What it does>
#   - <Key responsibilities>
# Runs: <When it executes>
# ============================================================================

# Set environment variables
set -gx FEDPUNK_REPO_ROOT "{{ .chezmoi.workingTree }}"
set -gx FEDPUNK_HOME_DIR "{{ .chezmoi.sourceDir }}"
set -gx FEDPUNK_HELPERS "$FEDPUNK_REPO_ROOT/home/core/lib/helpers.fish"
set -gx FEDPUNK_MODE "{{ .mode.name }}"

source "$FEDPUNK_HELPERS"

section "<Section Name>"
# Logic here
```

### 3. File Organization

Organize by **execution phase**, not component type. This makes the flow obvious:

```
home/
├── lib/
│   └── helpers.fish                    # Shared helper functions
│
├── 00-bootstrap/                       # Phase 0: System bootstrap (run_before)
│   ├── run_before_00-preflight.fish.tmpl
│   └── run_before_01-mode-config.fish.tmpl
│
├── 10-desktop/                         # Phase 1: Desktop setup (run_before)
│   └── run_before_10-desktop-init.fish.tmpl
│
├── 20-terminal/                        # Phase 2: Terminal tools (run_onchange)
│   ├── run_onchange_tmux.fish.tmpl
│   ├── run_onchange_neovim.fish.tmpl
│   ├── run_onchange_yazi.fish.tmpl
│   ├── run_onchange_btop.fish.tmpl
│   ├── run_onchange_gh.fish.tmpl
│   ├── run_onchange_lazygit.fish.tmpl
│   └── run_onchange_cli-tools.fish.tmpl
│
├── 30-gui/                             # Phase 3: GUI apps (run_onchange)
│   ├── run_onchange_hyprland.fish.tmpl
│   ├── run_onchange_kitty.fish.tmpl
│   ├── run_onchange_firefox.fish.tmpl
│   ├── run_onchange_rofi.fish.tmpl
│   ├── run_onchange_fonts.fish.tmpl
│   └── run_onchange_extra-apps.fish.tmpl
│
├── 40-system/                          # Phase 4: System components (run_onchange)
│   ├── run_onchange_audio.fish.tmpl
│   ├── run_onchange_bluetooth.fish.tmpl
│   ├── run_onchange_multimedia.fish.tmpl
│   ├── run_onchange_nvidia.fish.tmpl
│   └── run_onchange_languages.fish.tmpl
│
├── 50-setup/                           # Phase 5: One-time setup (run_once)
│   ├── run_once_podman.fish.tmpl
│   ├── run_once_devcontainer.fish.tmpl
│   ├── run_once_nvim-mcp.fish.tmpl
│   ├── run_once_claude.fish.tmpl
│   └── run_once_bitwarden.fish.tmpl
│
└── 90-finalize/                        # Phase 9: Finalization (run_after)
    └── run_after_90-finalize.fish.tmpl
```

### 4. Naming Conventions

**Directory naming:**
- `NN-category/` where NN indicates execution phase (00-99)
- Categories: bootstrap, desktop, terminal, gui, system, setup, finalize

**Script naming pattern:**
```
run_{when}_{number}-{name}.fish.tmpl

{when}   → before | onchange | once | after
{number} → Optional ordering (only for before/after)
{name}   → kebab-case descriptive name
```

**Examples:**
- `run_before_00-preflight.fish.tmpl` - Runs before files, order 00
- `run_onchange_tmux.fish.tmpl` - Reruns when content changes
- `run_once_podman.fish.tmpl` - Runs once, tracked in state
- `run_after_90-finalize.fish.tmpl` - Runs after files, order 90

**Why this is better:**
1. **Chronological organization** - Directory order = execution order
2. **Clear execution semantics** - Name tells you when/how it runs
3. **No "install_" prefix needed** - Context is clear from directory
4. **Easy to find scripts** - Browse by phase, not scattered
5. **Intuitive numbering** - 00-09 bootstrap, 10-19 init, 20-89 install, 90-99 finalize

**Functions:**
- `section` - Major section header
- `subsection` - Minor section header
- `step` - Execute command with spinner
- `info` - Informational message
- `success` - Success message
- `warning` - Warning message
- `error` - Error message
- `box` - Formatted box message
- `confirm` - Yes/no prompt
- `install_packages` - DNF package installation

### 5. Template Conditional Strategy

**Install scripts** - Wrap entire file:
```fish
{{- if .install.component }}
# Script content
{{- end }}
```

**GUI/System scripts** - Check mode + component:
```fish
{{- if and .install.component (ne .mode.name "container") }}
# Script content
{{- end }}
```

**Core scripts** - No conditionals (always run)

**Setup scripts** - Mode check only:
```fish
{{- if ne .mode.name "container" }}
# Script content
{{- end }}
```

## Benefits

1. **Clarity** - Clear variable names and purposes
2. **Consistency** - All scripts follow same pattern
3. **Maintainability** - Change paths in one place
4. **Readability** - Standard structure makes scripts easy to understand
5. **Reliability** - Less room for path resolution errors
6. **Scalability** - Easy to add new scripts following template

## Execution Flow (Visual)

```
┌─────────────────────────────────────────────────────┐
│  BOOTSTRAP (run_before)                             │
│  00-bootstrap/                                      │
│    ├─ 00-preflight     → Set env vars, DNF, Rust   │
│    └─ 01-mode-config   → Load mode YAML            │
├─────────────────────────────────────────────────────┤
│  DESKTOP INIT (run_before)                          │
│  10-desktop/                                        │
│    └─ 10-desktop-init  → Desktop-specific setup    │
├─────────────────────────────────────────────────────┤
│  📁 CHEZMOI APPLIES FILES (dotfiles deployed)       │
├─────────────────────────────────────────────────────┤
│  TERMINAL TOOLS (run_onchange)                      │
│  20-terminal/                                       │
│    ├─ tmux, neovim, yazi, btop, gh, lazygit, cli   │
│                                                     │
│  GUI APPS (run_onchange)                            │
│  30-gui/                                            │
│    ├─ hyprland, kitty, firefox, rofi, fonts        │
│                                                     │
│  SYSTEM (run_onchange)                              │
│  40-system/                                         │
│    ├─ audio, bluetooth, multimedia, nvidia         │
│                                                     │
│  ONE-TIME SETUP (run_once)                          │
│  50-setup/                                          │
│    ├─ podman, devcontainer, nvim-mcp, claude       │
├─────────────────────────────────────────────────────┤
│  FINALIZE (run_after)                               │
│  90-finalize/                                       │
│    └─ 90-finalize      → Cleanup, summary          │
└─────────────────────────────────────────────────────┘
```

## Implementation Plan

### Step 1: Create new directory structure
```bash
# Create phase directories
mkdir -p home/{lib,00-bootstrap,10-desktop,20-terminal,30-gui,40-system,50-setup,90-finalize}
```

### Step 2: Move helpers to lib/
```bash
git mv home/core/lib/helpers.fish home/lib/
```

### Step 3: Reorganize and rename scripts (preserve git history)
```bash
# Bootstrap scripts
git mv home/core/run_before_00_preflight.fish.tmpl home/00-bootstrap/run_before_00-preflight.fish.tmpl
git mv home/core/run_before_01_mode_config.fish.tmpl home/00-bootstrap/run_before_01-mode-config.fish.tmpl

# Desktop setup
git mv home/desktop/run_before_10_desktop_setup.fish.tmpl home/10-desktop/run_before_10-desktop-init.fish.tmpl

# Terminal tools (remove install_ prefix)
git mv home/terminal/run_onchange_install_tmux.fish.tmpl home/20-terminal/run_onchange_tmux.fish.tmpl
# ... repeat for all terminal scripts

# GUI apps
git mv home/gui/run_onchange_install_hyprland.fish.tmpl home/30-gui/run_onchange_hyprland.fish.tmpl
# ... repeat for all GUI scripts

# System components
git mv home/system/run_onchange_install_audio.fish.tmpl home/40-system/run_onchange_audio.fish.tmpl
# ... repeat for all system scripts

# One-time setup (remove setup_ prefix)
git mv home/setup/run_once_setup_podman.fish.tmpl home/50-setup/run_once_podman.fish.tmpl
# ... repeat for all setup scripts

# Finalization
git mv home/post-install/run_after_50_finalize.fish.tmpl home/90-finalize/run_after_90-finalize.fish.tmpl
```

### Step 4: Update bootstrap scripts
- Set standardized environment variables (FEDPUNK_REPO_ROOT, FEDPUNK_HELPERS, etc.)
- Update helper sourcing to use `$FEDPUNK_HELPERS`
- Standardize headers and structure

### Step 5: Update all other scripts
- Replace all helper sourcing with `source "$FEDPUNK_HELPERS"`
- Standardize headers (component, description, category, mode)
- Ensure consistent section structure
- Verify template conditionals

### Step 6: Clean up old directories
```bash
rmdir home/{core,terminal,gui,system,setup,desktop,post-install}
```

### Step 7: Test
- Test in container mode (minimal install)
- Test in desktop mode (full install)
- Verify git history preserved
- Check all scripts execute in correct order

### Step 8: Document
- Update README with new structure
- Create CONTRIBUTING.md with script templates
- Document environment variables
