#!/usr/bin/env fish
# Walker - Application launcher with Elephant service
# End-to-end setup: install package → deploy config → enable service

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
info "Setting up Walker launcher and Elephant service"

# Enable COPR repository
step "Enabling COPR repository" "sudo dnf copr enable -y washkinazy/wayland-wm-extras"

# Install walker and elephant
step "Installing walker and elephant" "sudo dnf install -qy walker elephant"

# Verify installation
if not command -v walker >/dev/null 2>&1
    error "Walker installation failed"
    exit 1
end

if not command -v elephant >/dev/null 2>&1
    error "Elephant installation failed"
    exit 1
end

success "Walker installed: "(which walker)
success "Elephant installed: "(which elephant)

# Deploy configuration
cd "$FEDPUNK_PATH"
run_quiet "Deploying Walker config" stow --restow -d config -t ~ walker

# Configure Elephant service
gum spin --spinner dot --title "Configuring Elephant service..." -- fish -c "
    elephant service enable >>$FEDPUNK_LOG_FILE 2>&1
" && success "Elephant service configured"

# Reload systemd daemon
step "Reloading systemd daemon" "systemctl --user daemon-reload"

# Enable and start the service
gum spin --spinner dot --title "Enabling Elephant service..." -- fish -c "
    systemctl --user enable elephant >>$FEDPUNK_LOG_FILE 2>&1
" && success "Elephant service enabled"

gum spin --spinner dot --title "Starting Elephant service..." -- fish -c "
    systemctl --user start elephant >>$FEDPUNK_LOG_FILE 2>&1
"

sleep 1

# Verify service
if systemctl --user is-active --quiet elephant
    success "Elephant service is running"
else
    warning "Elephant service failed to start, attempting restart..."
    step "Reloading systemd daemon again" "systemctl --user daemon-reload"

    gum spin --spinner dot --title "Restarting Elephant service..." -- fish -c "
        systemctl --user restart elephant >>$FEDPUNK_LOG_FILE 2>&1
    "

    sleep 1

    if systemctl --user is-active --quiet elephant
        success "Elephant service is now running"
    else
        error "Failed to start Elephant service"
        info "Check status with: systemctl --user status elephant"
    end
end

success "Walker setup complete"

echo ""
info "Walker Usage Notes:"
echo "  • Use Super+Space to launch Walker (recommended)"
echo "  • Running 'walker' from terminal may have Wayland display issues"
echo "  • Fallback: Use 'wofi --show drun' if Walker has issues"
echo ""
