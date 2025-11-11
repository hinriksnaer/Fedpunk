#!/usr/bin/env fish
# Cargo/Rust Setup - ABSOLUTE FIRST PREFLIGHT STEP
# This must run before anything else as many tools depend on cargo
# Note: Assumes gum is already installed by boot.sh

# Source helper functions if available
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
section "Rust/Cargo Setup"
info "Installing Rust toolchain (required for Fedpunk installation)"

if not command -v rustc >/dev/null 2>&1
    gum spin --spinner dot --title "Installing Rust toolchain..." -- fish -c '
        curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable --no-modify-path >>'"$FEDPUNK_LOG_FILE"' 2>&1
    '

    # Source cargo env for current session
    source $HOME/.cargo/env

    # Add to installer-managed config (never committed to git)
    set installer_config "$HOME/.config/fish/conf.d/installer-managed.fish"
    mkdir -p (dirname "$installer_config")

    # Create/update the installer-managed config with Rust PATH
    if test -f "$installer_config"
        # Update existing file - add Rust if not present
        if not grep -q "Rust/Cargo" "$installer_config" 2>/dev/null
            printf "\n# Rust/Cargo\nset -gx PATH \$HOME/.cargo/bin \$PATH\n" >> "$installer_config"
        end
    else
        # Create new file
        printf "# Auto-managed by Fedpunk installer - DO NOT EDIT\n" > "$installer_config"
        printf "# This file is regenerated on installation\n\n" >> "$installer_config"
        printf "# Rust/Cargo\nset -gx PATH \$HOME/.cargo/bin \$PATH\n" >> "$installer_config"
    end

    success "Rust toolchain installed"
else
    success "Rust already installed: "(rustc --version)

    # Ensure cargo is in PATH for current session
    set -gx PATH $HOME/.cargo/bin $PATH
end

# Update Rust to latest stable
if step "Updating Rust to latest stable" "rustup update stable"
    # Success
end

echo ""
box "Rust/Cargo Setup Complete!

Rust toolchain is now available:
  🦀 rustc - Rust compiler
  📦 cargo - Rust package manager
  🔧 rustup - Rust toolchain manager

This enables installation of modern CLI tools built with Rust." $GUM_SUCCESS
echo ""
