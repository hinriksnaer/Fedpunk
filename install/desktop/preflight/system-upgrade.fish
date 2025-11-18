#!/usr/bin/env fish
# System upgrade for desktop installations
# Upgrades all system packages to latest versions

# Source helper functions
source "$FEDPUNK_INSTALL/helpers/all.fish"

section "System Upgrade"

# System upgrade (opt-in for desktop)
echo ""
if confirm "Run full system upgrade? (may take a while)" "no"
    info "Upgrading system packages (this may take a while)"
    gum spin --spinner meter --title "Running system upgrade..." -- fish -c '
        sudo dnf upgrade --refresh -qy >>'"$FEDPUNK_LOG_FILE"' 2>&1
    ' && success "System packages upgraded" || warning "System upgrade completed with issues (may be already up-to-date)"
else
    info "Skipping system upgrade"
    echo "[SKIPPED] System upgrade declined by user" >> $FEDPUNK_LOG_FILE
end

echo ""
box "System Upgrade Complete!" $GUM_SUCCESS
