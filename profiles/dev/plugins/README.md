# Profile Plugins

Profile-specific modules that extend your Fedpunk installation with additional tools and applications.

## Structure

Each plugin follows the standard module structure:

```
plugins/dev-extras/
└── module.yaml      # Module configuration
```

## How Plugins Work

- **Profile-scoped**: Only deployed when the profile is active
- **Standard modules**: Follow the same module.yaml schema as base modules
- **Dependencies**: Can depend on base modules
- **Auto-deployment**: Installed when profile modes reference them

## Example: dev-extras Plugin

The dev-extras plugin in this profile installs:
- **Spotify** - Music streaming (Flatpak)
- **Discord** - Communication platform (Flatpak)
- **Devcontainer CLI** - VS Code devcontainer tools (npm)

```yaml
# profiles/dev/plugins/dev-extras/module.yaml
module:
  name: dev-extras
  description: Extra development tools and applications
  dependencies:
    - fish

packages:
  npm:
    - "@devcontainers/cli"
  flatpak:
    - com.spotify.Client
    - com.discordapp.Discord
```

## Using Plugins

### 1. Add plugin to profile mode

Edit `profiles/dev/modes/desktop.yaml`:
```yaml
modules:
  - essentials
  - hyprland
  - plugins/dev-extras  # Add plugin here
```

### 2. Deploy

```bash
fedpunk module deploy dev-extras
```

Or deploy all modules in the mode:
```bash
fish install.fish
```

## Creating Your Own Plugin

1. **Create the plugin directory:**
```bash
mkdir -p profiles/dev/plugins/my-tools
```

2. **Create module.yaml:**
```yaml
module:
  name: my-tools
  description: My custom development tools
  dependencies: []

packages:
  dnf:
    - htop
    - ncdu
  cargo:
    - ripgrep
```

3. **Add to your profile mode:**
```yaml
# profiles/dev/modes/desktop.yaml
modules:
  - essentials
  - plugins/my-tools
```

4. **Deploy:**
```bash
fedpunk module deploy my-tools
```

## Plugin Best Practices

- **Keep it focused**: One plugin per category (dev tools, media apps, etc.)
- **Document dependencies**: List what the plugin needs
- **Use descriptive names**: `dev-extras`, `media-apps`, `work-tools`
- **Version control**: Commit your plugins to share across machines
