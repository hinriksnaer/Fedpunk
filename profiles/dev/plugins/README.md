# Profile Plugins

This directory contains profile-specific modules (plugins) that extend the base system.

## Structure

Each plugin follows the same structure as regular modules:

```
plugins/my-plugin/
├── module.toml      # Module metadata
├── config/          # Dotfiles (stowed to $HOME)
│   └── .config/...
└── scripts/         # Lifecycle scripts
    ├── install
    ├── update
    ├── before
    └── after
```

## How Plugins Work

- Plugins are profile-scoped modules
- They follow the exact same module.toml schema
- They can depend on base modules
- They are deployed when the profile is activated

## Example: Custom Development Tools

```toml
# plugins/dev-tools/module.toml
[module]
name = "dev-tools"
description = "Custom development utilities for this profile"
dependencies = ["fish"]
priority = 50

[lifecycle]
after = ["setup-aliases"]

[packages]
cargo = ["cargo-watch", "cargo-edit"]
```

Plugins allow you to customize your environment without modifying the base fedpunk modules.
