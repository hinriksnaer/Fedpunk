#!/usr/bin/env fish
# Package Installation
# Install all packages (terminal and desktop components)

# Source helper functions
source "$FEDPUNK_INSTALL/helpers/all.fish"

# ================================
# Terminal Packages
# ================================

# Yazi file manager
install_if_enabled "FEDPUNK_INSTALL_YAZI" \
    "Install Yazi file manager?" \
    "$FEDPUNK_INSTALL/packaging/yazi.fish" \
    "yes"

# Claude CLI
install_if_enabled "FEDPUNK_INSTALL_CLAUDE" \
    "Install Claude CLI?" \
    "$FEDPUNK_INSTALL/packaging/claude.fish" \
    "yes"

# GitHub CLI
install_if_enabled "FEDPUNK_INSTALL_GH" \
    "Install GitHub CLI (gh)?" \
    "$FEDPUNK_INSTALL/packaging/gh.fish" \
    "yes"

# ================================
# Terminal Configuration Tools
# ================================

# tmux - Terminal multiplexer
if test "$FEDPUNK_INSTALL_TMUX" = "true"
    echo ""
    info "Installing tmux"
    step "Installing tmux package" "$SUDO_CMD dnf install -qy tmux"
else
    info "Skipping tmux installation"
    echo "[SKIPPED] tmux installation (FEDPUNK_INSTALL_TMUX=false)" >> $FEDPUNK_LOG_FILE
end

# btop - System monitor
if test "$FEDPUNK_INSTALL_BTOP" = "true"
    echo ""
    info "Installing btop"
    step "Installing btop package" "$SUDO_CMD dnf install -qy btop"
else
    info "Skipping btop installation"
    echo "[SKIPPED] btop installation (FEDPUNK_INSTALL_BTOP=false)" >> $FEDPUNK_LOG_FILE
end

# Neovim - Text editor
if test "$FEDPUNK_INSTALL_NEOVIM" = "true"
    echo ""
    info "Installing Neovim"
    step "Installing Neovim" "$SUDO_CMD dnf install -qy neovim"
else
    info "Skipping Neovim installation"
    echo "[SKIPPED] Neovim installation (FEDPUNK_INSTALL_NEOVIM=false)" >> $FEDPUNK_LOG_FILE
end

# lazygit - Git TUI
if test "$FEDPUNK_INSTALL_LAZYGIT" = "true"
    echo ""
    info "Installing lazygit"
    step "Enabling lazygit COPR" "$SUDO_CMD dnf install -qy dnf-plugins-core && $SUDO_CMD dnf copr enable -qy atim/lazygit"
    step "Installing lazygit" "$SUDO_CMD dnf install --refresh -qy lazygit"
else
    info "Skipping lazygit installation"
    echo "[SKIPPED] lazygit installation (FEDPUNK_INSTALL_LAZYGIT=false)" >> $FEDPUNK_LOG_FILE
end

# ================================
# Desktop Packages
# ================================

# Firefox browser
if not set -q FEDPUNK_INSTALL_FIREFOX
    if confirm "Install Firefox web browser?" "yes"
        set -gx FEDPUNK_INSTALL_FIREFOX true
    else
        set -gx FEDPUNK_INSTALL_FIREFOX false
    end
end

if test "$FEDPUNK_INSTALL_FIREFOX" = "true"
    echo ""
    info "Installing Firefox web browser"
    gum spin --spinner dot --title "Refreshing package metadata..." -- fish -c '
        $SUDO_CMD dnf makecache --refresh -q >>'"$FEDPUNK_LOG_FILE"' 2>&1
    ' && success "Package metadata refreshed" || warning "Could not refresh metadata"

    gum spin --spinner dot --title "Installing Firefox..." -- fish -c '
        $SUDO_CMD dnf install -qy --skip-broken --best firefox >>'"$FEDPUNK_LOG_FILE"' 2>&1
    ' && success "Firefox installed" || error "Firefox installation failed"
else
    info "Skipping Firefox installation"
    echo "[SKIPPED] Firefox installation (FEDPUNK_INSTALL_FIREFOX=false)" >> $FEDPUNK_LOG_FILE
end

# Fonts
if not set -q FEDPUNK_INSTALL_FONTS
    if confirm "Install fonts?" "yes"
        set -gx FEDPUNK_INSTALL_FONTS true
    else
        set -gx FEDPUNK_INSTALL_FONTS false
    end
end

if test "$FEDPUNK_INSTALL_FONTS" = "true"
    echo ""
    info "Installing fonts"
    source "$FEDPUNK_INSTALL/packaging/fonts.fish"
else
    info "Skipping fonts installation"
    echo "[SKIPPED] Fonts installation (FEDPUNK_INSTALL_FONTS=false)" >> $FEDPUNK_LOG_FILE
end

# Audio stack
if not set -q FEDPUNK_INSTALL_AUDIO
    if confirm "Install audio stack?" "yes"
        set -gx FEDPUNK_INSTALL_AUDIO true
    else
        set -gx FEDPUNK_INSTALL_AUDIO false
    end
end

if test "$FEDPUNK_INSTALL_AUDIO" = "true"
    echo ""
    info "Installing audio stack"
    source "$FEDPUNK_INSTALL/packaging/audio.fish"
else
    info "Skipping audio stack installation"
    echo "[SKIPPED] Audio stack installation (FEDPUNK_INSTALL_AUDIO=false)" >> $FEDPUNK_LOG_FILE
end

# Multimedia codecs and hardware acceleration
if not set -q FEDPUNK_INSTALL_MULTIMEDIA
    if confirm "Install multimedia codecs?" "yes"
        set -gx FEDPUNK_INSTALL_MULTIMEDIA true
    else
        set -gx FEDPUNK_INSTALL_MULTIMEDIA false
    end
end

if test "$FEDPUNK_INSTALL_MULTIMEDIA" = "true"
    echo ""
    info "Installing multimedia codecs"
    source "$FEDPUNK_INSTALL/packaging/multimedia.fish"
else
    info "Skipping multimedia codecs installation"
    echo "[SKIPPED] Multimedia codecs installation (FEDPUNK_INSTALL_MULTIMEDIA=false)" >> $FEDPUNK_LOG_FILE
end

# bluetui (Bluetooth TUI)
if not set -q FEDPUNK_INSTALL_BLUETOOTH
    if confirm "Install Bluetooth support?" "yes"
        set -gx FEDPUNK_INSTALL_BLUETOOTH true
    else
        set -gx FEDPUNK_INSTALL_BLUETOOTH false
    end
end

if test "$FEDPUNK_INSTALL_BLUETOOTH" = "true"
    echo ""
    info "Installing bluetui"
    source "$FEDPUNK_INSTALL/packaging/bluetui.fish"
else
    info "Skipping Bluetooth support installation"
    echo "[SKIPPED] Bluetooth support installation (FEDPUNK_INSTALL_BLUETOOTH=false)" >> $FEDPUNK_LOG_FILE
end

# NVIDIA drivers (if GPU detected)
echo ""
if lspci | grep -i nvidia >/dev/null 2>&1
    info "NVIDIA GPU detected"
    if confirm "Install NVIDIA proprietary drivers?"
        source "$FEDPUNK_INSTALL/packaging/nvidia.fish"
    else
        info "Skipping NVIDIA drivers"
        echo "[SKIPPED] NVIDIA drivers (user declined)" >> $FEDPUNK_LOG_FILE
    end
else
    info "No NVIDIA GPU detected, skipping drivers"
    echo "[SKIPPED] NVIDIA drivers (no GPU detected)" >> $FEDPUNK_LOG_FILE
end

# Extra applications
if not set -q FEDPUNK_INSTALL_EXTRA_APPS
    if confirm "Install extra applications (Discord, Spotify, etc.)?" "yes"
        set -gx FEDPUNK_INSTALL_EXTRA_APPS true
    else
        set -gx FEDPUNK_INSTALL_EXTRA_APPS false
    end
end

if test "$FEDPUNK_INSTALL_EXTRA_APPS" = "true"
    echo ""
    info "Installing extra applications"
    source "$FEDPUNK_INSTALL/packaging/extra-apps.fish"
else
    info "Skipping extra applications"
    echo "[SKIPPED] Extra applications (FEDPUNK_INSTALL_EXTRA_APPS=false)" >> $FEDPUNK_LOG_FILE
end

# ================================
# Desktop Environment
# ================================

# Kitty - Terminal emulator
if test "$FEDPUNK_INSTALL_KITTY" = "true"
    echo ""
    info "Installing Kitty"
    step "Installing kitty" "$SUDO_CMD dnf install -qy kitty"
else
    info "Skipping Kitty installation"
    echo "[SKIPPED] Kitty installation (FEDPUNK_INSTALL_KITTY=false)" >> $FEDPUNK_LOG_FILE
end

# Hyprland - Wayland compositor
if test "$FEDPUNK_INSTALL_HYPRLAND" = "true"
    echo ""
    info "Installing Hyprland and dependencies"

    # Enable Hyprland COPR
    step "Enabling Hyprland COPR" "$SUDO_CMD dnf copr enable -qy solopasha/hyprland"

    # Install Hyprland packages
    set packages "hyprland hyprpaper hyprlock hypridle xdg-desktop-portal-hyprland waybar polkit-gnome"
    step "Installing Hyprland packages" "$SUDO_CMD dnf install --refresh -qy --skip-broken --best $packages"

    # Install Wayland dependencies
    set wayland_deps "wayland-protocols-devel wlroots wl-clipboard cliphist grim slurp"
    step "Installing Wayland dependencies" "$SUDO_CMD dnf install --refresh -qy --skip-unavailable --best $wayland_deps"

    # Install Qt6 Wayland support
    set qt6_packages "qt6-qtwayland"
    step "Installing Qt6 Wayland support" "$SUDO_CMD dnf install --allowerasing --refresh -qy --skip-unavailable $qt6_packages"

    # Update graphics stack
    step "Updating graphics stack" "$SUDO_CMD dnf update -qy mesa-* --refresh"

    # Update user directories
    step "Updating user directories" "xdg-user-dirs-update"

    # Fix SELinux contexts
    step "Fixing SELinux contexts" "sudo restorecon -Rv $HOME/.config"

    # Enable mako notification service
    step "Enabling mako notification service" "systemctl --user enable --now mako"
else
    info "Skipping Hyprland installation"
    echo "[SKIPPED] Hyprland installation (FEDPUNK_INSTALL_HYPRLAND=false)" >> $FEDPUNK_LOG_FILE
end

# Rofi - Application launcher
if test "$FEDPUNK_INSTALL_ROFI" = "true"
    echo ""
    info "Installing Rofi"
    step "Installing rofi" "$SUDO_CMD dnf install -qy rofi"
else
    info "Skipping Rofi installation"
    echo "[SKIPPED] Rofi installation (FEDPUNK_INSTALL_ROFI=false)" >> $FEDPUNK_LOG_FILE
end
