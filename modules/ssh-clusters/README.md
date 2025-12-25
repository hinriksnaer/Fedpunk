# SSH Clusters Module

Internal SSH cluster configuration management for Fedpunk. Provides easy access to development and testing clusters with configurable username handling.

## Overview

This module manages SSH configurations for internal clusters including:
- **eaglestream**: Intel Eagle Stream SPR development cluster
- **ibm-yugi**: IBM development cluster 1
- **ibm-kaiba**: IBM development cluster 2
- **ibm-joey**: IBM development cluster 3

## Features

- Pre-configured cluster hostnames and settings
- Flexible username configuration (3 modes)
- Automatic User directive generation
- Declarative-first parameter system
- Stow-based configuration management

## Installation

### From Git Repository

Deploy directly from GitLab using the repository URL:

```fish
fedpunk module deploy git@gitlab.com:redhat/rhel-ai/team-pytorch/fedpunk-modules/ssh-clusters.git
```

Or add to your profile's `mode.yaml`:

```yaml
modules:
  - ssh  # Required dependency
  - git@gitlab.com:redhat/rhel-ai/team-pytorch/fedpunk-modules/ssh-clusters.git
```

### From Local Checkout

If you have the module checked out locally:

```fish
fedpunk module deploy /path/to/ssh-clusters/
```

## Configuration

### Username Modes

The module supports three modes for determining SSH usernames when no declarative value is provided:

#### 1. Current User

Uses your current system username (`$USER`):

```yaml
# ~/.config/fedpunk/fedpunk.yaml
modules:
  enabled:
    - module: git@gitlab.com:redhat/rhel-ai/team-pytorch/fedpunk-modules/ssh-clusters.git
      params:
        username_mode: current
```

#### 2. Prompt All

Prompts once during deployment for a username to use for all clusters:

```yaml
modules:
  enabled:
    - module: git@gitlab.com:redhat/rhel-ai/team-pytorch/fedpunk-modules/ssh-clusters.git
      params:
        username_mode: prompt_all
```

#### 3. Prompt Individual

Prompts for username separately for each cluster (not reproducible):

```yaml
modules:
  enabled:
    - module: git@gitlab.com:redhat/rhel-ai/team-pytorch/fedpunk-modules/ssh-clusters.git
      params:
        username_mode: prompt_individual
```

### Declarative Configuration

**Declarative values always take precedence.** If you don't provide parameters in `fedpunk.yaml`, you'll be prompted to select a mode during deployment, and your choice will be saved automatically.

**First deployment (no fedpunk.yaml):**
```fish
fedpunk module deploy git@gitlab.com:redhat/rhel-ai/team-pytorch/fedpunk-modules/ssh-clusters.git
# → Prompts: "How to determine usernames for SSH cluster access"
# → Select: current / prompt_all / prompt_individual
# → Saves your choice to ~/.config/fedpunk/fedpunk.yaml
```

**Subsequent deployments:**
```fish
fedpunk module deploy git@gitlab.com:redhat/rhel-ai/team-pytorch/fedpunk-modules/ssh-clusters.git
# → Uses saved value from fedpunk.yaml (no prompt)
```

### Parameter System

This module demonstrates Fedpunk's declarative-first parameter system:

1. **Declarative first**: Values in `fedpunk.yaml` always used (no prompting)
2. **Defaults next**: If defined, used silently without prompting
3. **Prompt last**: Only when no declarative value and no default
4. **Saved automatically**: User selections saved to `fedpunk.yaml`

**Parameter resolution order:**
```
1. Check ~/.config/fedpunk/fedpunk.yaml (declarative)
   ↓ Found? Use it and skip prompting
2. Check module.yaml for default value
   ↓ Found? Use it and save to fedpunk.yaml
3. Prompt user interactively
   ↓ Save response to fedpunk.yaml
```

## Usage

Once deployed, connect to clusters using their short names:

```bash
ssh eaglestream
ssh ibm-yugi
ssh ibm-kaiba
ssh ibm-joey
```

## File Structure

```
ssh-clusters/
├── module.yaml                     # Module definition with parameters
├── README.md                       # This file
├── config/
│   └── .ssh/config.d/
│       └── hosts                   # Cluster definitions (stowed)
└── scripts/
    └── generate-hosts              # User configuration generator
```

## Generated Files

The module creates:

- `~/.ssh/config.d/hosts` - Symlinked from module config
- `~/.ssh/config.d/hosts-users` - Auto-generated User directives
- `~/.config/fedpunk/fedpunk.yaml` - Declarative parameter state

## Updating Configuration

To change the username mode after installation:

1. Edit `~/.config/fedpunk/fedpunk.yaml`
2. Update the `username_mode` parameter (or remove it to be prompted again)
3. Redeploy: `fedpunk module deploy git@gitlab.com:...ssh-clusters.git`

**Example fedpunk.yaml:**
```yaml
modules:
  enabled:
    - module: git@gitlab.com:redhat/rhel-ai/team-pytorch/fedpunk-modules/ssh-clusters.git
      params:
        username_mode: current
```

## Adding New Clusters

To add more clusters:

1. Fork this repository or clone it locally
2. Edit `config/.ssh/config.d/hosts` - Add new Host blocks
3. Update cluster list in `scripts/generate-hosts`
4. Deploy from your modified version

Example Host block:

```ssh-config
Host my-new-cluster
    HostName cluster.example.com
    ForwardAgent yes
    ServerAliveInterval 60
```

## Dependencies

- `ssh` module (provides base SSH configuration)
- `gum` (optional, for interactive prompts - fallback to Fish `read`)

## Technical Details

### Parameter Definition

```yaml
parameters:
  username_mode:
    type: string
    description: "How to determine usernames for SSH cluster access"
    options:
      - current
      - prompt_all
      - prompt_individual
```

**Key points:**
- No `default` → implicitly required (will prompt if not in fedpunk.yaml)
- `options` → presents selection menu instead of text input
- Saved to `~/.config/fedpunk/fedpunk.yaml` automatically

### Environment Variables

Parameters are exposed as environment variables for use in scripts:

```bash
echo $FEDPUNK_PARAM_SSH_CLUSTERS_USERNAME_MODE
# → current / prompt_all / prompt_individual
```

### Lifecycle Hooks

- **after: generate-hosts** - Runs after stow to create user configurations based on username_mode

### Stow Behavior

- Target: `$HOME`
- Conflicts: `warn` (shows warning, lets you choose)
- Symlinks `config/.ssh/config.d/hosts` to `~/.ssh/config.d/hosts`

## Troubleshooting

### Clusters not accessible

1. Check if hosts file is symlinked: `ls -la ~/.ssh/config.d/hosts`
2. Verify users file exists: `cat ~/.ssh/config.d/hosts-users`
3. Check SSH config includes it: `grep -r "config.d" ~/.ssh/config`
4. Redeploy module: `fedpunk module deploy git@gitlab.com:...ssh-clusters.git`

### Want to be prompted again

Remove the parameter from `fedpunk.yaml` and redeploy:

```fish
# Edit ~/.config/fedpunk/fedpunk.yaml - remove username_mode parameter
# Then redeploy
fedpunk module deploy git@gitlab.com:redhat/rhel-ai/team-pytorch/fedpunk-modules/ssh-clusters.git
```

### Module cached with old version

Clear the external module cache:

```fish
rm -rf ~/.local/share/fedpunk/cache/external/gitlab.com/redhat/rhel-ai/team-pytorch/fedpunk-modules/ssh-clusters
fedpunk module deploy git@gitlab.com:redhat/rhel-ai/team-pytorch/fedpunk-modules/ssh-clusters.git
```

## Examples

### Interactive Deployment (First Time)

```fish
$ fedpunk module deploy git@gitlab.com:redhat/rhel-ai/team-pytorch/fedpunk-modules/ssh-clusters.git

# Fedpunk will prompt:
# → How to determine usernames for SSH cluster access
#   - current
#   - prompt_all
#   - prompt_individual

# Select with arrow keys, Enter to confirm
# Your choice is saved to ~/.config/fedpunk/fedpunk.yaml
```

### Declarative Deployment (Reproducible)

```yaml
# ~/.config/fedpunk/fedpunk.yaml
modules:
  enabled:
    - module: git@gitlab.com:redhat/rhel-ai/team-pytorch/fedpunk-modules/ssh-clusters.git
      params:
        username_mode: current
```

```fish
$ fedpunk module deploy git@gitlab.com:redhat/rhel-ai/team-pytorch/fedpunk-modules/ssh-clusters.git
# → No prompts, uses declarative value from fedpunk.yaml
# → Fully reproducible across environments
```

### Profile Integration

```yaml
# profiles/team/modes/desktop/mode.yaml
modules:
  - ssh
  - git@gitlab.com:redhat/rhel-ai/team-pytorch/fedpunk-modules/ssh-clusters.git
```

On first `fedpunk apply`, users will be prompted for `username_mode`, and their choice is saved to `~/.config/fedpunk/fedpunk.yaml` for subsequent runs.

## License

Part of Fedpunk - see root LICENSE file.
