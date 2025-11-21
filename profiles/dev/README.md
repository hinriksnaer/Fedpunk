# Dev Profile

Development profile for Fedpunk.

## Structure

### `modes/`
Module lists for different deployment scenarios:
- **desktop.yaml** - Full desktop environment with all development tools
- **container.yaml** - Minimal development environment for containers/devcontainers

### `monitors.conf`
Profile-specific monitor configuration for Hyprland.
Sourced by Hyprland config after default monitor settings.

### `plugins/`
Profile-specific modules that extend the base Fedpunk installation.
Place custom module directories here.

## Usage

Activate this profile:
```bash
fedpunk profile activate dev
```

List modules in desktop mode:
```bash
cat ~/.local/share/fedpunk/profiles/dev/modes/desktop.yaml
```

## Customization

- Edit `modes/desktop.yaml` or `modes/container.yaml` to add/remove modules
- Modify `monitors.conf` for your display setup
- Add custom modules in `plugins/` directory
