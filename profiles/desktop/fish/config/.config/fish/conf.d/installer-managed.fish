# Auto-managed by Fedpunk
# Runtime detection of cargo and NVIDIA

# Rust/Cargo PATH
if test -d $HOME/.cargo/bin
    fish_add_path -g $HOME/.cargo/bin
end

# NVIDIA Wayland support (runtime detection)
if command -v nvidia-smi >/dev/null 2>&1; or test -f /proc/driver/nvidia/version
    set -gx LIBVA_DRIVER_NAME nvidia
    set -gx XDG_SESSION_TYPE wayland
    set -gx GBM_BACKEND nvidia-drm
    set -gx __GLX_VENDOR_LIBRARY_NAME nvidia
    set -gx WLR_NO_HARDWARE_CURSORS 1
end
