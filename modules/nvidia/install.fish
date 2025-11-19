#!/usr/bin/env fish
# ============================================================================
# NVIDIA MODULE: Install NVIDIA proprietary drivers
# ============================================================================

source "$FEDPUNK_LIB_PATH/helpers.fish"

subsection "Installing NVIDIA drivers"

# Get module parameters
set -q FEDPUNK_MODULE_NVIDIA_INSTALL_WAYLAND_SUPPORT; or set FEDPUNK_MODULE_NVIDIA_INSTALL_WAYLAND_SUPPORT "true"
set -q FEDPUNK_MODULE_NVIDIA_INSTALL_CUDA; or set FEDPUNK_MODULE_NVIDIA_INSTALL_CUDA "true"

# Base driver installation
set packages "akmod-nvidia"

if test "$FEDPUNK_MODULE_NVIDIA_INSTALL_CUDA" = "true"
    set packages $packages "xorg-x11-drv-nvidia-cuda"
end

step "Installing NVIDIA driver packages" \
    "sudo dnf install -qy $packages"

# Wayland support
if test "$FEDPUNK_MODULE_NVIDIA_INSTALL_WAYLAND_SUPPORT" = "true"
    echo ""
    subsection "Installing Wayland support"
    step "Installing NVIDIA Wayland drivers" \
        "sudo dnf install -qy nvidia-vaapi-driver libva-nvidia-driver"
end

echo ""
info "NVIDIA drivers installed - reboot required for full activation"
success "NVIDIA module complete"
