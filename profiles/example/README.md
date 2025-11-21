# Example Profile

Template profile for creating your own Fedpunk profile.

## Structure

### `modes/`
Module lists for different deployment scenarios:
- **desktop.yaml** - Full desktop environment
- **container.yaml** - Terminal-only environment

## Creating Your Profile

1. Copy this profile:
```bash
cp -r ~/.local/share/fedpunk/profiles/example ~/.local/share/fedpunk/profiles/myprofile
```

2. Customize the mode files:
```bash
nvim ~/.local/share/fedpunk/profiles/myprofile/modes/desktop.yaml
```

3. Activate your profile:
```bash
fedpunk profile activate myprofile
```

## Profile Options

### Monitor Configuration
Create `monitors.conf` to customize display settings:
```conf
# Example monitor configuration
monitor = HDMI-A-1, 1920x1080@60, 0x0, 1
```

### Custom Modules
Add profile-specific modules in `plugins/` directory following the standard module structure.
