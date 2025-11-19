#!/usr/bin/env fish
# ============================================================================
# HYPRLAND MODULE: Install Hyprland Wayland compositor
# ============================================================================

source "$FEDPUNK_LIB_PATH/helpers.fish"

subsection "Installing Hyprland"

# Enable COPR if needed
set -q FEDPUNK_MODULE_HYPRLAND_ENABLE_COPR; or set FEDPUNK_MODULE_HYPRLAND_ENABLE_COPR "true"

if test "$FEDPUNK_MODULE_HYPRLAND_ENABLE_COPR" = "true"
    step "Enabling Hyprland COPR" \
        "sudo dnf copr enable -qy solopasha/hyprland"
end

# Install Hyprland packages
set packages "hyprland hyprpaper hyprlock hypridle xdg-desktop-portal-hyprland"

set -q FEDPUNK_MODULE_HYPRLAND_INSTALL_EXTRAS; or set FEDPUNK_MODULE_HYPRLAND_INSTALL_EXTRAS "true"
if test "$FEDPUNK_MODULE_HYPRLAND_INSTALL_EXTRAS" = "true"
    set packages $packages "waybar polkit-gnome"
end

step "Installing Hyprland packages" \
    "sudo dnf install --refresh -qy --skip-broken --best $packages"

# Install Wayland dependencies
echo ""
subsection "Installing Wayland dependencies"
set wayland_deps "wayland-protocols-devel wlroots wl-clipboard cliphist grim slurp"
step "Installing Wayland tools" \
    "sudo dnf install --refresh -qy --skip-unavailable --best $wayland_deps"

step "Installing Qt6 Wayland support" \
    "sudo dnf install --allowerasing --refresh -qy --skip-unavailable qt6-qtwayland"

# Update graphics stack
echo ""
step "Updating graphics stack" \
    "sudo dnf update -qy mesa-* --refresh"

success "Hyprland installed"
