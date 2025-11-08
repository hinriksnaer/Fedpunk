#!/usr/bin/env fish

# Get target directory (either /root or /home/USER)
set TARGET_DIR (test (id -u) -eq 0; and echo "/root"; or echo "/home/"(whoami))

cd (dirname (status -f))/../

echo "→ Installing Hyprland and dependencies"

# Enable COPR repositories for Hyprland and nwg-displays
sudo dnf copr enable -y solopasha/hyprland
sudo dnf copr enable -y tofik/nwg-shell

sudo dnf upgrade --refresh -qy

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

sudo dnf install -qy $packages

# Fix potential SELinux issues
echo "→ Setting up user directories and fixing SELinux contexts"
xdg-user-dirs-update

# Ensure SELinux contexts are correct for new files
if command -v restorecon >/dev/null 2>&1
    sudo restorecon -R /home/(whoami)/.config 2>/dev/null || true
    sudo restorecon -R /home/(whoami)/.local 2>/dev/null || true
end

# Install additional dependencies that may be missing
echo "→ Installing additional Wayland dependencies"
set wayland_deps \
  wlr-randr \
  wlogout \
  xwayland \
  qt5-qtwayland \
  qt6-qtwayland \
  mesa-dri-drivers \
  wayland-devel \
  libwayland-client \
  libwayland-cursor \
  libwayland-egl \
  glfw-devel

sudo dnf install -qy $wayland_deps 2>/dev/null || true

# Ensure graphics drivers are up to date
echo "→ Ensuring graphics stack is current"
sudo dnf upgrade -qy mesa* libdrm* 2>/dev/null || true

echo "✓ Hyprland installed"