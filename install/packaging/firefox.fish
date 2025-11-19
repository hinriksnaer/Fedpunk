#!/usr/bin/env fish
# Firefox - Web browser
# Refreshes package metadata before install to ensure latest version

# Source helper functions
source "$FEDPUNK_INSTALL/helpers/all.fish"

if rpm -q firefox >/dev/null 2>&1
    success "Firefox already installed"
else
    step "Refreshing package metadata" "$SUDO_CMD dnf makecache --refresh -q"
    step "Installing Firefox" "$SUDO_CMD dnf install -qy --skip-broken --best firefox"
end
