#!/usr/bin/env fish
# Package Installation
# Install all packages (terminal and desktop components)

# Source helper functions
source "$FEDPUNK_INSTALL/helpers/all.fish"

# ================================
# Terminal Packages
# ================================

# Yazi file manager
install_if_enabled "FEDPUNK_INSTALL_YAZI" \
    "Install Yazi file manager?" \
    "$FEDPUNK_INSTALL/packaging/yazi.fish" \
    "yes"

# Claude CLI
install_if_enabled "FEDPUNK_INSTALL_CLAUDE" \
    "Install Claude CLI?" \
    "$FEDPUNK_INSTALL/packaging/claude.fish" \
    "yes"

# GitHub CLI
install_if_enabled "FEDPUNK_INSTALL_GH" \
    "Install GitHub CLI (gh)?" \
    "$FEDPUNK_INSTALL/packaging/gh.fish" \
    "yes"

# ================================
# Desktop Packages
# ================================

# Firefox browser
echo ""
info "Installing Firefox web browser"
gum spin --spinner dot --title "Refreshing package metadata..." -- fish -c '
    sudo dnf makecache --refresh -q >>'"$FEDPUNK_LOG_FILE"' 2>&1
' && success "Package metadata refreshed" || warning "Could not refresh metadata"

gum spin --spinner dot --title "Installing Firefox..." -- fish -c '
    sudo dnf install -qy --skip-broken --best firefox >>'"$FEDPUNK_LOG_FILE"' 2>&1
' && success "Firefox installed" || error "Firefox installation failed"

# Fonts
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
    source "$FEDPUNK_INSTALL/packaging/fonts.fish"
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
    source "$FEDPUNK_INSTALL/packaging/audio.fish"
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
    source "$FEDPUNK_INSTALL/packaging/multimedia.fish"
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
    source "$FEDPUNK_INSTALL/packaging/bluetui.fish"
else
    info "Skipping Bluetooth support installation"
    echo "[SKIPPED] Bluetooth support installation (FEDPUNK_INSTALL_BLUETOOTH=false)" >> $FEDPUNK_LOG_FILE
end

# NVIDIA drivers (if GPU detected)
echo ""
if lspci | grep -i nvidia >/dev/null 2>&1
    info "NVIDIA GPU detected"
    if confirm "Install NVIDIA proprietary drivers?"
        source "$FEDPUNK_INSTALL/packaging/nvidia.fish"
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
source "$FEDPUNK_INSTALL/packaging/extra-apps.fish"
