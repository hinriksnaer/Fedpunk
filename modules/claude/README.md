# Claude Code Module

Installs and configures Claude Code CLI to use Google Vertex AI authentication.

## Quick Start

### Prerequisites

Install Fedpunk via COPR:

```bash
sudo dnf copr enable hinriksnaer/fedpunk
sudo dnf install fedpunk
```

### Install Module

The Claude module is **built into the Fedpunk RPM**, so you can deploy it immediately:

```fish
# Deploy the claude module
fedpunk module deploy claude

# The installer will:
# 1. Install Google Cloud SDK
# 2. Prompt for browser authentication
# 3. Install Claude Code CLI
# 4. Configure environment variables

# Start new shell to load PATH
exec fish

# Verify installation
claude --version
```

## What It Does

This module automates the complete setup of Claude Code with Google Vertex AI:

1. **Installs Google Cloud SDK** - Auto-detects package manager and installs gcloud
2. **Authenticates with GCP** - Runs `gcloud auth application-default login` (opens browser)
3. **Installs Claude Code** - Downloads from https://claude.ai/install.sh
4. **Configures Environment** - Sets Vertex AI variables for Fish shell

## Features

- ✓ Google Cloud authentication (no API keys needed)
- ✓ Access Claude models through Vertex AI
- ✓ Automatic environment configuration
- ✓ Works with all shells (Bash, Zsh, Fish)
- ✓ `~/.local/bin` automatically in PATH

## Parameters

The module has two parameters with sensible defaults:

### `project_id`
- **Description**: Google Cloud project ID for Anthropic Vertex AI
- **Default**: `itpc-gcp-ai-eng-claude`
- **Type**: string

### `region`
- **Description**: Google Cloud region for Vertex AI  
- **Default**: `us-east5`
- **Type**: string

### Custom Configuration

Override defaults in `~/.config/fedpunk/fedpunk.yaml`:

```yaml
modules:
  enabled:
    - module: claude
      params:
        project_id: my-custom-project
        region: us-central1
```

Or on first deployment, you'll be prompted and your choices saved automatically.

## What It Does

### 1. Installs Google Cloud SDK

Automatically detects your package manager (DNF/APT) and installs `gcloud`.

### 2. Authenticates with Google Cloud

Runs `gcloud auth application-default login` which:
- Opens your browser for Google authentication
- Creates application-default credentials
- Stores them in `~/.config/gcloud/application_default_credentials.json`

### 3. Installs Claude Code

Downloads and installs the Claude Code CLI tool using:
```bash
curl -fsSL https://claude.ai/install.sh | bash
```

### 4. Configures Environment Variables

Creates `~/.config/fish/conf.d/claude-vertex.fish` with:

```fish
set -gx CLAUDE_CODE_USE_VERTEX 1
set -gx CLOUD_ML_REGION us-east5  # or your custom region
set -gx ANTHROPIC_VERTEX_PROJECT_ID itpc-gcp-ai-eng-claude  # or your custom project
```

## Usage

After deployment, simply use Claude Code normally:

```fish
claude chat
```

Claude Code will automatically use Vertex AI authentication based on the environment variables.

## File Structure

```
modules/claude/
├── module.yaml                              # Module definition
├── README.md                                # This file
├── config/
│   └── .config/fish/conf.d/
│       └── claude-vertex.fish               # Vertex AI environment variables
└── scripts/
    └── install                              # Installation and auth script
```

## Generated Files

The module creates/modifies:

- `~/.config/fish/conf.d/claude-vertex.fish` - Symlinked from module config
- `~/.config/gcloud/application_default_credentials.json` - Google auth credentials
- `~/.local/bin/claude` - Claude Code binary (typical location)

## Environment Variables

The following variables are set in your Fish shell:

| Variable | Purpose | Default |
|----------|---------|---------|
| `CLAUDE_CODE_USE_VERTEX` | Enable Vertex AI mode | `1` |
| `CLOUD_ML_REGION` | GCP region for Vertex AI | `us-east5` |
| `ANTHROPIC_VERTEX_PROJECT_ID` | GCP project ID | `itpc-gcp-ai-eng-claude` |

## Updating Configuration

To change project or region after installation:

1. Edit `~/.config/fedpunk/fedpunk.yaml`:
   ```yaml
   modules:
     enabled:
       - module: claude
         params:
           project_id: new-project-id
           region: us-west1
   ```

2. Redeploy the module:
   ```fish
   fedpunk module deploy claude
   ```

3. Restart your Fish shell to load new environment variables

## Troubleshooting

### Authentication fails

Re-run the authentication:
```bash
gcloud auth application-default login
```

### Claude Code not found

Ensure `~/.local/bin` is in your PATH:
```fish
fish_add_path ~/.local/bin
```

### Wrong project or region

Check your environment variables:
```fish
echo $ANTHROPIC_VERTEX_PROJECT_ID
echo $CLOUD_ML_REGION
```

Update in `fedpunk.yaml` and redeploy if incorrect.

### Need to re-authenticate

Google Cloud credentials can expire. Re-run:
```bash
gcloud auth application-default login
```

## Dependencies

- `fish` module (provides Fish shell)
- `curl` (installed via DNF packages)
- Internet connection for downloading gcloud SDK and Claude Code

## Technical Details

### Lifecycle Hooks

- **after: install** - Runs after configuration deployment to:
  1. Install gcloud SDK
  2. Authenticate with Google Cloud
  3. Install Claude Code CLI

### Stow Behavior

- Target: `$HOME`
- Conflicts: `warn` (prompts on conflicts)
- Symlinks `config/.config/fish/conf.d/claude-vertex.fish` to `~/.config/fish/conf.d/`

### Package Management

The install script auto-detects:
- **Fedora/RHEL**: Uses DNF with Google's YUM repository
- **Debian/Ubuntu**: Uses APT with Google's APT repository

## Security Considerations

- Google Cloud credentials are stored in `~/.config/gcloud/`
- Credentials provide access to your GCP project
- Ensure your GCP project has appropriate IAM permissions
- Use least-privilege service accounts when possible

## License

Part of Fedpunk - see root LICENSE file.
