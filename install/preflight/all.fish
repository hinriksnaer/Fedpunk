#!/usr/bin/env fish
# Shared preflight setup - Runs for both terminal and desktop setups
# Sets up Cargo, Fish, and system configurations

# Source helper functions
source "$FEDPUNK_INSTALL/helpers/all.fish"

# CRITICAL ORDER: setup-cargo must run FIRST
# Fedpunk relies heavily on Rust/Cargo for modern CLI tools (lsd, ripgrep, etc.)
# If cargo isn't available early, later steps will fail
fish "$FEDPUNK_INSTALL/preflight/shared/setup-cargo.fish"

# Setup Fish shell early (needed for Fish-based installation scripts)
fish "$FEDPUNK_INSTALL/preflight/shared/setup-fish.fish"

# Shared system setup (git submodules, system upgrade, core utilities, SELinux)
fish "$FEDPUNK_INSTALL/preflight/shared/setup-system.fish"

# Install essential development tools and languages
fish "$FEDPUNK_INSTALL/preflight/shared/install-essentials.fish"
