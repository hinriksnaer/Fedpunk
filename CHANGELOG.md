# Changelog

All notable changes to Fedpunk will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### 🎉 Major Features

#### CLI Modularization
- **Refactored** Monolithic 1,083-line CLI into modular architecture
  - New thin dispatcher at `bin/fedpunk` (~190 lines) routes commands to modular handlers
  - Commands organized in `cli/<command>/<command>.fish` with functions as subcommands
  - Descriptions extracted from `--description` flags - no separate metadata files
  - Private functions (prefixed with `_`) hidden from help and protected from direct execution
  - Smart TUI/CLI mode: if arg provided → CLI mode, if no arg + TTY → TUI selector
  - Modules can now provide their own CLI commands via `module/cli/` directories

#### Module CLI Extensions
- **Added** Module CLI extension pattern for self-contained command modules
  - Modules place CLI commands in `module/cli/<command>/<command>.fish`
  - Linker automatically deploys module CLIs as symlinks to `$FEDPUNK_ROOT/cli/`
  - Commands seamlessly integrate with main `fedpunk` dispatcher
  - Vault commands now live in bitwarden module (`modules/bitwarden/cli/vault/`)
  - Bluetooth commands now live in bluetooth module (`modules/bluetooth/cli/bluetooth/`)

### 🔧 Improvements

#### UI Utilities
- **Added** Smart UI utility functions in `lib/fish/ui.fish`
  - `ui-select-smart`: TUI selector if interactive and no value, otherwise use provided value
  - `ui-input-smart`: TUI input if interactive and no value, otherwise use provided value
  - `ui-confirm-smart`: TUI confirm if interactive, use default if not
  - Enables consistent behavior across TUI and CLI modes

#### Linker Enhancements
- **Added** CLI deployment functions to linker
  - `linker-deploy-cli`: Symlinks module CLI commands to `$FEDPUNK_ROOT/cli/`
  - `linker-remove-cli`: Removes CLI symlinks when module is removed
  - CLI state tracked in `.linker-state.json` alongside config files

#### Testing
- **Added** Comprehensive CLI dispatcher test suite (37 tests)
  - Tests command discovery, subcommand execution, help generation
  - Tests error handling, exit codes, private function protection
  - Test command `fedpunk doctor` for dispatcher verification

### 📝 Project Structure

- **New** `bin/fedpunk` - Modular CLI dispatcher
- **New** `cli/` directory - Core command modules (apply, doctor, init, module, profile, sync, theme, wallpaper)
- **New** `modules/bitwarden/cli/vault/` - Vault commands as module CLI
- **New** `modules/bluetooth/cli/bluetooth/` - Bluetooth commands as module CLI
- **New** `tests/cli-dispatcher.fish` - CLI test suite
- **Changed** `modules/fish/config/.local/bin/fedpunk` - Now thin wrapper delegating to new dispatcher

## [0.2.2] - 2025-11-25

### 🐛 Bug Fixes

- **Fixed** Neovim theme not loading on startup
  - Theme-watcher now loads the current fedpunk theme on VimEnter
  - Previously only watched for changes, causing default theme to show on startup
  - Affects both default profile (LazyVim) and dev profile (neovim-custom)

## [0.2.1] - 2025-11-25

### 🔧 Improvements

#### Installation & Setup
- **Fixed** Installer using temporary directories causing broken symlinks after installation
  - Changed from `/tmp/fedpunk-install-$` to permanent backup location
  - Now backs up existing installation to `~/.local/share/fedpunk.backup.TIMESTAMP`
  - Ensures all symlinks remain valid after installation completes
- **Fixed** Create `.active-config` symlink before deploying modules
  - Plugin deployment now works correctly on first install
  - Modules can reference active profile during deployment

#### Performance
- **Optimized** SELinux context restoration during installation
  - Reduced from scanning 5M+ files to only Fedpunk-managed directories
  - Removed duplicate SELinux restoration from hyprland module
  - Now restores context only for: `~/.config/{hypr,kitty,fish,nvim}`, `~/.local/bin`, `~/.local/share/fedpunk`
  - Dramatically reduced installation time

#### Configuration Management
- **Centralized** configuration file backups
  - Moved from scattered `.backup.TIMESTAMP` files in `~/.config/` to centralized location
  - All backups now in `~/.local/share/fedpunk-backups/config-backups/`
  - Flattened file paths with underscore replacement for better organization
- **Fixed** Diff functionality during conflict resolution
  - Now resolves symlinks before attempting diff
  - Clear error messages for broken symlinks
  - Better conflict handling experience

#### Hyprland
- **Added** Per-mode Hyprland configuration system
  - Each mode can now have custom `hypr.conf` overrides
  - New directory structure: `profiles/<profile>/modes/<mode>/hypr.conf`
  - Runtime-generated `active-mode.conf` sources mode-specific settings
  - Supports mode-specific monitor resolution and layout preferences
  - Installer automatically generates and reloads configuration
- **Added** Automatic Hyprland reload after installation
  - Configuration changes apply immediately without manual reload
  - Reloads both after module deployment and mode setup

#### Neovim
- **Refactored** Migrated to LazyVim for default profile, custom config for dev profile
  - Default profile now uses official LazyVim starter for batteries-included experience
  - LazyVim starter dynamically cloned via before script (not tracked in git)
  - Dev profile uses custom Neovim configuration via plugin system (`neovim-custom`)
  - Created comprehensive CI tests for both default and dev profiles
  - Added theme-watcher plugin for automatic colorscheme reloading
  - Fixed LazyVim import order warning by disabling check for fedpunk theme system
  - Updated all theme files to work with both LazyVim (default) and custom config (dev)
  - Theme files now include conditional check to prevent duplicate LazyVim imports
  - Dynamic theme switching now works seamlessly in both profiles

### 🐛 Bug Fixes

- **Fixed** Git tracking of runtime-generated files
  - Added `.active-config` to gitignore (runtime-generated symlink)
  - Added `active-mode.conf` to gitignore (runtime-generated config)
  - Added centralized backup directory to gitignore
  - Cleaned up tracked files that should be runtime-generated
- **Fixed** Hyprland globbing error from deprecated monitors.conf source
  - Removed profile-level monitors.conf source (replaced by mode-based system)
  - Monitor configuration now handled exclusively via mode-specific hypr.conf files

### 📝 Project Structure

- **Updated** `.gitignore` with runtime-generated files and backup directories
- **Improved** Mode configuration structure from flat YAML to directories
  - Better organization with `mode.yaml` + `hypr.conf` per mode
  - Cleaner separation of mode metadata and configuration

### 🔄 Breaking Changes

None - All changes are backward compatible. Existing installations will work without modification.

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

[Unreleased]: https://github.com/hinriksnaer/Fedpunk/compare/v0.2.1...HEAD
[0.2.1]: https://github.com/hinriksnaer/Fedpunk/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/hinriksnaer/Fedpunk/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/hinriksnaer/Fedpunk/releases/tag/v0.1.0
