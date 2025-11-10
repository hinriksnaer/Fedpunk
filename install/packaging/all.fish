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
        fish "$FEDPUNK_INSTALL/packaging/install-nvidia.fish"
        echo ""
    end
end

# Terminal components
echo ""
info "Installing terminal components"
echo ""

set current_component (math $current_component + 1)
progress $current_component $total_components "Essential development tools"
fish "$FEDPUNK_INSTALL/packaging/install-essentials.fish"

set current_component (math $current_component + 1)
progress $current_component $total_components "Fonts"
fish "$FEDPUNK_INSTALL/packaging/install-fonts.fish"

set current_component (math $current_component + 1)
progress $current_component $total_components "btop"
fish "$FEDPUNK_INSTALL/packaging/install-btop.fish"

set current_component (math $current_component + 1)
progress $current_component $total_components "Neovim"
fish "$FEDPUNK_INSTALL/packaging/install-neovim.fish"

set current_component (math $current_component + 1)
progress $current_component $total_components "tmux"
fish "$FEDPUNK_INSTALL/packaging/install-tmux.fish"

set current_component (math $current_component + 1)
progress $current_component $total_components "lazygit"
fish "$FEDPUNK_INSTALL/packaging/install-lazygit.fish"

set current_component (math $current_component + 1)
progress $current_component $total_components "bluetui"
fish "$FEDPUNK_INSTALL/packaging/install-bluetui.fish"

# Audio stack
echo ""
set current_component (math $current_component + 1)
progress $current_component $total_components "Audio stack"
fish "$FEDPUNK_INSTALL/packaging/install-audio.fish"

# Claude installation (prompt user)
echo ""
if confirm "Install Claude CLI?"
    progress "+" $total_components "Claude CLI"
    fish "$FEDPUNK_INSTALL/packaging/install-claude.fish"
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
        fish "$FEDPUNK_INSTALL/packaging/install-hyprland.fish"
        progress "+" $total_components "Walker"
        fish "$FEDPUNK_INSTALL/packaging/install-walker.fish"
    else
        info "Skipping desktop components"
    end
else
    echo ""
    info "Installing desktop components"
    echo ""
    progress "+" $total_components "Hyprland"
    fish "$FEDPUNK_INSTALL/packaging/install-hyprland.fish"
    progress "+" $total_components "Walker"
    fish "$FEDPUNK_INSTALL/packaging/install-walker.fish"
end

echo ""
box "Package Installation Complete!" $GUM_SUCCESS
