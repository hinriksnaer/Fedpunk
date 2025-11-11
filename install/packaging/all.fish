#!/usr/bin/env fish
# Package installation - Pure package installs (no configs to stow)
# These components don't have configuration directories

# Source helper functions
source "$FEDPUNK_INSTALL/helpers/all.fish"

section "Installing Packages"

# Fonts (needed early for terminal/desktop)
echo ""
info "Installing fonts"
fish "$FEDPUNK_INSTALL/packaging/fonts.fish"

# Audio stack
echo ""
info "Installing audio stack"
fish "$FEDPUNK_INSTALL/packaging/audio.fish"

# bluetui (Bluetooth TUI)
echo ""
info "Installing bluetui"
fish "$FEDPUNK_INSTALL/packaging/bluetui.fish"

# Claude installation (prompt user)
echo ""
if confirm "Install Claude CLI?"
    fish "$FEDPUNK_INSTALL/packaging/claude.fish"
else
    info "Skipping Claude CLI installation"
    echo "[SKIPPED] Claude CLI installation declined by user" >> $FEDPUNK_LOG_FILE
end

# NVIDIA drivers (if GPU detected)
echo ""
if lspci | grep -i nvidia >/dev/null 2>&1
    info "NVIDIA GPU detected"
    if confirm "Install NVIDIA proprietary drivers?"
        fish "$FEDPUNK_INSTALL/packaging/nvidia.fish"
    else
        info "Skipping NVIDIA drivers"
        echo "[SKIPPED] NVIDIA drivers (user declined)" >> $FEDPUNK_LOG_FILE
    end
else
    info "No NVIDIA GPU detected, skipping drivers"
    echo "[SKIPPED] NVIDIA drivers (no GPU detected)" >> $FEDPUNK_LOG_FILE
end

echo ""
box "Package Installation Complete!" $GUM_SUCCESS
