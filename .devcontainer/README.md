# Fedpunk Devcontainer Testing

This devcontainer is for testing fedpunk's modular component-based installation in container mode.

## Quick Start

### Option 1: VS Code / Claude Code (Recommended)

1. Open this directory in VS Code/Claude Code
2. When prompted, click "Reopen in Container"
3. Once inside, run:
   ```fish
   fish .devcontainer/test-install.fish
   ```

### Option 2: Podman/Docker CLI

```bash
cd /path/to/fedpunk

podman run -it --rm \
  -e FEDPUNK_MODE=container \
  -v .:/workspace:Z \
  -w /workspace \
  fedora:latest \
  bash -c "dnf install -y fish curl && fish .devcontainer/test-install.fish"
```

## What the Test Does

The test script will:

1. ✓ Detect container environment
2. ✓ Install chezmoi
3. ✓ Configure chezmoi to use `/workspace` as source
4. ✓ Initialize chezmoi (mode auto-detected as "container")
5. ✓ Show detected mode
6. ✓ List files that would be deployed
7. ✓ Run a dry-run to verify everything works

## Expected Output

```
╔════════════════════════════════════════════╗
║   Fedpunk Container Mode Test             ║
╚════════════════════════════════════════════╝

→ Container Detection:
  ✓ CONTAINER env var is set

→ Setting up chezmoi:
  ✓ Already installed

→ Initializing chezmoi:
  ✓ Initialized with source=/workspace

→ Configuration:
[data]
  [data.mode]
    name = "container"

→ Files to be deployed:
  Total managed files: XX

→ Testing chezmoi apply (dry-run):
  ✓ Dry-run successful
```

## Full Installation Test

To actually apply the configuration and run component install scripts:

```fish
# Apply dotfiles (automatically runs component install scripts)
chezmoi apply
```

Components will install automatically via their `run_*` scripts.

## Architecture

The new modular structure:

```
/workspace/
├── home/
│   ├── core/                    # System essentials
│   │   ├── run_before_00_preflight.fish.tmpl
│   │   ├── run_before_01_mode_config.fish.tmpl
│   │   └── lib/                 # Helper functions
│   ├── desktop/                 # Desktop-only setup
│   ├── fish/                    # Fish shell
│   │   ├── dot_config/fish/
│   │   └── (no install script)
│   ├── tmux/                    # Tmux
│   │   ├── dot_config/tmux/
│   │   └── run_onchange_install_tmux.fish.tmpl
│   ├── neovim/                  # Neovim
│   │   ├── dot_config/nvim/
│   │   └── run_onchange_install_neovim.fish.tmpl
│   └── <component>/            # One directory per component
│       ├── dot_config/         # Component dotfiles
│       └── run_*_install_*.fish.tmpl  # Component install script
└── modes/                       # Mode configurations
    ├── container.yaml
    ├── desktop.yaml
    └── laptop.yaml
```

Key features:
- **Self-contained components**: Each component has config + install script together
- **Automatic execution**: Chezmoi runs scripts based on naming conventions
- **Mode-based**: Components check `FEDPUNK_INSTALL_<COMPONENT>=true` from mode YAML
- **No orchestration**: No central install script, each component manages itself
