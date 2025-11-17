#!/usr/bin/env fish
# Rofi - Application launcher and window switcher
# End-to-end setup: install package → deploy config

# Source helper functions
if not set -q FEDPUNK_PATH
    set -gx FEDPUNK_PATH "$HOME/.local/share/fedpunk"
end
if not set -q FEDPUNK_INSTALL
    set -gx FEDPUNK_INSTALL "$FEDPUNK_PATH/install"
end
if test -f "$FEDPUNK_INSTALL/helpers/all.fish"
    source "$FEDPUNK_INSTALL/helpers/all.fish"
end

echo ""
info "Setting up Rofi launcher"

# Install rofi
step "Installing rofi" "sudo dnf install -qy rofi"

# Verify installation
if not command -v rofi >/dev/null 2>&1
    error "Rofi installation failed"
    exit 1
end

success "Rofi installed: "(which rofi)

# Configuration will be deployed by chezmoi at end of installation
info "Rofi config prepared (will be deployed with chezmoi)"

success "Rofi setup complete"

echo ""
info "Rofi Usage Notes:"
echo "  • Use rofi as app launcher: rofi -show drun"
echo "  • Window switcher: rofi -show window"
echo "  • Run commands: rofi -show run"
echo "  • Config location: ~/.config/rofi/config.rasi"
echo ""
