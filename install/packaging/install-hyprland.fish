#!/usr/bin/env fish

# Source helper functions
# Don't override FEDPUNK_INSTALL if it's already set
if not set -q FEDPUNK_INSTALL
    set -gx FEDPUNK_INSTALL "$HOME/.local/share/fedpunk/install"
end
if test -f "$FEDPUNK_INSTALL/helpers/all.fish"
    source "$FEDPUNK_INSTALL/helpers/all.fish"
end

# Get target directory (either /root or /home/USER)
set TARGET_DIR (test (id -u) -eq 0; and echo "/root"; or echo "/home/"(whoami))

info "Installing Hyprland and dependencies"

# Enable COPR repositories for Hyprland and nwg-displays
step "Enabling Hyprland COPR" "sudo dnf copr enable -y solopasha/hyprland"
step "Enabling nwg-shell COPR" "sudo dnf copr enable -y tofik/nwg-shell"

# Core Hyprland packages
set packages \
  hyprland \
  hyprpaper \
  dunst \
  wofi \
  grim \
  slurp \
  wl-clipboard \
  thunar \
  pavucontrol \
  playerctl \
  wpctl \
  hyprpolkitagent \
  nwg-displays \
  xdg-desktop-portal-hyprland \
  xdg-desktop-portal-gtk \
  gvfs \
  gvfs-mtp \
  xdg-user-dirs \
  xdg-utils \
  pipewire-alsa \
  pipewire-utils \
  network-manager-applet \
  policycoreutils \
  kitty \
  swaybg

step "Installing Hyprland packages" "sudo dnf install -qy $packages"

# Fix potential SELinux issues
info "Setting up user directories"
step "Updating user directories" "xdg-user-dirs-update"

# Ensure SELinux contexts are correct for new files
if command -v restorecon >/dev/null 2>&1
    step "Fixing SELinux contexts" "sudo restorecon -R /home/(whoami)/.config /home/(whoami)/.local"
end

# Install additional dependencies that may be missing
info "Installing additional Wayland dependencies"
set wayland_deps \
  wlr-randr \
  wlogout \
  xorg-x11-server-Xwayland \
  qt5-qtwayland \
  mesa-dri-drivers \
  wayland-devel \
  libwayland-client \
  libwayland-cursor \
  libwayland-egl \
  glfw-devel

# Skip qt6-qtwayland due to version conflict and use --skip-unavailable for safety
step "Installing Wayland dependencies" "sudo dnf install -qy --skip-unavailable --best $wayland_deps"

# Ensure graphics drivers are up to date
step "Updating graphics stack" "sudo dnf upgrade -qy --skip-unavailable mesa* libdrm*"