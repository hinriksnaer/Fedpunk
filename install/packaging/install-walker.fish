#!/usr/bin/env fish

# Source helper functions
# Don't override FEDPUNK_INSTALL if it's already set
if not set -q FEDPUNK_INSTALL
    set -gx FEDPUNK_INSTALL "$HOME/.local/share/fedpunk/install"
end
if test -f "$FEDPUNK_INSTALL/helpers/all.fish"
    source "$FEDPUNK_INSTALL/helpers/all.fish"
end

# Get target directory (either /root or /home/USER)
set TARGET_DIR (test (id -u) -eq 0; and echo "/root"; or echo "/home/"(whoami))

cd $FEDPUNK_PATH

info "Installing Walker launcher and Elephant service"

# Enable copr repository
step "Enabling COPR repository" "sudo dnf copr enable -y washkinazy/wayland-wm-extras"

# Install walker and elephant from copr
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

step "Deploying Walker configuration" "stow -d config -t $TARGET_DIR walker"

info "Enabling and starting Elephant systemd service"

# First enable the service in elephant's config
gum spin --spinner dot --title "Configuring Elephant service..." -- fish -c '
    elephant service enable >>'"$FEDPUNK_LOG_FILE"' 2>&1
' && success "Elephant service configured"

# IMPORTANT: Reload systemd daemon to pick up the new service file
step "Reloading systemd daemon" "systemctl --user daemon-reload"

# Enable and start the systemd service
gum spin --spinner dot --title "Enabling Elephant service..." -- fish -c '
    systemctl --user enable elephant >>'"$FEDPUNK_LOG_FILE"' 2>&1
' && success "Elephant service enabled"

gum spin --spinner dot --title "Starting Elephant service..." -- fish -c '
    systemctl --user start elephant >>'"$FEDPUNK_LOG_FILE"' 2>&1
'

# Give it a moment to start
sleep 1

# Verify the service is running
if systemctl --user is-active --quiet elephant
    success "Elephant service is running"
else
    warning "Elephant service failed to start, attempting restart..."
    step "Reloading systemd daemon again" "systemctl --user daemon-reload"
    gum spin --spinner dot --title "Restarting Elephant service..." -- fish -c '
        systemctl --user restart elephant >>'"$FEDPUNK_LOG_FILE"' 2>&1
    '
    sleep 1
    if systemctl --user is-active --quiet elephant
        success "Elephant service is now running"
    else
        error "Failed to start Elephant service"
        info "Check status with: systemctl --user status elephant"
        info "Try manually: systemctl --user daemon-reload && systemctl --user start elephant"
        exit 1
    end
end

echo ""
box "Walker and Elephant Installed!

Services configured:
  ✓ Elephant service enabled and started
  ✓ Elephant will auto-start on login

Usage:
  • Launch Walker: walker
  • Or press Super+R in Hyprland

Configuration:
  • Walker config: ~/.config/walker/config.toml
  • Walker theme: ~/.config/walker/style.css

Service management:
  • Check status: systemctl --user status elephant
  • Restart: systemctl --user restart elephant
  • Disable: elephant service disable" $GUM_SUCCESS
echo ""
