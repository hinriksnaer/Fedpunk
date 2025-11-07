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
fish "$FEDPUNK_INSTALL/packaging/install-bluetui.fish"

# Optional: Claude
if [ -n "$FEDPUNK_INSTALL_CLAUDE" ]; then
    fish "$FEDPUNK_INSTALL/packaging/install-claude.fish"
fi

# Desktop components
fish "$FEDPUNK_INSTALL/packaging/install-hyprland.fish"
fish "$FEDPUNK_INSTALL/packaging/install-walker.fish"

# Optional: NVIDIA
if [ -n "$FEDPUNK_INSTALL_NVIDIA" ]; then
    fish "$FEDPUNK_INSTALL/packaging/install-nvidia.fish"
fi

echo "✅ Package installation complete"
