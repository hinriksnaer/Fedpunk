#!/usr/bin/env fish

echo "→ Installing NVIDIA proprietary drivers"

# Check if NVIDIA GPU is present
if not lspci | grep -i nvidia >/dev/null
    echo "⚠️  No NVIDIA GPU detected. Exiting."
    exit 1
end

echo "✓ NVIDIA GPU detected"

# Enable RPM Fusion repositories (required for NVIDIA drivers)
echo "→ Enabling RPM Fusion repositories"
set fedora_version (rpm -E %fedora)
sudo dnf install -y \
    "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$fedora_version.noarch.rpm" \
    "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$fedora_version.noarch.rpm"

# Update package cache
sudo dnf upgrade --refresh -y

# Install NVIDIA proprietary drivers
echo "→ Installing NVIDIA proprietary drivers"
sudo dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda

# Install additional NVIDIA utilities
echo "→ Installing NVIDIA utilities"
set packages \
    nvidia-settings \
    nvidia-persistenced \
    cuda-drivers

sudo dnf install -y $packages

# Enable nvidia-persistenced service
echo "→ Enabling NVIDIA persistence daemon"
sudo systemctl enable nvidia-persistenced

# Check if secure boot is enabled
if bootctl status 2>/dev/null | grep -q "Secure Boot: enabled"
    echo ""
    echo "⚠️  SECURE BOOT DETECTED"
    echo "   The NVIDIA driver kernel module needs to be signed for secure boot."
    echo "   You have two options:"
    echo ""
    echo "   Option 1 (Recommended): Disable Secure Boot in BIOS/UEFI"
    echo "   Option 2: Sign the kernel module manually after reboot"
    echo ""
    echo "   For Option 2, after reboot run:"
    echo "   sudo /usr/src/kernels/\$(uname -r)/scripts/sign-file sha256 \\"
    echo "        /var/lib/shim-signed/mok/MOK.priv \\"
    echo "        /var/lib/shim-signed/mok/MOK.der \\"
    echo "        /lib/modules/\$(uname -r)/extra/nvidia/nvidia.ko"
    echo ""
end

# Create modprobe configuration for NVIDIA
echo "→ Configuring NVIDIA kernel modules"
printf "%s\n" \
    "# Disable nouveau (open source NVIDIA driver)" \
    "blacklist nouveau" \
    "options nouveau modeset=0" \
    "" \
    "# NVIDIA driver options" \
    "options nvidia-drm modeset=1" \
    "options nvidia NVreg_UsePageAttributeTable=1" \
    "options nvidia NVreg_InitializeSystemMemoryAllocations=0" | sudo tee /etc/modprobe.d/nvidia.conf >/dev/null

# Add NVIDIA modules to initramfs
echo "→ Adding NVIDIA modules to initramfs"
echo 'add_drivers+=" nvidia nvidia_modeset nvidia_uvm nvidia_drm "' | sudo tee /etc/dracut.conf.d/nvidia.conf >/dev/null

# Regenerate initramfs
echo "→ Regenerating initramfs"
sudo dracut --force

cd (dirname (status -f))/../

# Check for Wayland compatibility
if test "$XDG_SESSION_TYPE" = "wayland"; or command -v hyprland >/dev/null 2>&1
    echo ""
    echo "ℹ️  WAYLAND COMPATIBILITY"
    echo "   For Wayland compositors (including Hyprland), ensure these environment variables:"
    echo "   export LIBVA_DRIVER_NAME=nvidia"
    echo "   export XDG_SESSION_TYPE=wayland"
    echo "   export GBM_BACKEND=nvidia-drm"
    echo "   export __GLX_VENDOR_LIBRARY_NAME=nvidia"
    echo ""
    echo "   These will be added to your shell configuration."
    
    # Add Wayland NVIDIA environment variables to fish config
    if test -f "fish/.config/fish/config.fish"
        echo "→ Adding NVIDIA Wayland variables to fish config"
        printf "%s\n" \
            "" \
            "# NVIDIA Wayland support" \
            "set -gx LIBVA_DRIVER_NAME nvidia" \
            "set -gx XDG_SESSION_TYPE wayland" \
            "set -gx GBM_BACKEND nvidia-drm" \
            "set -gx __GLX_VENDOR_LIBRARY_NAME nvidia" \
            "set -gx WLR_NO_HARDWARE_CURSORS 1" >> fish/.config/fish/config.fish
    end
end

echo ""
echo "✓ NVIDIA driver installation complete!"
echo ""
echo "IMPORTANT: You must reboot for the drivers to take effect."
echo ""
echo "After reboot, verify installation with:"
echo "  nvidia-smi"
echo "  nvidia-settings"
echo ""
echo "If you encounter issues:"
echo "  - Check 'dmesg | grep nvidia' for kernel messages"
echo "  - Ensure secure boot is disabled or driver is properly signed"
echo "  - Run 'sudo akmods --force' to rebuild kernel modules"