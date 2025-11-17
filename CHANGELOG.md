# Changelog

All notable changes to Fedpunk will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2025-11-17

### Added

- **Initial Release**: Modern Fedora development environment with Hyprland compositor
- **Desktop Environment**: Full Hyprland-based tiling window manager setup
  - Hyprland compositor with custom configuration
  - Waybar status bar with custom styling
  - Rofi application launcher with theme support
  - Mako notification daemon
  - Swaylock screen locker
  - wlogout logout menu
  - Hyprpaper wallpaper manager
- **Terminal Environment**: Rich Fish shell setup
  - Fish shell as default shell
  - Starship prompt for fast, customizable shell prompt
  - Fisher plugin manager
  - fzf.fish for fuzzy finding integration
  - lsd (LSDeluxe) for enhanced directory listings
  - Yazi file manager
  - Zellij terminal multiplexer
  - bat for syntax-highlighted file viewing
- **Development Tools**: Modern Rust-based CLI tools
  - Rust/Cargo toolchain
  - ripgrep for fast code search
  - fd for fast file finding
  - eza for modern ls replacement
  - delta for improved git diffs
- **Configuration Management**:
  - chezmoi for dotfile management (migrated from GNU Stow)
  - Profile system for managing different environment configurations
  - Theme system with multiple pre-configured themes
- **Installation Modes**:
  - Full desktop installation with GUI applications
  - Terminal-only installation for servers/containers
  - Non-interactive installation support
  - Devcontainer support for containerized development
- **Package Management**:
  - DNF repository management with COPR support
  - Flatpak integration
  - System package installation scripts
  - CLI tool installation via Cargo
- **Documentation**:
  - Comprehensive README with installation instructions
  - Architecture documentation
  - Profile system documentation
  - Theme system documentation

### Fixed

- **Installation Critical Fixes**:
  - Fixed chezmoi installation command quoting and heredoc syntax
  - Added util-linux dependency to devcontainer setup for `su` command
  - Fixed yazi.fish script permissions (711 → 755)
  - Added mkdir -p for ~/.local/bin before chezmoi download
- **Path Management**:
  - Fixed script paths from ~/.local/share/fedpunk/bin/ to ~/.local/bin/
  - Updated all Hyprland keybindings to use correct script paths
  - Fixed theme selection scripts path references
  - Replaced direct PATH manipulation with fish_add_path to prevent duplication
- **Configuration Management**:
  - Updated Rust/Cargo PATH management to use fish_add_path
  - Fixed PATH handling in config.fish and installer-managed.fish
  - Improved active config script PATH detection

### Changed

- **Unified configuration management with chezmoi**:
  - Replaced GNU Stow with chezmoi for core dotfile deployment
  - Removed dual Stow/chezmoi system for consistency
  - Simplified profile system: profiles now provide runtime overlays (config.fish, keybinds.conf, scripts/)
  - Removed `fedpunk-stow-profile` command and profile config/ directories
  - Updated all deployment scripts to use chezmoi exclusively
  - Modified profile activation to use chezmoi apply
  - Updated installation scripts to configure chezmoi
- **Installation Process**:
  - Split installation into preflight (Cargo, Fish) and main installation phases
  - Improved error handling and logging throughout installation
  - Added gum-based UI for better installation feedback
  - Restructured terminal package installation

### Known Issues

- **Yazi Installation**: May fail if unzip package is not available; cargo build can fail on minimal systems
- **Neovim Configuration**: Git submodule deployment may need manual initialization
- **Profile Configuration**: Profile-specific config deployment not yet implemented (fedpunk-activate-profile:236)
- **chezmoi Deployment**: Final chezmoi apply may fail in some edge cases; investigating root cause
- **Terminal-Only Mode**: Some packages may have unnecessary desktop dependencies

### Development Notes

- Tested on Fedora 43 (Workstation and Container)
- Requires Fish shell, git, and gum for installation
- Installation logs available at /tmp/fedpunk-install-*.log
- Core functionality verified through devcontainer testing

### Migration Guide

For users upgrading from pre-0.1.0 versions using GNU Stow:

#### Core System Migration

1. Backup your current configuration: `cp -r ~/.config ~/.config.backup`
2. Install chezmoi: `curl -sL https://github.com/twpayne/chezmoi/releases/latest/download/chezmoi-linux-amd64 -o ~/.local/bin/chezmoi && chmod +x ~/.local/bin/chezmoi`
3. Configure chezmoi: `mkdir -p ~/.config/chezmoi && echo 'sourceDir = "/home/'$(whoami)'/.local/share/fedpunk"' > ~/.config/chezmoi/chezmoi.toml`
4. Remove old stow-deployed configs: `stow -D . -t ~ -d ~/.local/share/fedpunk` (if stow is still installed)
5. Deploy with chezmoi: `chezmoi apply`
6. Update scripts to use ~/.local/bin/ instead of ~/.local/share/fedpunk/bin/

#### Profile System Migration

If you were using `fedpunk-stow-profile`:

1. Remove Stow-based profile configs: `rm -rf ~/.local/share/fedpunk/profiles/*/config`
2. Profile customizations now go directly in the profile root:
   - `profiles/myprofile/config.fish` - Fish shell customizations (sourced at runtime)
   - `profiles/myprofile/keybinds.conf` - Hyprland keybindings (included at runtime)
   - `profiles/myprofile/scripts/` - Utility scripts (added to PATH)
3. No deployment command needed - profile files are sourced automatically

[0.1.0]: https://github.com/softmax0112/fedpunk/releases/tag/v0.1.0
