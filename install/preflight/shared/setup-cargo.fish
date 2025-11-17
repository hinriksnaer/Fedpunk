#!/usr/bin/env fish
# Cargo/Rust Setup - ABSOLUTE FIRST PREFLIGHT STEP
# This must run before anything else as many tools depend on cargo
# Note: Assumes gum is already installed by boot.sh

# FEDPUNK_PATH and FEDPUNK_INSTALL should be set by parent install.fish
# Source helper functions
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

    # Add cargo to PATH for current session (Fish-compatible way)
    set -gx PATH $HOME/.cargo/bin $PATH

    # Add to installer-managed config (never committed to git)
    set installer_config "$HOME/.config/fish/conf.d/installer-managed.fish"
    mkdir -p (dirname "$installer_config")

    # Create/update the installer-managed config with Rust PATH
    if test -f "$installer_config"
        # Update existing file - add Rust if not present
        if not grep -q "Rust/Cargo" "$installer_config" 2>/dev/null
            printf "\n# Rust/Cargo\nfish_add_path -g \$HOME/.cargo/bin\n" >> "$installer_config"
        end
    else
        # Create new file
        printf "# Auto-managed by Fedpunk installer - DO NOT EDIT\n" > "$installer_config"
        printf "# This file is regenerated on installation\n\n" >> "$installer_config"
        printf "# Rust/Cargo\nfish_add_path -g \$HOME/.cargo/bin\n" >> "$installer_config"
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

# Install mold linker for faster cargo builds
info "Installing mold linker (speeds up Rust compilation significantly)"
if not command -v mold >/dev/null 2>&1
    step "Installing mold and clang" "sudo dnf install -qy mold clang"
else
    success "mold already installed: "(mold --version | head -n1)
end

# Deploy cargo config for build optimizations
info "Setting up cargo build optimizations"
set cargo_config_dir "$FEDPUNK_PATH/.cargo"
set cargo_config "$cargo_config_dir/config.toml"

if not test -f "$cargo_config"
    mkdir -p "$cargo_config_dir"
    cat > "$cargo_config" << 'EOF'
# Cargo configuration for faster builds
# This speeds up all cargo install commands in fedpunk

[build]
# Use all CPU cores for parallel compilation
jobs = 8

[target.x86_64-unknown-linux-gnu]
# Use mold linker (much faster than default ld)
linker = "clang"
rustflags = ["-C", "link-arg=-fuse-ld=mold"]

[registries.crates-io]
# Use sparse registry protocol (faster than git)
protocol = "sparse"

[profile.dev]
# Skip optimization for faster dev builds
opt-level = 0
debug = true

# But optimize dependencies (good balance)
[profile.dev.package."*"]
opt-level = 2

[profile.release]
# Full optimizations for release builds
opt-level = 3
lto = "thin"
codegen-units = 1
EOF
    success "Cargo config created with build optimizations"
else
    success "Cargo config already exists"
end

echo ""
box "Rust/Cargo Setup Complete!

Rust toolchain is now available:
  🦀 rustc - Rust compiler
  📦 cargo - Rust package manager
  🔧 rustup - Rust toolchain manager
  ⚡ mold - Fast linker (3-5x faster builds)

Build optimizations enabled:
  • Parallel compilation with all CPU cores
  • Mold linker for faster linking
  • Sparse registry for faster dependency resolution

This enables installation of modern CLI tools built with Rust." $GUM_SUCCESS
echo ""
