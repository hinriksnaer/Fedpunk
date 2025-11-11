#!/usr/bin/env fish
# Post-installation tasks

# Source helper functions
source "$FEDPUNK_INSTALL/helpers/all.fish"

section "Post-Installation"

# Check for package updates (catch any updates from COPRs we just added)
fish "$FEDPUNK_INSTALL/post-install/update-packages.fish"

# Setup theme system
fish "$FEDPUNK_INSTALL/post-install/setup-themes.fish"

success "Post-installation complete"
