#!/usr/bin/env fish
# Preflight checks and system setup

# Source helper functions
source "$FEDPUNK_INSTALL/helpers/all.fish"

# Run system-level setup (repos, upgrades, submodules, SELinux)
fish "$FEDPUNK_INSTALL/preflight/install-system.fish"
