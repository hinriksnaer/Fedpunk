#!/usr/bin/env bash
set -euo pipefail

echo "→ Installing NVIDIA proprietary drivers"

# Check if NVIDIA GPU is present
if ! lspci | grep -i nvidia > /dev/null; then
    echo "⚠️  No NVIDIA GPU detected. Exiting."
    exit 1
fi

echo "✓ NVIDIA GPU detected"

# Enable RPM Fusion repositories (required for NVIDIA drivers)
echo "→ Enabling RPM Fusion repositories"
sudo dnf install -y \
    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# Update package cache
sudo dnf upgrade --refresh -y

# Install NVIDIA proprietary drivers
echo "→ Installing NVIDIA proprietary drivers"
sudo dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda

# Install additional NVIDIA utilities
echo "→ Installing NVIDIA utilities"
packages=(
    nvidia-settings
    nvidia-persistenced
    cuda-drivers
)

sudo dnf install -y "${packages[@]}"

# Enable nvidia-persistenced service
echo "→ Enabling NVIDIA persistence daemon"
sudo systemctl enable nvidia-persistenced

# Check if secure boot is enabled
if bootctl status 2>/dev/null | grep -q "Secure Boot: enabled"; then
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
fi

# Create modprobe configuration for NVIDIA
echo "→ Configuring NVIDIA kernel modules"
sudo tee /etc/modprobe.d/nvidia.conf > /dev/null <<EOF
# Disable nouveau (open source NVIDIA driver)
blacklist nouveau
options nouveau modeset=0

# NVIDIA driver options
options nvidia-drm modeset=1
options nvidia NVreg_UsePageAttributeTable=1
options nvidia NVreg_InitializeSystemMemoryAllocations=0
EOF

# Add NVIDIA modules to initramfs
echo "→ Adding NVIDIA modules to initramfs"
echo 'add_drivers+=" nvidia nvidia_modeset nvidia_uvm nvidia_drm "' | sudo tee /etc/dracut.conf.d/nvidia.conf

# Regenerate initramfs
echo "→ Regenerating initramfs"
sudo dracut --force

# Check for Wayland compatibility
if [[ "${XDG_SESSION_TYPE:-}" == "wayland" ]] || command -v hyprland >/dev/null 2>&1; then
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
    if [[ -f "$(dirname "${BASH_SOURCE[0]}")/../fish/.config/fish/config.fish" ]]; then
        echo "→ Adding NVIDIA Wayland variables to fish config"
        cat >> "$(dirname "${BASH_SOURCE[0]}")/../fish/.config/fish/config.fish" << 'EOF'

# NVIDIA Wayland support
set -gx LIBVA_DRIVER_NAME nvidia
set -gx XDG_SESSION_TYPE wayland
set -gx GBM_BACKEND nvidia-drm
set -gx __GLX_VENDOR_LIBRARY_NAME nvidia
set -gx WLR_NO_HARDWARE_CURSORS 1
EOF
    fi
fi

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