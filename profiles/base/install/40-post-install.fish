#!/usr/bin/env fish
# ============================================================================
# POST-INSTALL: Final setup tasks
# ============================================================================
# Purpose:
#   - Update all packages (catch COPR updates)
#   - Setup Claude Code if config exists
# Runs: After configs are deployed
# ============================================================================

source "$FEDPUNK_PROFILE_PATH/lib/helpers.fish"

section "Post-Installation"

# Update packages
subsection "Checking for package updates"
step "Updating packages" "sudo dnf upgrade -qy --refresh"

# Setup Claude Code (if config exists)
echo ""
if test -f "$HOME/.config/claude/config.json"
    subsection "Setting up Claude Code"

    if test -f "$FEDPUNK_PATH/install/post-install/setup-claude-code.fish"
        source "$FEDPUNK_PATH/install/post-install/setup-claude-code.fish"
    else
        success "Claude Code config deployed"
    end
else
    info "No Claude Code config found"
end

echo ""
box "Post-Installation Complete!" $GUM_SUCCESS
