#!/usr/bin/env fish
# Hyprland - Wayland compositor with dependencies
# Includes Hyprpaper, Hyprlock, Hypridle, Waybar, and Wayland tools

# Source helper functions
source "$FEDPUNK_INSTALL/helpers/all.fish"

section "Hyprland & Wayland Environment"

# Enable Hyprland COPR
step "Enabling Hyprland COPR" "$SUDO_CMD dnf copr enable -qy solopasha/hyprland"

# Install core Hyprland packages
set packages "hyprland hyprpaper hyprlock hypridle xdg-desktop-portal-hyprland waybar polkit-gnome"
step "Installing Hyprland packages" "$SUDO_CMD dnf install --refresh -qy --skip-broken --best $packages"

# Install Wayland dependencies
set wayland_deps "wayland-protocols-devel wlroots wl-clipboard cliphist grim slurp"
step "Installing Wayland dependencies" "$SUDO_CMD dnf install --refresh -qy --skip-unavailable --best $wayland_deps"

# Install Qt6 Wayland support
step "Installing Qt6 Wayland support" "$SUDO_CMD dnf install --allowerasing --refresh -qy --skip-unavailable qt6-qtwayland"

# Update graphics stack
step "Updating graphics stack" "$SUDO_CMD dnf update -qy mesa-* --refresh"

# Update user directories
if command -v xdg-user-dirs-update >/dev/null 2>&1
    step "Updating user directories" "xdg-user-dirs-update"
end

# Fix SELinux contexts if config directory exists
if test -d "$HOME/.config"
    step "Fixing SELinux contexts" "sudo restorecon -Rv $HOME/.config"
end

# Enable mako notification service (will fail gracefully if not installed yet)
if systemctl --user list-unit-files | grep -q mako
    step "Enabling mako notification service" "systemctl --user enable --now mako"
end
