#!/usr/bin/env fish
# Desktop Package Installation
# Install packages for desktop components

# Source helper functions
source "$FEDPUNK_INSTALL/helpers/all.fish"

# Firefox browser
echo ""
info "Installing Firefox web browser"
gum spin --spinner dot --title "Refreshing package metadata..." -- fish -c '
    sudo dnf makecache --refresh -q >>'"$FEDPUNK_LOG_FILE"' 2>&1
' && success "Package metadata refreshed" || warning "Could not refresh metadata"

gum spin --spinner dot --title "Installing Firefox..." -- fish -c '
    sudo dnf install -qy --skip-broken --best firefox >>'"$FEDPUNK_LOG_FILE"' 2>&1
' && success "Firefox installed" || error "Firefox installation failed"

# Fonts (needed for desktop)
if not set -q FEDPUNK_INSTALL_FONTS
    if confirm "Install fonts?" "yes"
        set -gx FEDPUNK_INSTALL_FONTS true
    else
        set -gx FEDPUNK_INSTALL_FONTS false
    end
end

if test "$FEDPUNK_INSTALL_FONTS" = "true"
    echo ""
    info "Installing fonts"
    source "$FEDPUNK_INSTALL/desktop/packaging/fonts.fish"
else
    info "Skipping fonts installation"
    echo "[SKIPPED] Fonts installation (FEDPUNK_INSTALL_FONTS=false)" >> $FEDPUNK_LOG_FILE
end

# Audio stack
if not set -q FEDPUNK_INSTALL_AUDIO
    if confirm "Install audio stack?" "yes"
        set -gx FEDPUNK_INSTALL_AUDIO true
    else
        set -gx FEDPUNK_INSTALL_AUDIO false
    end
end

if test "$FEDPUNK_INSTALL_AUDIO" = "true"
    echo ""
    info "Installing audio stack"
    source "$FEDPUNK_INSTALL/desktop/packaging/audio.fish"
else
    info "Skipping audio stack installation"
    echo "[SKIPPED] Audio stack installation (FEDPUNK_INSTALL_AUDIO=false)" >> $FEDPUNK_LOG_FILE
end

# Multimedia codecs and hardware acceleration
if not set -q FEDPUNK_INSTALL_MULTIMEDIA
    if confirm "Install multimedia codecs?" "yes"
        set -gx FEDPUNK_INSTALL_MULTIMEDIA true
    else
        set -gx FEDPUNK_INSTALL_MULTIMEDIA false
    end
end

if test "$FEDPUNK_INSTALL_MULTIMEDIA" = "true"
    echo ""
    info "Installing multimedia codecs"
    source "$FEDPUNK_INSTALL/desktop/packaging/multimedia.fish"
else
    info "Skipping multimedia codecs installation"
    echo "[SKIPPED] Multimedia codecs installation (FEDPUNK_INSTALL_MULTIMEDIA=false)" >> $FEDPUNK_LOG_FILE
end

# bluetui (Bluetooth TUI)
if not set -q FEDPUNK_INSTALL_BLUETOOTH
    if confirm "Install Bluetooth support?" "yes"
        set -gx FEDPUNK_INSTALL_BLUETOOTH true
    else
        set -gx FEDPUNK_INSTALL_BLUETOOTH false
    end
end

if test "$FEDPUNK_INSTALL_BLUETOOTH" = "true"
    echo ""
    info "Installing bluetui"
    source "$FEDPUNK_INSTALL/desktop/packaging/bluetui.fish"
else
    info "Skipping Bluetooth support installation"
    echo "[SKIPPED] Bluetooth support installation (FEDPUNK_INSTALL_BLUETOOTH=false)" >> $FEDPUNK_LOG_FILE
end

# NVIDIA drivers (if GPU detected)
echo ""
if lspci | grep -i nvidia >/dev/null 2>&1
    info "NVIDIA GPU detected"
    if confirm "Install NVIDIA proprietary drivers?"
        source "$FEDPUNK_INSTALL/desktop/packaging/nvidia.fish"
    else
        info "Skipping NVIDIA drivers"
        echo "[SKIPPED] NVIDIA drivers (user declined)" >> $FEDPUNK_LOG_FILE
    end
else
    info "No NVIDIA GPU detected, skipping drivers"
    echo "[SKIPPED] NVIDIA drivers (no GPU detected)" >> $FEDPUNK_LOG_FILE
end

# Extra applications
echo ""
info "Installing extra applications"
source "$FEDPUNK_INSTALL/desktop/packaging/extra-apps.fish"
