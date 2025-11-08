# Environment variables
set -gx PATH $HOME/.local/bin $PATH
set -gx PATH $HOME/.cargo/bin $PATH
set -gx PATH $HOME/.local/share/fedpunk/bin $PATH

# History
set -g fish_history_size 10000

# Vi mode
fish_vi_key_bindings

# lsd aliases
alias ls='lsd'
alias l='ls -l'
alias la='ls -a'
alias lla='ls -la'
alias lt='ls --tree'

# fzf integration
fzf --fish | source

# Starship prompt
starship init fish | source

# Activate virtual environment (optional)
# source $HOME/.venv/bin/activate.fish

# NVIDIA Wayland support
set -gx LIBVA_DRIVER_NAME nvidia
set -gx XDG_SESSION_TYPE wayland
set -gx GBM_BACKEND nvidia-drm
set -gx __GLX_VENDOR_LIBRARY_NAME nvidia
set -gx WLR_NO_HARDWARE_CURSORS 1

# NVIDIA Wayland support
set -gx LIBVA_DRIVER_NAME nvidia
set -gx XDG_SESSION_TYPE wayland
set -gx GBM_BACKEND nvidia-drm
set -gx __GLX_VENDOR_LIBRARY_NAME nvidia
set -gx WLR_NO_HARDWARE_CURSORS 1

# NVIDIA Wayland support
set -gx LIBVA_DRIVER_NAME nvidia
set -gx XDG_SESSION_TYPE wayland
set -gx GBM_BACKEND nvidia-drm
set -gx __GLX_VENDOR_LIBRARY_NAME nvidia
set -gx WLR_NO_HARDWARE_CURSORS 1

# Default terminal for GUI applications
set -gx TERMINAL kitty

# Default terminal for GUI applications
set -gx TERMINAL kitty

# NVIDIA Wayland support
set -gx LIBVA_DRIVER_NAME nvidia
set -gx XDG_SESSION_TYPE wayland
set -gx GBM_BACKEND nvidia-drm
set -gx __GLX_VENDOR_LIBRARY_NAME nvidia
set -gx WLR_NO_HARDWARE_CURSORS 1

# Rust/Cargo
set -gx PATH $HOME/.cargo/bin $PATH

# Rust/Cargo
set -gx PATH $HOME/.cargo/bin $PATH

# Default terminal for GUI applications
set -gx TERMINAL kitty

# NVIDIA Wayland support
set -gx LIBVA_DRIVER_NAME nvidia
set -gx XDG_SESSION_TYPE wayland
set -gx GBM_BACKEND nvidia-drm
set -gx __GLX_VENDOR_LIBRARY_NAME nvidia
set -gx WLR_NO_HARDWARE_CURSORS 1

# Rust/Cargo
set -gx PATH $HOME/.cargo/bin $PATH

# NVIDIA Wayland support
set -gx LIBVA_DRIVER_NAME nvidia
set -gx XDG_SESSION_TYPE wayland
set -gx GBM_BACKEND nvidia-drm
set -gx __GLX_VENDOR_LIBRARY_NAME nvidia
set -gx WLR_NO_HARDWARE_CURSORS 1

# Rust/Cargo
set -gx PATH $HOME/.cargo/bin $PATH

# NVIDIA Wayland support
set -gx LIBVA_DRIVER_NAME nvidia
set -gx XDG_SESSION_TYPE wayland
set -gx GBM_BACKEND nvidia-drm
set -gx __GLX_VENDOR_LIBRARY_NAME nvidia
set -gx WLR_NO_HARDWARE_CURSORS 1
