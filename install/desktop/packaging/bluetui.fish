#!/usr/bin/env fish
# bluetui - Bluetooth TUI manager
# Pure package installation (configs managed by chezmoi)

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
info "Installing bluetui"

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
