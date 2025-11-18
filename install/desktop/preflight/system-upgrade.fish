#!/usr/bin/env fish
# System upgrade for desktop installations
# Upgrades all system packages to latest versions

# Source helper functions
source "$FEDPUNK_INSTALL/helpers/all.fish"

section "System Upgrade"

# System upgrade (opt-in for desktop)
if opt_in "Run full system upgrade? (may take a while)" "no"
    subsection "Upgrading system packages"
    gum spin --spinner meter --title "Running system upgrade..." -- fish -c '
        sudo dnf upgrade --refresh -qy >>'"$FEDPUNK_LOG_FILE"' 2>&1
    ' && success "System packages upgraded" || warning "System upgrade completed with issues (may be already up-to-date)"
end

echo ""
box "System Upgrade Complete!" $GUM_SUCCESS
