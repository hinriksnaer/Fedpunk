# Changelog

All notable changes to Fedpunk will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.0] - 2025-11-24

### 🎉 Major Features

#### Default Profile
- **Added** `profiles/default/` as the recommended starting point for new users
  - Desktop mode: Full Hyprland environment without hardware-specific configurations
  - Container mode: Minimal terminal-only setup for devcontainers and servers
  - Excludes: NVIDIA drivers, audio/multimedia packages, personal entertainment apps, hardware-specific configs
  - Clean, general-purpose setup suitable for most Fedora users
- **Changed** `dev` profile positioning: Now explicitly documented as personal/reference implementation
- **Added** Comprehensive `profiles/default/README.md` with usage guide and customization instructions

#### Vertex AI Module
- **Added** `modules/vertex-ai/` for Google Vertex AI authentication with Claude Code
  - Opt-in module that can be added to any profile
  - Sets required environment variables: `CLAUDE_CODE_USE_VERTEX`, `CLOUD_ML_REGION`, `ANTHROPIC_VERTEX_PROJECT_ID`
  - Added to `dev/container` mode as reference implementation
  - Depends on `claude` module for proper integration

#### Yazi Theming Integration
- **Added** Live theme switching support for Yazi file manager
  - Automatically switches yazi flavor based on active Fedpunk theme
  - 12 theme flavors matching existing theme system
  - No restart required - updates instantly with other theme changes
  - Integrated with existing theme management commands

### 📚 Documentation

#### Complete Overhaul
- **Rewrote** `docs/guides/installation.md` from scratch
  - Comprehensive profile selection guide (default/dev/example)
  - Detailed mode selection explanations (desktop/container)
  - Troubleshooting section with common issues and solutions
  - Security considerations for bootstrap script and sudo usage
  - Container-specific installation instructions (devcontainers, remote servers)
  - Post-installation guide with next steps

#### README Updates
- **Updated** Main README with profile system explanation table
  - Clarified purpose of each profile (default/dev/example)
  - Added profile/mode selection code examples
  - Updated theme count from 11 to 12 (added rose-pine-dark)
  - Fixed version references (v2.0 → v0.2.0 for consistency)
  - Added Vertex AI module mentions
  - Enhanced Claude Code integration section

### 🔧 Improvements

#### Module System
- **Improved** Module dependency resolution and deployment
- **Added** State-tracked configuration linker for better module management
- **Enhanced** Module CLI with better error handling and feedback

#### Installation & Setup
- **Fixed** Fish shell not being set as default in fresh installs (#24)
  - Now checks actual shell from `/etc/passwd` instead of `$SHELL` environment variable
  - Adds comprehensive logging to fish install script
- **Added** Test assertion to verify Fish is set as default shell
- **Fixed** Add `jq` dependency to boot.sh installer and CI workflow
- **Fixed** Move fish install script to run after package installation

#### Bluetooth Support
- **Separated** Bluetooth into dedicated module for better device support (#25)
  - Previously bundled with audio, now independent
  - Improved hardware compatibility
  - Better isolation and modularity

#### VM Testing & Development
- **Added** VM testing tools for fedpunk development
  - Create and manage test VMs easily
  - Converted VM scripts from bash to fish
  - Optimized VM performance for demos and desktop testing
  - Improved VM management commands with cleaner UX

#### Vault Integration
- **Fixed** Update vault claude-backup/restore to use long-lived tokens
  - More reliable authentication
  - Better session management

#### Profile System
- **Fixed** Make profile symlinks user-agnostic and portable (#22)
  - No longer hardcoded to specific usernames
  - Works across different installations

#### Package Management
- **Added** Quiet mode (`-q`) to all DNF install commands
  - Cleaner installation output
  - Reduced verbosity during package installation
- **Fixed** Add sudo to flatpak commands to prevent authentication prompts (#21)

#### Hardware Monitoring
- **Added** Hardware monitoring groups to waybar
- **Added** Fan control plugin for Aquacomputer Octo hardware monitoring
  - Profile-specific plugin in `profiles/dev/plugins/fancontrol/`
  - Real-time fan speed and temperature monitoring
  - Waybar integration

#### NVIDIA Support
- **Fixed** Use grubby instead of manual GRUB editing for NVIDIA
  - More reliable and safer GRUB configuration
  - Better error handling

#### CI/CD
- **Added** CI workflow to test dev desktop installation (#23)
  - Automated testing of installation process
  - Catches issues early

### 🐛 Bug Fixes

- **Fixed** Critical installer and theme system bugs
- **Fixed** Fish shell default and Claude command installation issues
- **Fixed** Comprehensive logging issues in fish install script
- **Fixed** Re-enable dev-extras and fancontrol plugins in dev desktop
- **Fixed** Restructure fan-control plugin to avoid stow conflicts
- **Fixed** Disable fancontrol plugin in dev desktop for testing (temporary)
- **Fixed** Disable dev-extras in desktop profile for VM testing (temporary)

### 📝 Project Structure

- **Updated** `.gitignore` to track `profiles/default/`
- **Added** CHANGELOG.md for release tracking
- **Improved** Documentation organization and cross-referencing

### 🔄 Breaking Changes

None - All changes are backward compatible with existing installations.

### 🏗️ Internal Changes

- Refactored VM scripts for better maintainability
- Improved module deployment logic
- Enhanced state tracking for configuration files
- Better error messages and logging throughout

---

## [0.1.0] - Initial Release

### Initial Features
- Modular configuration engine for Fedora Linux
- 27 self-contained modules with automatic dependency resolution
- Profile system supporting multiple environments
- 11 live-switching themes (Hyprland, Kitty, Neovim, btop, Rofi, Waybar)
- Keyboard-driven workflow with vim-style navigation
- GNU Stow-based instant deployment
- Fish shell with modern CLI tools
- Hyprland Wayland compositor with tiling
- Neovim with LSP and LazyVim
- GitHub CLI and Bitwarden integration
- Claude Code integration
- Desktop and container deployment modes
- Plugin framework for profile-specific customizations

---

## Release Notes Format

### Legend
- 🎉 **Major Features** - Significant new functionality
- 📚 **Documentation** - Documentation improvements
- 🔧 **Improvements** - Enhancements to existing features
- 🐛 **Bug Fixes** - Bug fixes and corrections
- 🔄 **Breaking Changes** - Changes that may require user action
- 🏗️ **Internal Changes** - Code refactoring and internal improvements

### Change Types
- **Added** - New features or functionality
- **Changed** - Changes to existing functionality
- **Deprecated** - Features that will be removed in future versions
- **Removed** - Features that have been removed
- **Fixed** - Bug fixes
- **Security** - Security-related changes

---

[Unreleased]: https://github.com/hinriksnaer/Fedpunk/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/hinriksnaer/Fedpunk/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/hinriksnaer/Fedpunk/releases/tag/v0.1.0
