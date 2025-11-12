#!/usr/bin/env fish
# Post-installation tasks

# Source helper functions
source "$FEDPUNK_INSTALL/helpers/all.fish"

section "Post-Installation"

# Check for package updates (catch any updates from COPRs we just added)
source "$FEDPUNK_INSTALL/post-install/update-packages.fish"

# System optimizations (boot time improvements, service tuning)
source "$FEDPUNK_INSTALL/post-install/optimize-system.fish"

# Setup theme system
source "$FEDPUNK_INSTALL/post-install/setup-themes.fish"

success "Post-installation complete"
