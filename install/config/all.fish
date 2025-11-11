#!/usr/bin/env fish
# Configuration deployment - Components with configs to stow
# Each script does end-to-end: install package → deploy config

# Source helper functions
source "$FEDPUNK_INSTALL/helpers/all.fish"

section "Deploying Configuration"

# Terminal components
echo ""
info "Setting up terminal components"

fish "$FEDPUNK_INSTALL/config/btop.fish"
fish "$FEDPUNK_INSTALL/config/neovim.fish"
fish "$FEDPUNK_INSTALL/config/tmux.fish"
fish "$FEDPUNK_INSTALL/config/lazygit.fish"

# Desktop components (if display server available)
echo ""
if test -z "$DISPLAY" -a -z "$WAYLAND_DISPLAY" -a -z "$XDG_SESSION_TYPE"
    warning "No display server detected (headless environment)"
    if confirm "Install desktop components anyway?"
        info "Setting up desktop components"
        fish "$FEDPUNK_INSTALL/config/kitty.fish"
        fish "$FEDPUNK_INSTALL/config/hyprland.fish"
        fish "$FEDPUNK_INSTALL/config/walker.fish"
    else
        info "Skipping desktop components"
        echo "[SKIPPED] Desktop components (user declined)" >> $FEDPUNK_LOG_FILE
    end
else
    info "Setting up desktop components"
    fish "$FEDPUNK_INSTALL/config/kitty.fish"
    fish "$FEDPUNK_INSTALL/config/hyprland.fish"
    fish "$FEDPUNK_INSTALL/config/walker.fish"
end

# Link bin directory
echo ""
info "Linking bin scripts"
cd "$FEDPUNK_PATH"
run_quiet "Creating bin directory" mkdir -p $HOME/.local/bin
run_quiet "Linking bin scripts" stow --restow -d $FEDPUNK_PATH -t $HOME/.local bin

echo ""
box "Configuration Deployment Complete!" $GUM_SUCCESS
