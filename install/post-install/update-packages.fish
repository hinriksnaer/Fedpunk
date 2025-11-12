#!/usr/bin/env fish
# Post-install package update
# Quick check for updates to packages we just installed

# FEDPUNK_PATH and FEDPUNK_INSTALL should be set by parent install.fish
# Source helper functions
if test -f "$FEDPUNK_INSTALL/helpers/all.fish"
    source "$FEDPUNK_INSTALL/helpers/all.fish"
end

echo ""
info "Checking for package updates"

# Quick check for any available updates
gum spin --spinner meter --title "Checking for package updates..." -- fish -c '
    sudo dnf upgrade --refresh -qy --best >>'"$FEDPUNK_LOG_FILE"' 2>&1
' && success "Packages are up-to-date" || warning "Some packages may need manual update"

success "Package update check complete"
