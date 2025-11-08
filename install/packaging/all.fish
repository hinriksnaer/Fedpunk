#!/usr/bin/env fish
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
read -P "Install Claude CLI? [y/N]: " -n 1 claude_response
echo
if string match -qir '^y' -- $claude_response
    fish "$FEDPUNK_INSTALL/packaging/install-claude.fish"
end

# Desktop components
# Check if display server is available
if test -z "$DISPLAY" -a -z "$WAYLAND_DISPLAY" -a -z "$XDG_SESSION_TYPE"
    echo "⚠️  No display server detected (headless environment)"
    read -P "Install desktop components anyway? [y/N]: " -n 1 desktop_response
    echo
    if string match -qir '^y' -- $desktop_response
        fish "$FEDPUNK_INSTALL/packaging/install-hyprland.fish"
        fish "$FEDPUNK_INSTALL/packaging/install-walker.fish"
    else
        echo "→ Skipping desktop components"
    end
else
    echo "→ Installing desktop components"
    fish "$FEDPUNK_INSTALL/packaging/install-hyprland.fish"
    fish "$FEDPUNK_INSTALL/packaging/install-walker.fish"
end

# NVIDIA drivers (auto-detect and prompt)
if lspci | grep -i nvidia >/dev/null 2>&1
    echo "🎮 NVIDIA GPU detected!"
    read -P "Install NVIDIA proprietary drivers? [y/N]: " -n 1 nvidia_response
    echo
    if string match -qir '^y' -- $nvidia_response
        fish "$FEDPUNK_INSTALL/packaging/install-nvidia.fish"
    end
end

echo "✅ Package installation complete"
