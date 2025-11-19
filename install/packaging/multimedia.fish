#!/usr/bin/env fish
# Install multimedia codecs and hardware acceleration support

# Source helper functions
source "$FEDPUNK_INSTALL/helpers/all.fish"

section "Multimedia Codecs"

# Install multimedia group
info "Installing multimedia packages"
gum spin --spinner meter --title "Installing multimedia group..." -- fish -c '
    sudo dnf group install -qy multimedia >>'"$FEDPUNK_LOG_FILE"' 2>&1
' && success "Multimedia group installed" || warning "Multimedia group may already be installed"

# Swap ffmpeg-free with full ffmpeg
echo ""
info "Installing full FFmpeg with codec support"
gum spin --spinner meter --title "Swapping to full FFmpeg..." -- fish -c '
    sudo dnf swap -qy --allowerasing ffmpeg-free ffmpeg >>'"$FEDPUNK_LOG_FILE"' 2>&1
' && success "Full FFmpeg installed" || warning "FFmpeg may already be installed"

# Upgrade multimedia stack
gum spin --spinner dot --title "Upgrading multimedia stack..." -- fish -c '
    sudo dnf upgrade -qy @multimedia --setopt="install_weak_deps=False" >>'"$FEDPUNK_LOG_FILE"' 2>&1
' && success "Multimedia stack upgraded" || warning "Multimedia stack already up to date"

# Install sound and video group
echo ""
info "Installing additional sound and video packages"
gum spin --spinner meter --title "Installing sound-and-video group..." -- fish -c '
    sudo dnf group install -qy sound-and-video >>'"$FEDPUNK_LOG_FILE"' 2>&1
' && success "Sound and video packages installed" || warning "Sound and video packages may already be installed"

# Hardware video acceleration
echo ""
section "Hardware Video Acceleration"

info "Installing base hardware acceleration packages"
gum spin --spinner dot --title "Installing libva and ffmpeg-libs..." -- fish -c '
    sudo dnf install -qy ffmpeg-libs libva libva-utils >>'"$FEDPUNK_LOG_FILE"' 2>&1
' && success "Base acceleration packages installed" || warning "Packages may already be installed"

# Detect GPU and install appropriate drivers
if lspci | grep -i "VGA.*Intel" >/dev/null 2>&1
    echo ""
    info "Intel GPU detected, installing Intel media driver"
    gum spin --spinner dot --title "Installing Intel media driver..." -- fish -c '
        sudo dnf swap -qy --allowerasing libva-intel-media-driver intel-media-driver >>'"$FEDPUNK_LOG_FILE"' 2>&1
    ' && success "Intel media driver installed" || warning "Intel media driver may already be installed"
end

if lspci | grep -i "VGA.*AMD\|VGA.*Radeon" >/dev/null 2>&1
    echo ""
    info "AMD GPU detected, installing Mesa freeworld drivers"
    gum spin --spinner dot --title "Installing AMD freeworld drivers..." -- fish -c '
        sudo dnf swap -qy --allowerasing mesa-va-drivers mesa-va-drivers-freeworld >>'"$FEDPUNK_LOG_FILE"' 2>&1
        sudo dnf swap -qy --allowerasing mesa-vdpau-drivers mesa-vdpau-drivers-freeworld >>'"$FEDPUNK_LOG_FILE"' 2>&1
    ' && success "AMD freeworld drivers installed" || warning "AMD drivers may already be installed"
end

echo ""
box "Multimedia Codecs & Hardware Acceleration Complete!" $GUM_SUCCESS
