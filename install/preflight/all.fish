#!/usr/bin/env fish
# Preflight checks and system setup

# ABSOLUTE FIRST STEP: Setup Cargo/Rust (many tools depend on this)
fish "$FEDPUNK_INSTALL/preflight/setup-cargo.fish"

# SECOND STEP: Setup Fish shell enhancements (stow, gum, config, plugins)
fish "$FEDPUNK_INSTALL/preflight/setup-fish.fish"

fish "$FEDPUNK_INSTALL/preflight/install-essentials.fish"

# Source helper functions
source "$FEDPUNK_INSTALL/helpers/all.fish"

# Run system-level setup (repos, upgrades, submodules, SELinux)
fish "$FEDPUNK_INSTALL/preflight/setup-system.fish"
