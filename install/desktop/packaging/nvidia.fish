#!/usr/bin/env fish
# NVIDIA - Proprietary drivers with Wayland support
# Pure package installation (no config to stow)

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
# Enhanced progress for repository setup
info "Setting up RPM Fusion repositories for NVIDIA drivers"
gum spin --spinner line --title "Downloading and installing RPM Fusion repositories..." -- fish -c '
    sudo dnf install -qy https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-'$fedora_version'.noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-'$fedora_version'.noarch.rpm >>'"$FEDPUNK_LOG_FILE"' 2>&1
' && success "RPM Fusion repositories installed successfully" || warning "RPM Fusion repositories may already be installed"

# Install NVIDIA proprietary drivers
echo ""
info "Installing NVIDIA drivers (this will take several minutes)"
echo ""
info "📦 Downloading NVIDIA proprietary driver packages..."
info "🔧 This includes the kernel module, CUDA runtime, and X11 driver"
info "⏳ Please be patient - driver compilation can take 5-10 minutes"
echo ""
gum spin --spinner meter --title "Downloading and installing NVIDIA driver packages..." -- fish -c '
    sudo dnf install -qy akmod-nvidia xorg-x11-drv-nvidia-cuda >>'"$FEDPUNK_LOG_FILE"' 2>&1
'
if test $status -eq 0
    success "NVIDIA driver packages installed successfully"
    echo ""
    info "🔨 Checking kernel module compilation status..."
    info "💡 The NVIDIA kernel module may still be compiling in the background"
    
    # Wait for akmods to potentially finish compilation
    gum spin --spinner dot --title "Waiting for NVIDIA kernel module compilation..." -- fish -c '
        # Give akmods a moment to start if needed
        sleep 2
        
        # Check if akmods is running
        if pgrep -f "akmods.*nvidia" >/dev/null 2>&1
            # Wait for it to finish, but with a timeout
            timeout 300 bash -c "while pgrep -f \"akmods.*nvidia\" >/dev/null 2>&1; do sleep 2; done" >>'"$FEDPUNK_LOG_FILE"' 2>&1
        end
    ' && success "NVIDIA kernel module compilation completed" || info "Kernel module compilation may continue in background"
else
    error "Failed to install NVIDIA drivers"
end

# Install additional NVIDIA utilities
echo ""
info "Installing NVIDIA utilities and support packages"
set packages \
    nvidia-settings \
    nvidia-persistenced \
    cuda-drivers \
    libva \
    libva-nvidia-driver

info "📊 Installing: nvidia-settings, CUDA drivers, VA-API support..."
gum spin --spinner dot --title "Installing NVIDIA utilities and support packages..." -- fish -c '
    sudo dnf install -qy '$packages' >>'"$FEDPUNK_LOG_FILE"' 2>&1
' && success "NVIDIA utilities installed successfully" || warning "Some NVIDIA utilities may already be installed"

# Enable nvidia-persistenced service
echo ""
info "Configuring NVIDIA system services"
gum spin --spinner dot --title "Enabling NVIDIA persistence daemon..." -- fish -c '
    sudo systemctl enable nvidia-persistenced >>'"$FEDPUNK_LOG_FILE"' 2>&1
' && success "NVIDIA persistence daemon enabled" || warning "Failed to enable NVIDIA persistence daemon"

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
        "options nvidia-drm modeset=1 fbdev=1" \
        "options nvidia NVreg_UsePageAttributeTable=1" \
        "options nvidia NVreg_InitializeSystemMemoryAllocations=0" | sudo tee /etc/modprobe.d/nvidia.conf >/dev/null >>'"$FEDPUNK_LOG_FILE"' 2>&1
' && success "NVIDIA modprobe configured"

# Add NVIDIA modules to initramfs
gum spin --spinner dot --title "Adding NVIDIA modules to initramfs..." -- fish -c '
    echo '\''add_drivers+=" nvidia nvidia_modeset nvidia_uvm nvidia_drm "'\'' | sudo tee /etc/dracut.conf.d/nvidia.conf >/dev/null >>'"$FEDPUNK_LOG_FILE"' 2>&1
' && success "NVIDIA modules added to initramfs"

# Regenerate initramfs
echo ""
info "Regenerating initramfs with NVIDIA modules"
echo ""
info "🔄 Rebuilding initial RAM filesystem..."
info "📦 Including NVIDIA kernel modules for boot-time loading"
info "⏳ This process typically takes 1-2 minutes"
echo ""
gum spin --spinner pulse --title "Regenerating initramfs with NVIDIA drivers..." -- fish -c '
    sudo dracut --force >>'"$FEDPUNK_LOG_FILE"' 2>&1
' && success "Initramfs regenerated successfully with NVIDIA support" || error "Failed to regenerate initramfs"

# Check for Wayland compatibility
if test "$XDG_SESSION_TYPE" = "wayland"; or command -v hyprland >/dev/null 2>&1
    echo ""
    info "Configuring Wayland compatibility"

    # Add Wayland NVIDIA environment variables to installer-managed config
    set installer_config "$HOME/.config/fish/conf.d/installer-managed.fish"
    mkdir -p (dirname "$installer_config")

    gum spin --spinner dot --title "Adding NVIDIA Wayland variables to fish config..." -- fish -c '
        set config "'$installer_config'"

        # Create file if it doesn'\''t exist
        if not test -f "$config"
            printf "# Auto-managed by Fedpunk installer - DO NOT EDIT\n" > "$config"
            printf "# This file is regenerated on installation\n\n" >> "$config"
        end

        # Add NVIDIA config if not present
        if not grep -q "NVIDIA Wayland support" "$config" 2>/dev/null
            printf "\n# NVIDIA Wayland support\n" >> "$config"
            printf "set -gx LIBVA_DRIVER_NAME nvidia\n" >> "$config"
            printf "set -gx XDG_SESSION_TYPE wayland\n" >> "$config"
            printf "set -gx GBM_BACKEND nvidia-drm\n" >> "$config"
            printf "set -gx __GLX_VENDOR_LIBRARY_NAME nvidia\n" >> "$config"
            printf "set -gx WLR_NO_HARDWARE_CURSORS 1\n" >> "$config"
        end
    ' >>$FEDPUNK_LOG_FILE 2>&1 && success "NVIDIA Wayland variables configured"

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
