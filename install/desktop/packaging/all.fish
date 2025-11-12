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
echo ""
info "Installing fonts"
source "$FEDPUNK_INSTALL/desktop/packaging/fonts.fish"

# Audio stack
echo ""
info "Installing audio stack"
source "$FEDPUNK_INSTALL/desktop/packaging/audio.fish"

# Multimedia codecs and hardware acceleration
echo ""
info "Installing multimedia codecs"
source "$FEDPUNK_INSTALL/desktop/packaging/multimedia.fish"

# bluetui (Bluetooth TUI)
echo ""
info "Installing bluetui"
source "$FEDPUNK_INSTALL/desktop/packaging/bluetui.fish"

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
