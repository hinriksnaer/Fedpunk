# Changelog

All notable changes to Fedpunk will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Comprehensive test suite with 16 tests covering all major functionality
- Parallel CI workflow for fast test execution
- Module template submodule in `examples/module-template`
- `environment:` section support in module.yaml for environment variable injection
- Parameter default value injection from module.yaml
- Module sources management (`fedpunk module sources add/list/sync/remove`)
- External module support via git URLs in `modules.enabled`
- Profile git URL support - deploy profiles directly from git repositories
- SSH agent stable socket management with automatic persistence

### Changed
- Profiles are now external only - no built-in profiles in core
- External modules stored in `~/.config/fedpunk/modules/`
- Profiles stored in `~/.config/fedpunk/profiles/`
- Sources stored in `~/.config/fedpunk/sources/`
- Config structure: `profile.name`, `profile.source`, `profile.mode`
- Documentation updated for minimal core architecture

### Fixed
- Config preservation - `fedpunk-config-init` no longer overwrites existing config
- Duplicate module prevention in config
- yq shell pollution with clean environment wrapper
- Variable scoping in profile getter functions
- Parameter injection now includes default values
- Environment config written to correct user-level locations

### Removed
- Built-in profiles (now external)
- Built-in themes (provided by external profiles like hyprpunk)
- MIGRATION.md (no longer needed)
- Dead neovim submodule reference

## [0.4.0] - 2024-03-13

### Added
- SSH agent improvements with stable socket support
- Module sources for multi-module repositories
- Git profile deployment from URLs

### Fixed
- SSH agent socket validation
- RPM spec directory ownership

## [0.3.2] - 2024-03-10

### Added
- DNF COPR package distribution
- Module CLI subcommands

### Fixed
- CI container git configuration
- RPM package module inclusion

## [0.3.1] - 2024-03-08

### Fixed
- Module CLI list subcommand
- SSH clusters module inclusion

## [0.3.0] - 2024-03-05

### Added
- External module support
- Profile-based configuration
- GNU Stow integration for config deployment

### Changed
- Restructured module system with dependencies
- New linker with state tracking

## [0.2.0] - 2024-02-20

### Added
- Parameter injection system
- Lifecycle hooks (before/after)
- Module CLI extensions

### Changed
- YAML-based module configuration

## [0.1.0] - 2024-02-01

### Added
- Initial release
- Fish shell module
- SSH module
- Basic deployment system

[Unreleased]: https://github.com/hinriksnaer/fedpunk/compare/v0.4.0...HEAD
[0.4.0]: https://github.com/hinriksnaer/fedpunk/compare/v0.3.2...v0.4.0
[0.3.2]: https://github.com/hinriksnaer/fedpunk/compare/v0.3.1...v0.3.2
[0.3.1]: https://github.com/hinriksnaer/fedpunk/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/hinriksnaer/fedpunk/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/hinriksnaer/fedpunk/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/hinriksnaer/fedpunk/releases/tag/v0.1.0
