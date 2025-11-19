#!/usr/bin/env fish
# Package Installation
# Install all packages (terminal and desktop components) based on mode configuration

# Source helper functions
source "$FEDPUNK_INSTALL/helpers/all.fish"

section "Package Installation"

# ================================
# Terminal Tools
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

# tmux - Terminal multiplexer
install_if_enabled "FEDPUNK_INSTALL_TMUX" \
    "Install tmux?" \
    "$FEDPUNK_INSTALL/packaging/tmux.fish" \
    "yes"

# btop - System monitor
install_if_enabled "FEDPUNK_INSTALL_BTOP" \
    "Install btop?" \
    "$FEDPUNK_INSTALL/packaging/btop.fish" \
    "yes"

# Neovim - Text editor
install_if_enabled "FEDPUNK_INSTALL_NEOVIM" \
    "Install Neovim?" \
    "$FEDPUNK_INSTALL/packaging/neovim.fish" \
    "yes"

# lazygit - Git TUI
install_if_enabled "FEDPUNK_INSTALL_LAZYGIT" \
    "Install lazygit?" \
    "$FEDPUNK_INSTALL/packaging/lazygit.fish" \
    "yes"

# ================================
# Desktop Packages
# ================================

# Firefox browser
install_if_enabled "FEDPUNK_INSTALL_FIREFOX" \
    "Install Firefox web browser?" \
    "$FEDPUNK_INSTALL/packaging/firefox.fish" \
    "yes"

# Fonts
install_if_enabled "FEDPUNK_INSTALL_FONTS" \
    "Install fonts?" \
    "$FEDPUNK_INSTALL/packaging/fonts.fish" \
    "yes"

# Audio stack
install_if_enabled "FEDPUNK_INSTALL_AUDIO" \
    "Install audio stack?" \
    "$FEDPUNK_INSTALL/packaging/audio.fish" \
    "yes"

# Multimedia codecs
install_if_enabled "FEDPUNK_INSTALL_MULTIMEDIA" \
    "Install multimedia codecs?" \
    "$FEDPUNK_INSTALL/packaging/multimedia.fish" \
    "yes"

# Bluetooth support
install_if_enabled "FEDPUNK_INSTALL_BLUETOOTH" \
    "Install Bluetooth support?" \
    "$FEDPUNK_INSTALL/packaging/bluetui.fish" \
    "yes"

# NVIDIA drivers (detect GPU)
echo ""
set gpu_type (detect_gpu)
if test "$gpu_type" = "nvidia"
    info "NVIDIA GPU detected"
    if confirm "Install NVIDIA proprietary drivers?" "yes"
        source "$FEDPUNK_INSTALL/packaging/nvidia.fish"
    else
        info "Skipping NVIDIA drivers"
        echo "[SKIPPED] NVIDIA drivers (user declined)" >> $FEDPUNK_LOG_FILE
    end
else
    info "No NVIDIA GPU detected, skipping drivers"
    echo "[SKIPPED] NVIDIA drivers (GPU type: $gpu_type)" >> $FEDPUNK_LOG_FILE
end

# Extra applications
install_if_enabled "FEDPUNK_INSTALL_EXTRA_APPS" \
    "Install extra applications (Discord, Spotify, etc.)?" \
    "$FEDPUNK_INSTALL/packaging/extra-apps.fish" \
    "yes"

# ================================
# Desktop Environment
# ================================

# Kitty - Terminal emulator
install_if_enabled "FEDPUNK_INSTALL_KITTY" \
    "Install Kitty terminal?" \
    "$FEDPUNK_INSTALL/packaging/kitty.fish" \
    "yes"

# Hyprland - Wayland compositor
install_if_enabled "FEDPUNK_INSTALL_HYPRLAND" \
    "Install Hyprland?" \
    "$FEDPUNK_INSTALL/packaging/hyprland.fish" \
    "yes"

# Rofi - Application launcher
install_if_enabled "FEDPUNK_INSTALL_ROFI" \
    "Install Rofi?" \
    "$FEDPUNK_INSTALL/packaging/rofi.fish" \
    "yes"

echo ""
box "Package Installation Complete!" $GUM_SUCCESS
