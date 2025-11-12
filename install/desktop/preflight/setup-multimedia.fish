#!/usr/bin/env fish
# Setup Flatpak and Flathub repository

# Source helper functions
source "$FEDPUNK_INSTALL/helpers/all.fish"

section "Multimedia & Application Setup"

# Install Flatpak if not already installed
if not command -v flatpak >/dev/null 2>&1
    info "Installing Flatpak"
    gum spin --spinner meter --title "Installing Flatpak..." -- fish -c '
        sudo dnf install -qy flatpak >>'"$FEDPUNK_LOG_FILE"' 2>&1
    ' && success "Flatpak installed" || begin
        error "Failed to install Flatpak"
        exit 1
    end
else
    success "Flatpak already installed"
end

# Add Flathub repository
echo ""
info "Adding Flathub repository"

# Check if Flathub is already added
if flatpak remote-list 2>/dev/null | grep -q "flathub"
    success "Flathub repository already configured"
else
    gum spin --spinner line --title "Adding Flathub remote..." -- fish -c '
        sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo >>'"$FEDPUNK_LOG_FILE"' 2>&1
    ' && success "Flathub repository added" || warning "Failed to add Flathub repository"
end

# Install AppImage support (FUSE)
echo ""
info "Installing AppImage support"
gum spin --spinner dot --title "Installing FUSE..." -- fish -c '
    sudo dnf install -qy fuse >>'"$FEDPUNK_LOG_FILE"' 2>&1
' && success "AppImage support installed" || warning "FUSE may already be installed"

echo ""
box "Multimedia & Application Setup Complete!" $GUM_SUCCESS
