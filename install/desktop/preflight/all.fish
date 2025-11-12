#!/usr/bin/env fish
# Desktop-specific preflight setup
# Sets up RPM Fusion repositories and XDG user directories

# Source helper functions
source "$FEDPUNK_INSTALL/helpers/all.fish"

# Desktop system setup (RPM Fusion, XDG user directories)
source "$FEDPUNK_INSTALL/desktop/preflight/setup-desktop-system.fish"
