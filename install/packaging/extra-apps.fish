#!/usr/bin/env fish
# Extra Applications & Tooling
# Edit the lists below to add your own applications

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


section "Extra Applications & Tooling"

# DNF packages to install
set DNF_PACKAGES \
    gnome-software \
    discord

# Flatpak apps to install (use Flathub app IDs)
set FLATPAK_APPS \
    com.spotify.Client

# Install DNF packages
if test (count $DNF_PACKAGES) -gt 0
    echo ""
    info "Installing DNF packages: "(string join ", " $DNF_PACKAGES)
    gum spin --spinner dot --title "Installing packages..." -- fish -c '
        sudo dnf install -qy '"$DNF_PACKAGES"' >>'"$FEDPUNK_LOG_FILE"' 2>&1
    ' && success "DNF packages installed" || warning "Some packages may have failed"
end

# Install Flatpak apps
if test (count $FLATPAK_APPS) -gt 0
    echo ""
    info "Installing Flatpak apps"
    for app in $FLATPAK_APPS
        gum spin --spinner dot --title "Installing $app..." -- fish -c '
            flatpak install -y flathub '"$app"' >>'"$FEDPUNK_LOG_FILE"' 2>&1
        ' && success "$app installed" || warning "Failed to install $app"
    end
end

echo ""
box "Extra Applications Complete!" $GUM_SUCCESS
