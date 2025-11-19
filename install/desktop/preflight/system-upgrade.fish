#!/usr/bin/env fish
# System upgrade for desktop installations
# Upgrades all system packages to latest versions

# Source helper functions
source "$FEDPUNK_INSTALL/helpers/all.fish"

section "System Upgrade"

# Check if system upgrade is enabled via mode configuration
if set -q FEDPUNK_INSTALL_SYSTEM_UPGRADE; and test "$FEDPUNK_INSTALL_SYSTEM_UPGRADE" = "true"
    subsection "Upgrading system packages"
    gum spin --spinner meter --title "Running system upgrade..." -- fish -c '
        sudo dnf upgrade --refresh -qy >>'"$FEDPUNK_LOG_FILE"' 2>&1
    ' && success "System packages upgraded" || warning "System upgrade completed with issues (may be already up-to-date)"
else
    info "System upgrade skipped (system_upgrade=false in mode configuration)"
    echo "[SKIPPED] System upgrade disabled by mode configuration" >> $FEDPUNK_LOG_FILE
end

echo ""
box "System Upgrade Phase Complete!" $GUM_SUCCESS
