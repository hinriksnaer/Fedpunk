#!/usr/bin/env fish
# Desktop Package Installation
# Install packages for desktop components

# Source helper functions
source "$FEDPUNK_INSTALL/helpers/all.fish"

# Firefox browser
echo ""
step "Installing Firefox" "sudo dnf install -qy firefox"

# Fonts (needed for desktop)
echo ""
info "Installing fonts"
fish "$FEDPUNK_INSTALL/desktop/packaging/fonts.fish"

# Audio stack
echo ""
info "Installing audio stack"
fish "$FEDPUNK_INSTALL/desktop/packaging/audio.fish"

# bluetui (Bluetooth TUI)
echo ""
info "Installing bluetui"
fish "$FEDPUNK_INSTALL/desktop/packaging/bluetui.fish"

# NVIDIA drivers (if GPU detected)
echo ""
if lspci | grep -i nvidia >/dev/null 2>&1
    info "NVIDIA GPU detected"
    if confirm "Install NVIDIA proprietary drivers?"
        fish "$FEDPUNK_INSTALL/desktop/packaging/nvidia.fish"
    else
        info "Skipping NVIDIA drivers"
        echo "[SKIPPED] NVIDIA drivers (user declined)" >> $FEDPUNK_LOG_FILE
    end
else
    info "No NVIDIA GPU detected, skipping drivers"
    echo "[SKIPPED] NVIDIA drivers (no GPU detected)" >> $FEDPUNK_LOG_FILE
end
