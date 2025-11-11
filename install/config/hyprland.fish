#!/usr/bin/env fish
# Hyprland - Wayland tiling compositor
# End-to-end setup: install packages → deploy config

# Source helper functions
if not set -q FEDPUNK_INSTALL
    set -gx FEDPUNK_INSTALL "$HOME/.local/share/fedpunk/install"
end
if not set -q FEDPUNK_PATH
    set -gx FEDPUNK_PATH "$HOME/.local/share/fedpunk"
end
if test -f "$FEDPUNK_INSTALL/helpers/all.fish"
    source "$FEDPUNK_INSTALL/helpers/all.fish"
end

echo ""
info "Setting up Hyprland and dependencies"

# Enable COPR repositories
gum spin --spinner dot --title "Enabling Hyprland COPR..." -- fish -c '
    echo y | sudo dnf copr enable solopasha/hyprland >>'"$FEDPUNK_LOG_FILE"' 2>&1
' && success "Hyprland COPR enabled" || warning "Hyprland COPR may already be enabled"

gum spin --spinner dot --title "Enabling nwg-shell COPR..." -- fish -c '
    echo y | sudo dnf copr enable tofik/nwg-shell >>'"$FEDPUNK_LOG_FILE"' 2>&1
' && success "nwg-shell COPR enabled" || warning "nwg-shell COPR may already be enabled"

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

step "Installing Hyprland packages" "sudo dnf install -qy --skip-broken --best $packages"

# Additional Wayland dependencies
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

step "Installing Wayland dependencies" "sudo dnf install -qy --skip-unavailable --best $wayland_deps"

# Update graphics stack
step "Updating graphics stack" "sudo dnf upgrade -qy --skip-unavailable mesa-dri-drivers mesa-libGL mesa-libEGL libdrm || true"

# Setup user directories
step "Updating user directories" "xdg-user-dirs-update"

# Fix SELinux contexts
if command -v restorecon >/dev/null 2>&1
    step "Fixing SELinux contexts" "sudo restorecon -R /home/(whoami)/.config /home/(whoami)/.local"
end

# Deploy configuration
cd "$FEDPUNK_PATH"
run_quiet "Deploying Hyprland config" stow --restow -d config -t ~ hyprland

success "Hyprland setup complete"
