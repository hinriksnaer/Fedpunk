#!/usr/bin/env fish
# Desktop-specific preflight setup
# Sets up RPM Fusion repositories and XDG user directories

# Source helper functions
source "$FEDPUNK_INSTALL/helpers/all.fish"

# System upgrade (desktop-only, opt-in)
source "$FEDPUNK_INSTALL/desktop/preflight/system-upgrade.fish"

# Update system firmware (desktop-only, opt-in)
source "$FEDPUNK_INSTALL/desktop/preflight/update-firmware.fish"

# Desktop system setup (RPM Fusion, XDG user directories)
source "$FEDPUNK_INSTALL/desktop/preflight/setup-desktop-system.fish"

# Multimedia and application setup (Flatpak, Flathub, AppImage support)
source "$FEDPUNK_INSTALL/desktop/preflight/setup-multimedia.fish"
