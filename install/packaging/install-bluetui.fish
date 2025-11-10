#!/usr/bin/env fish
# Install bluetui - Bluetooth TUI manager

# Source helper functions
# Don't override FEDPUNK_INSTALL if it's already set
if not set -q FEDPUNK_INSTALL
    set -gx FEDPUNK_INSTALL "$HOME/.local/share/fedpunk/install"
end
if test -f "$FEDPUNK_INSTALL/helpers/all.fish"
    source "$FEDPUNK_INSTALL/helpers/all.fish"
end

# Check if cargo is installed
if not command -v cargo >/dev/null 2>&1
    error "Cargo not found! Please install Rust first"
    info "Run: curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
    exit 1
end

# Check if bluetui is already installed
if command -v bluetui >/dev/null 2>&1
    success "bluetui already installed: "(bluetui --version)
    exit 0
end

# Install bluetui dependencies
info "Installing bluetui dependencies"
step "Installing dbus-devel" "sudo dnf install -qy dbus-devel"

# Install bluetui
step "Installing bluetui with cargo" "cargo install bluetui"
