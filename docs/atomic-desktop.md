# Atomic Desktop Support

Fedpunk now supports **Fedora Atomic Desktops** (Silverblue, Kinoite, etc.) with automatic detection and appropriate package management.

## How It Works

### Automatic Detection

Fedpunk automatically detects if you're running an atomic desktop by checking for `/run/ostree-booted`:

```fish
# Traditional Fedora → uses dnf
# Atomic Fedora → uses rpm-ostree
```

### Package Installation

When you deploy a module on an atomic desktop:

**System packages (from module.yaml `dnf:` section):**
- Automatically layered with `rpm-ostree install`
- Reboot required to activate
- Minimal layers recommended

**User-space packages:**
- Cargo packages → install to `~/.cargo` (no layering)
- NPM packages → install to `~/.npm` (no layering)
- Flatpaks → install to user (no layering)

### Reboot Handling

If any packages are layered, fedpunk will show a reboot warning:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚠️  REBOOT REQUIRED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
System packages layered. Run: systemctl reboot
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Best Practices for Atomic

### Minimize Layers

Only layer packages that **must** be system-level:
- Desktop compositor (Hyprland)
- System bars/tools (Waybar)
- Hardware drivers (NVIDIA)

### Prefer Alternatives

**Instead of layering:**
- Use Flatpak for GUI apps
- Use Cargo for Rust CLI tools
- Use NPM for Node tools
- Use Toolbox/Distrobox for development

### Example Atomic Mode

```yaml
# profiles/dev/modes/atomic-desktop.yaml
modules:
  # User-space only (no layering)
  - essentials   # Rust/Node via rustup/volta
  - neovim       # Cargo packages only
  - tmux
  - lazygit

  # Must be layered (minimal)
  - hyprland     # Compositor
  - kitty        # Terminal
  - waybar       # Status bar

  # Flatpaks (no layering)
  - firefox
  - plugins/dev-extras  # Spotify, Discord
```

## Migration Guide

### From Traditional to Atomic

1. **Install Fedora Silverblue/Kinoite**
2. **Deploy your existing profile:**
   ```fish
   fish install.fish --mode desktop
   ```
3. **Fedpunk automatically:**
   - Uses rpm-ostree for system packages
   - Keeps Flatpaks and user-space tools the same
   - Shows reboot prompt when needed

4. **Reboot to activate layers:**
   ```bash
   systemctl reboot
   ```

### Optimize for Atomic

Create an `atomic-desktop` mode that minimizes layers:

```yaml
# Before (traditional-desktop.yaml)
modules:
  - system-utils  # Lots of dnf packages
  - dev-tools     # More dnf packages

# After (atomic-desktop.yaml)
modules:
  - essentials    # User-space only
  - dev-tools     # Cargo/npm only
```

## Technical Details

### Package Manager Abstraction

Fedpunk uses a new abstraction layer in `lib/fish/package-manager.fish`:

```fish
function install-system-packages
    if is-atomic-desktop
        sudo rpm-ostree install --idempotent $argv
    else
        sudo dnf install -y $argv
    end
end
```

### Module Changes

No changes needed to existing modules! The abstraction layer handles everything:

```yaml
# This works on BOTH traditional and atomic
packages:
  dnf:
    - kitty
    - hyprland
  flatpak:
    - com.spotify.Client
  cargo:
    - ripgrep
```

**On traditional:** `dnf install kitty hyprland`
**On atomic:** `rpm-ostree install kitty hyprland` + reboot

## Comparison

| Aspect | Traditional | Atomic |
|--------|------------|---------|
| System packages | `dnf install` (immediate) | `rpm-ostree install` (reboot) |
| User packages | Same | Same |
| Flatpaks | Same | Same |
| Dotfiles | Same (GNU Stow) | Same (GNU Stow) |
| Rollback | DNF history | `rpm-ostree rollback` |
| Base updates | `dnf upgrade` | Atomic image update |

## Benefits of Atomic + Fedpunk

1. **Reproducibility** - Profile defines exact system state
2. **Safety** - Rollback to previous deployment
3. **Cleaner** - Less system mutation
4. **Faster** - Atomic updates
5. **Portable** - Same config on traditional or atomic
