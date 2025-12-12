# Desktop Profile

Full-featured desktop environment profile with Hyprland window manager and extensive development tools.

## Overview

This profile contains all desktop-specific modules that were separated from the core Fedpunk installation to keep the base system minimal.

## Modes

### Desktop Mode (`desktop`)
Full desktop environment with:
- Hyprland window manager with hyprlock
- Kitty terminal, Rofi launcher
- Firefox and Zen Browser
- Full development toolchain (Neovim, Rust, languages)
- Multimedia support
- Bluetooth, WiFi, audio configuration
- NVIDIA driver support

### Container Mode (`container`)
Minimal terminal-focused environment for development containers:
- Essential CLI tools
- Neovim, Tmux, Yazi
- Git tools (gh, lazygit)
- No GUI components

## Usage

```fish
# Deploy full desktop
fedpunk profile deploy desktop --mode desktop

# Deploy minimal container environment
fedpunk profile deploy desktop --mode container
```

## Plugins

All desktop-specific modules are in the `plugins/` directory:
- **Window Manager**: hyprland, hyprlock
- **Terminal**: kitty, tmux, fish
- **Editors**: neovim
- **Browsers**: firefox, zen-browser
- **Development**: rust, languages, gh, lazygit, dev-tools, cli-tools
- **Utilities**: bitwarden, yazi, btop, rofi
- **System**: bluetooth, wifi, audio, nvidia, system-config, flatpak, fonts, multimedia

## Relationship to Core Fedpunk

Core Fedpunk (`/usr/share/fedpunk/modules`) only contains:
- `essentials` - Core system packages
- `ssh` - SSH key management
- `claude` - Claude CLI tool
- `bluetui` - Bluetooth TUI

All other modules are profile-specific plugins in this desktop profile.
