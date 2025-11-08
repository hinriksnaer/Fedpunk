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

# Optional: Claude
if [ -n "$FEDPUNK_INSTALL_CLAUDE" ]; then
    fish "$FEDPUNK_INSTALL/packaging/install-claude.fish"
fi

# Desktop components (skip on headless servers)
if [[ -z "$FEDPUNK_HEADLESS" ]]; then
    fish "$FEDPUNK_INSTALL/packaging/install-hyprland.fish"
    fish "$FEDPUNK_INSTALL/packaging/install-walker.fish"
else
    echo "→ Skipping desktop components (headless server detected)"
fi

# NVIDIA drivers (auto-detect and prompt)
if lspci | grep -i nvidia >/dev/null 2>&1; then
    echo "🎮 NVIDIA GPU detected!"
    if [[ -z "$FEDPUNK_HEADLESS" ]]; then
        # Interactive prompt for desktop installation
        read -p "Install NVIDIA proprietary drivers? [y/N]: " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            fish "$FEDPUNK_INSTALL/packaging/install-nvidia.fish"
        fi
    else
        # Auto-install on headless servers (for compute workloads)
        echo "→ Auto-installing NVIDIA drivers for headless server"
        fish "$FEDPUNK_INSTALL/packaging/install-nvidia.fish"
    fi
elif [ -n "$FEDPUNK_INSTALL_NVIDIA" ]; then
    # Force install if explicitly requested
    echo "→ Installing NVIDIA drivers (forced)"
    fish "$FEDPUNK_INSTALL/packaging/install-nvidia.fish"
fi

echo "✅ Package installation complete"
