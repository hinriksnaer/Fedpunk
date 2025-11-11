#!/usr/bin/env fish
# Desktop-specific system setup: RPM Fusion repos, XDG user directories
# This only runs for desktop setups

# Source helper functions
source "$FEDPUNK_INSTALL/helpers/all.fish"

section "Desktop System Setup"

# Enable RPM Fusion repositories (needed for multimedia codecs, NVIDIA drivers)
echo ""
info "Enabling package repositories"

# Get Fedora version
set fedora_version (rpm -E %fedora)
set free_url "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$fedora_version.noarch.rpm"
set nonfree_url "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$fedora_version.noarch.rpm"

# Use line spinner for network download operations
gum spin --spinner line --title "Enabling RPM Fusion repositories..." -- fish -c '
    sudo dnf install -qy --skip-broken '$free_url' '$nonfree_url' >>'"$FEDPUNK_LOG_FILE"' 2>&1
' && success "RPM Fusion repositories enabled" || warning "RPM Fusion repositories may already be enabled"

# Setup XDG user directories (creates Downloads, Pictures, Videos, etc.)
echo ""
info "Setting up user directories"
if command -v xdg-user-dirs-update >/dev/null 2>&1
    gum spin --spinner dot --title "Configuring user directories..." -- fish -c '
        xdg-user-dirs-update >>'"$FEDPUNK_LOG_FILE"' 2>&1
    ' && success "User directories configured" || warning "xdg-user-dirs-update failed"
else
    info "xdg-user-dirs will be installed with desktop components"
end

echo ""
box "Desktop System Setup Complete!" $GUM_SUCCESS
