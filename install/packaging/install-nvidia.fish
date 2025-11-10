#!/usr/bin/env fish

# Source helper functions
set -gx FEDPUNK_INSTALL "$HOME/.local/share/fedpunk/install"
if test -f "$FEDPUNK_INSTALL/helpers/all.fish"
    source "$FEDPUNK_INSTALL/helpers/all.fish"
end

info "Installing NVIDIA proprietary drivers"

# Check if NVIDIA GPU is present
if not lspci | grep -i nvidia >/dev/null
    warning "No NVIDIA GPU detected. Skipping NVIDIA driver installation."
    exit 0
end

success "NVIDIA GPU detected"

# Enable RPM Fusion repositories (required for NVIDIA drivers)
info "Enabling RPM Fusion repositories"
set fedora_version (rpm -E %fedora)
step "Enabling RPM Fusion" "sudo dnf install -qy https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$fedora_version.noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$fedora_version.noarch.rpm"

# Install NVIDIA proprietary drivers
echo ""
info "Installing NVIDIA drivers (this may take a while)"
step "Installing NVIDIA driver and CUDA" "sudo dnf install -qy akmod-nvidia xorg-x11-drv-nvidia-cuda"

# Install additional NVIDIA utilities
info "Installing NVIDIA utilities"
set packages \
    nvidia-settings \
    nvidia-persistenced \
    cuda-drivers

step "Installing NVIDIA utilities" "sudo dnf install -qy $packages"

# Enable nvidia-persistenced service
step "Enabling NVIDIA persistence daemon" "sudo systemctl enable nvidia-persistenced"

# Check if secure boot is enabled
if bootctl status 2>/dev/null | grep -q "Secure Boot: enabled"
    echo ""
    warning "SECURE BOOT DETECTED"
    echo ""
    info "The NVIDIA driver kernel module needs to be signed for secure boot."
    info "You have two options:"
    echo ""
    info "  Option 1 (Recommended): Disable Secure Boot in BIOS/UEFI"
    info "  Option 2: Sign the kernel module manually after reboot"
    echo ""
    info "For Option 2, after reboot run:"
    info "  sudo /usr/src/kernels/\$(uname -r)/scripts/sign-file sha256 \\"
    info "       /var/lib/shim-signed/mok/MOK.priv \\"
    info "       /var/lib/shim-signed/mok/MOK.der \\"
    info "       /lib/modules/\$(uname -r)/extra/nvidia/nvidia.ko"
    echo ""
end

# Create modprobe configuration for NVIDIA
echo ""
info "Configuring NVIDIA kernel modules"
gum spin --spinner dot --title "Creating NVIDIA modprobe configuration..." -- fish -c '
    printf "%s\n" \
        "# Disable nouveau (open source NVIDIA driver)" \
        "blacklist nouveau" \
        "options nouveau modeset=0" \
        "" \
        "# NVIDIA driver options" \
        "options nvidia-drm modeset=1" \
        "options nvidia NVreg_UsePageAttributeTable=1" \
        "options nvidia NVreg_InitializeSystemMemoryAllocations=0" | sudo tee /etc/modprobe.d/nvidia.conf >/dev/null >>'"$FEDPUNK_LOG_FILE"' 2>&1
' && success "NVIDIA modprobe configured"

# Add NVIDIA modules to initramfs
gum spin --spinner dot --title "Adding NVIDIA modules to initramfs..." -- fish -c '
    echo '\''add_drivers+=" nvidia nvidia_modeset nvidia_uvm nvidia_drm "'\'' | sudo tee /etc/dracut.conf.d/nvidia.conf >/dev/null >>'"$FEDPUNK_LOG_FILE"' 2>&1
' && success "NVIDIA modules added to initramfs"

# Regenerate initramfs
echo ""
info "Regenerating initramfs (this may take a minute)"
gum spin --spinner meter --title "Regenerating initramfs..." -- fish -c '
    sudo dracut --force >>'"$FEDPUNK_LOG_FILE"' 2>&1
' && success "Initramfs regenerated" || error "Failed to regenerate initramfs"

cd (dirname (status -f))/../

# Check for Wayland compatibility
if test "$XDG_SESSION_TYPE" = "wayland"; or command -v hyprland >/dev/null 2>&1
    echo ""
    info "Configuring Wayland compatibility"

    # Add Wayland NVIDIA environment variables to fish config
    set fish_config "$HOME/.config/fish/config.fish"
    if test -f "$fish_config"
        gum spin --spinner dot --title "Adding NVIDIA Wayland variables to fish config..." -- fish -c '
            if not grep -q "NVIDIA Wayland support" "'$fish_config'"
                printf "%s\n" \
                    "" \
                    "# NVIDIA Wayland support" \
                    "set -gx LIBVA_DRIVER_NAME nvidia" \
                    "set -gx XDG_SESSION_TYPE wayland" \
                    "set -gx GBM_BACKEND nvidia-drm" \
                    "set -gx __GLX_VENDOR_LIBRARY_NAME nvidia" \
                    "set -gx WLR_NO_HARDWARE_CURSORS 1" >> "'$fish_config'"
            end >>'"$FEDPUNK_LOG_FILE"' 2>&1
        ' && success "NVIDIA Wayland variables configured"
    else
        warning "Fish config not found at $fish_config"
        info "Add these environment variables manually:"
        info "  set -gx LIBVA_DRIVER_NAME nvidia"
        info "  set -gx XDG_SESSION_TYPE wayland"
        info "  set -gx GBM_BACKEND nvidia-drm"
        info "  set -gx __GLX_VENDOR_LIBRARY_NAME nvidia"
        info "  set -gx WLR_NO_HARDWARE_CURSORS 1"
    end

    # Enable NVIDIA configuration in Hyprland
    set hyprland_config "$HOME/.config/hypr/hyprland.conf"
    if test -f "$hyprland_config"
        gum spin --spinner dot --title "Enabling NVIDIA configuration in Hyprland..." -- fish -c '
            if not grep -q "nvidia.conf" "'$hyprland_config'"
                printf "%s\n" \
                    "" \
                    "# NVIDIA Configuration (auto-added)" \
                    "source = \$HOME/.config/hypr/conf.d/nvidia.conf" >> "'$hyprland_config'"
            end >>'"$FEDPUNK_LOG_FILE"' 2>&1
        ' && success "Hyprland NVIDIA config enabled"
    else
        info "Hyprland config not found. NVIDIA settings will be available at:"
        info "  ~/.config/hypr/conf.d/nvidia.conf"
    end
end

echo ""
box "NVIDIA Driver Installation Complete!

⚠️  IMPORTANT: You must reboot for the drivers to take effect.

After reboot, verify installation with:
  • nvidia-smi
  • nvidia-settings

If you encounter issues:
  • Check kernel messages: dmesg | grep nvidia
  • Ensure secure boot is disabled or driver is signed
  • Rebuild kernel modules: sudo akmods --force" $GUM_SUCCESS
echo ""
