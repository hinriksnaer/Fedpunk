# Fedpunk Devcontainer Testing

This devcontainer provides a safe, isolated environment to test the Fedpunk terminal-only installation without affecting your host system.

## Quick Start

### Using VS Code

1. **Open the repository** in VS Code
2. **Install the Dev Containers extension** (if not already installed)
3. **Click "Reopen in Container"** when prompted
   - Or: Press `F1` → "Dev Containers: Reopen in Container"
4. **Wait for setup** (first-time setup takes ~5-10 minutes)
5. **Start Fish shell:** `exec fish`

### Using GitHub Codespaces

1. Navigate to the repository on GitHub
2. Click "Code" → "Codespaces" → "Create codespace on main"
3. Wait for environment to build
4. Run `exec fish` in the terminal

## What Gets Installed

✅ **Included (Terminal-Only Mode):**
- Fish shell with full configuration
- Neovim with LazyVim, plugins, and LSP
- Tmux with plugin manager (TPM)
- Lazygit (terminal git UI)
- btop (system resource monitor)
- Modern CLI tools: ripgrep, fzf, fd, bat, eza
- Starship prompt
- All Fedpunk themes (terminal colors)

❌ **Excluded (Desktop Components):**
- Hyprland compositor
- Kitty terminal (uses your existing terminal)
- Rofi launcher
- Mako notifications
- Desktop-specific configs

## Testing Checklist

### Basic Functionality

```bash
# Verify Fish shell
fish --version

# Check theme system
fedpunk-theme-list
fedpunk-theme-current

# Set a theme
fedpunk-theme-set-terminal catppuccin

# List bin scripts
ls ~/.local/bin/fedpunk*

# Test Neovim
nvim

# Test Tmux
tmux

# Test Lazygit
lazygit

# Test btop
btop
```

### Theme System Testing

```bash
# List all available themes
fedpunk-theme-list

# Cycle through themes (terminal colors only)
for theme in catppuccin nord tokyo-night ayu-mirage rose-pine; do
    echo "Testing theme: $theme"
    fedpunk-theme-set-terminal $theme
    sleep 2
done

# Check current theme
fedpunk-theme-current
```

### Neovim Testing

```bash
# Open Neovim
nvim

# Inside Neovim, check:
:checkhealth        # Verify all plugins and LSP
:Lazy               # View installed plugins
:Mason              # View LSP servers
```

### Fish Shell Testing

```bash
# Check Fish configuration
fish --debug-output=/dev/stderr

# Test Fish functions
functions | grep fedpunk

# Check Fish completions
complete -C "fedpunk-theme-"
```

## Known Limitations in Devcontainer

1. **No GUI** - Desktop components (Hyprland, Kitty, Rofi) cannot be tested
2. **No theme persistence** - Terminal colors reset on new terminal windows (container limitation)
3. **Limited systemd** - Some system services may not work in container
4. **No hardware access** - GPU, Bluetooth, audio not available
5. **SSH keys** - Mounted read-only from host (if available)

## Viewing Installation Logs

```bash
# Find the latest installation log
ls -lt /tmp/fedpunk-install-*.log | head -1

# View the log
cat /tmp/fedpunk-install-*.log | less

# Search for errors
grep -i "error\|fail" /tmp/fedpunk-install-*.log
```

## Troubleshooting

### Container fails to build
```bash
# Rebuild container from scratch
F1 → "Dev Containers: Rebuild Container"
```

### Installation fails
```bash
# Check the installation log
cat /tmp/fedpunk-install-*.log

# Re-run installation manually
cd ~/.local/share/fedpunk
fish install.fish --terminal-only --non-interactive
```

### Fish shell not starting
```bash
# Check Fish installation
which fish
fish --version

# Start Fish manually
exec fish
```

### Neovim plugins missing
```bash
# Open Neovim and run Lazy
nvim
:Lazy sync
```

### Theme not applying
```bash
# Check if theme exists
ls ~/.local/share/fedpunk/themes/

# Check active theme symlinks
ls -la ~/.config/kitty/theme.conf
ls -la ~/.config/btop/themes/active.theme

# Re-apply theme
fedpunk-theme-set-terminal catppuccin
```

## Performance Notes

### First Run (Cold Start)
- **Time:** 5-10 minutes
- **Downloads:** ~500MB
- **Installs:** Rust toolchain, Fish packages, Neovim plugins, system packages

### Subsequent Runs (Container Rebuild)
- **Time:** 2-3 minutes
- **Uses:** Docker layer caching
- **Faster:** Only updates changed components

## Customization

### Add Custom Packages

Edit `.devcontainer/setup.sh`:
```bash
# Add DNF packages
sudo dnf install -y my-package

# Add Cargo packages
cargo install my-rust-tool
```

### Change Base Image

Edit `.devcontainer/devcontainer.json`:
```json
{
  "image": "fedora:44"  // Change version
}
```

### Add VS Code Extensions

Edit `.devcontainer/devcontainer.json`:
```json
{
  "customizations": {
    "vscode": {
      "extensions": [
        "bbenoist.Nix",
        "ms-python.python"
      ]
    }
  }
}
```

## Cleaning Up

### Remove Container
```bash
# From VS Code
F1 → "Dev Containers: Remove Container"

# From Docker CLI
docker ps -a | grep fedpunk
docker rm <container-id>
```

### Remove Image
```bash
docker images | grep fedora
docker rmi <image-id>
```

## Next Steps

After successful testing in the devcontainer:

1. **Deploy on host** - Run full installation on your Fedora system
2. **Test desktop mode** - Install with Hyprland on actual hardware
3. **Customize** - Add personal themes to `profile/dev/themes/`
4. **Contribute** - Report issues or submit improvements

## Support

- **Documentation:** See `VALIDATION_REPORT.md` for detailed analysis
- **Issues:** https://github.com/hinriksnaer/Fedpunk/issues
- **Installation logs:** `/tmp/fedpunk-install-*.log`

---

**Happy Testing! 🐟**
