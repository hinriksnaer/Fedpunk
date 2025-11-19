# Fedpunk Devcontainer Testing

This devcontainer is for testing fedpunk's profile-based installation in container mode.

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
  -e FEDPUNK_PROFILE=dev \
  -e FEDPUNK_NON_INTERACTIVE=true \
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
4. ✓ Initialize chezmoi
5. ✓ Show detected profile and mode
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

→ Configuring chezmoi:
  ✓ Set sourceDir to /workspace

→ Initializing chezmoi:
  ✓ Initialized

→ Configuration:
[data]
  [data.mode]
    name = "container"
  [data.profile]
    name = "dev"
    path = "/workspace/profiles/dev"

→ Profile Information:
  Profile: dev
  Path: /workspace/profiles/dev
  Manifest: Found
  Install scripts: 2

→ Files to be deployed:
  Total managed files: XX

→ Testing chezmoi apply (dry-run):
  ✓ Dry-run successful
```

## Full Installation Test

To actually apply the configuration and run install scripts:

```fish
# Apply dotfiles
chezmoi apply

# Run profile install scripts
cd /workspace/profiles/dev/install
for script in *.fish
    fish $script
end
```

## Architecture

The new simplified structure:

```
/workspace/
├── home/               # Dotfiles managed by chezmoi
│   ├── dot_config/
│   └── *.tmpl         # Chezmoi templates
└── profiles/
    ├── base/
    │   └── install/   # Base install scripts
    └── dev/
        ├── config.fish        # Fish config additions
        ├── fedpunk.yaml       # Profile metadata
        └── install/           # Dev-specific install scripts
            ├── 00-dev-packages.fish
            └── 10-dev-setup.fish
```

No more modules! Just:
- **home/** for dotfiles
- **profiles/** for environment-specific configs and install scripts
