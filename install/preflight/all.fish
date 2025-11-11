#!/usr/bin/env fish
# Preflight checks and system setup

fish "$FEDPUNK_INSTALL/preflight/install-essentials.fish"

# Source helper functions
source "$FEDPUNK_INSTALL/helpers/all.fish"

# Run system-level setup (repos, upgrades, submodules, SELinux)
fish "$FEDPUNK_INSTALL/preflight/install-system.fish"
