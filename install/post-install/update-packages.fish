#!/usr/bin/env fish
# Post-install package update
# Quick check for updates to packages we just installed

# Source helper functions
if not set -q FEDPUNK_PATH
    set -gx FEDPUNK_PATH "$HOME/.local/share/fedpunk"
end
if not set -q FEDPUNK_INSTALL
    set -gx FEDPUNK_INSTALL "$FEDPUNK_PATH/install"
end
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
