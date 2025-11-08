#!/bin/bash
# Package installation scripts
# Run all component installers

echo "→ Installing Fedpunk packages"

# Terminal components
fish "$FEDPUNK_INSTALL/packaging/install-essentials.fish"
fish "$FEDPUNK_INSTALL/packaging/install-btop.fish"
fish "$FEDPUNK_INSTALL/packaging/install-neovim.fish"
fish "$FEDPUNK_INSTALL/packaging/install-tmux.fish"
fish "$FEDPUNK_INSTALL/packaging/install-lazygit.fish"
# fish "$FEDPUNK_INSTALL/packaging/install-bluetui.fish"

# Claude installation (prompt user)
echo ""
read -p "Install Claude CLI? [y/N]: " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    fish "$FEDPUNK_INSTALL/packaging/install-claude.fish"
fi

# Desktop components 
# Check if display server is available
if [[ -z "$DISPLAY" && -z "$WAYLAND_DISPLAY" && -z "$XDG_SESSION_TYPE" ]]; then
    echo "⚠️  No display server detected (headless environment)"
    read -p "Install desktop components anyway? [y/N]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        fish "$FEDPUNK_INSTALL/packaging/install-hyprland.fish"
        fish "$FEDPUNK_INSTALL/packaging/install-walker.fish"
    else
        echo "→ Skipping desktop components"
    fi
else
    echo "→ Installing desktop components"
    fish "$FEDPUNK_INSTALL/packaging/install-hyprland.fish"
    fish "$FEDPUNK_INSTALL/packaging/install-walker.fish"
fi

# NVIDIA drivers (auto-detect and prompt)
if lspci | grep -i nvidia >/dev/null 2>&1; then
    echo "🎮 NVIDIA GPU detected!"
    read -p "Install NVIDIA proprietary drivers? [y/N]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        fish "$FEDPUNK_INSTALL/packaging/install-nvidia.fish"
    fi
fi

echo "✅ Package installation complete"
