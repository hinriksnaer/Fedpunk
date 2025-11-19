#!/usr/bin/env fish
# Post-installation tasks (mode-agnostic)
# Desktop-specific tasks are handled by dedicated chezmoi lifecycle scripts:
#   - run_once_after_desktop-optimize.fish.tmpl (system optimizations)
#   - run_onchange_after_desktop-themes.fish.tmpl (theme setup)

# Source helper functions
source "$FEDPUNK_INSTALL/helpers/all.fish"

section "Post-Installation"

# Check for package updates (catch any updates from COPRs we just added)
source "$FEDPUNK_INSTALL/post-install/update-packages.fish"

# Setup Claude Code (if config exists)
if test -f "$FEDPUNK_INSTALL/post-install/setup-claude-code.fish"
    source "$FEDPUNK_INSTALL/post-install/setup-claude-code.fish"
end

success "Post-installation complete"
