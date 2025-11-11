#!/usr/bin/env fish
# Package installation scripts
# Run all component installers

# Source helper functions
source "$FEDPUNK_INSTALL/helpers/all.fish"

section "Installing Packages"

# Count total components for progress indicator
set total_components 8
set current_component 0

# NVIDIA drivers (install early if detected, before other components)
if lspci | grep -i nvidia >/dev/null 2>&1
    echo ""
    info "NVIDIA GPU detected - installing drivers first"
    if confirm "Install NVIDIA proprietary drivers?"
        progress "!" $total_components "NVIDIA drivers"
        echo "" >> $FEDPUNK_LOG_FILE
        echo "[INSTALLER] Running: install-nvidia.fish" >> $FEDPUNK_LOG_FILE
        fish "$FEDPUNK_INSTALL/packaging/install-nvidia.fish"
        echo ""
    else
        echo "" >> $FEDPUNK_LOG_FILE
        echo "[SKIPPED] NVIDIA drivers (user declined)" >> $FEDPUNK_LOG_FILE
    end
else
    echo "" >> $FEDPUNK_LOG_FILE
    echo "[SKIPPED] NVIDIA drivers (no NVIDIA GPU detected)" >> $FEDPUNK_LOG_FILE
end

# Terminal components
echo ""
info "Installing terminal components"
echo ""

set current_component (math $current_component + 1)
progress $current_component $total_components "Fonts"
echo "" >> $FEDPUNK_LOG_FILE
echo "[INSTALLER] Running: install-fonts.fish" >> $FEDPUNK_LOG_FILE
fish "$FEDPUNK_INSTALL/packaging/install-fonts.fish"

set current_component (math $current_component + 1)
progress $current_component $total_components "btop"
echo "" >> $FEDPUNK_LOG_FILE
echo "[INSTALLER] Running: install-btop.fish" >> $FEDPUNK_LOG_FILE
fish "$FEDPUNK_INSTALL/packaging/install-btop.fish"

set current_component (math $current_component + 1)
progress $current_component $total_components "Neovim"
echo "" >> $FEDPUNK_LOG_FILE
echo "[INSTALLER] Running: install-neovim.fish" >> $FEDPUNK_LOG_FILE
fish "$FEDPUNK_INSTALL/packaging/install-neovim.fish"

set current_component (math $current_component + 1)
progress $current_component $total_components "tmux"
echo "" >> $FEDPUNK_LOG_FILE
echo "[INSTALLER] Running: install-tmux.fish" >> $FEDPUNK_LOG_FILE
fish "$FEDPUNK_INSTALL/packaging/install-tmux.fish"

set current_component (math $current_component + 1)
progress $current_component $total_components "lazygit"
echo "" >> $FEDPUNK_LOG_FILE
echo "[INSTALLER] Running: install-lazygit.fish" >> $FEDPUNK_LOG_FILE
fish "$FEDPUNK_INSTALL/packaging/install-lazygit.fish"

set current_component (math $current_component + 1)
progress $current_component $total_components "bluetui"
echo "" >> $FEDPUNK_LOG_FILE
echo "[INSTALLER] Running: install-bluetui.fish" >> $FEDPUNK_LOG_FILE
fish "$FEDPUNK_INSTALL/packaging/install-bluetui.fish"

# Audio stack
echo ""
set current_component (math $current_component + 1)
progress $current_component $total_components "Audio stack"
echo "" >> $FEDPUNK_LOG_FILE
echo "[INSTALLER] Running: install-audio.fish" >> $FEDPUNK_LOG_FILE
fish "$FEDPUNK_INSTALL/packaging/install-audio.fish"

# Claude installation (prompt user)
echo ""
if confirm "Install Claude CLI?"
    progress "+" $total_components "Claude CLI"
    echo "" >> $FEDPUNK_LOG_FILE
    echo "[INSTALLER] Running: install-claude.fish" >> $FEDPUNK_LOG_FILE
    fish "$FEDPUNK_INSTALL/packaging/install-claude.fish"
else
    echo "" >> $FEDPUNK_LOG_FILE
    echo "[SKIPPED] Claude CLI installation declined by user" >> $FEDPUNK_LOG_FILE
end

# Desktop components
# Check if display server is available
echo ""
if test -z "$DISPLAY" -a -z "$WAYLAND_DISPLAY" -a -z "$XDG_SESSION_TYPE"
    warning "No display server detected (headless environment)"
    if confirm "Install desktop components anyway?"
        echo ""
        info "Installing desktop components"
        echo ""
        progress "+" $total_components "Hyprland"
        echo "" >> $FEDPUNK_LOG_FILE
        echo "[INSTALLER] Running: install-hyprland.fish" >> $FEDPUNK_LOG_FILE
        fish "$FEDPUNK_INSTALL/packaging/install-hyprland.fish"
        progress "+" $total_components "Walker"
        echo "" >> $FEDPUNK_LOG_FILE
        echo "[INSTALLER] Running: install-walker.fish" >> $FEDPUNK_LOG_FILE
        fish "$FEDPUNK_INSTALL/packaging/install-walker.fish"
    else
        info "Skipping desktop components"
        echo "" >> $FEDPUNK_LOG_FILE
        echo "[SKIPPED] Desktop components (user declined)" >> $FEDPUNK_LOG_FILE
    end
else
    echo ""
    info "Installing desktop components"
    echo ""
    progress "+" $total_components "Hyprland"
    echo "" >> $FEDPUNK_LOG_FILE
    echo "[INSTALLER] Running: install-hyprland.fish" >> $FEDPUNK_LOG_FILE
    fish "$FEDPUNK_INSTALL/packaging/install-hyprland.fish"
    progress "+" $total_components "Walker"
    echo "" >> $FEDPUNK_LOG_FILE
    echo "[INSTALLER] Running: install-walker.fish" >> $FEDPUNK_LOG_FILE
    fish "$FEDPUNK_INSTALL/packaging/install-walker.fish"
end

echo ""
box "Package Installation Complete!" $GUM_SUCCESS
