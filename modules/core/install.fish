#!/usr/bin/env fish
# ============================================================================
# CORE MODULE: Essential system setup
# ============================================================================

source "$FEDPUNK_LIB_PATH/helpers.fish"

section "Core System Setup"

# Configure DNF for faster downloads
subsection "Configuring DNF"
if not grep -q "max_parallel_downloads" /etc/dnf/dnf.conf
    step "Enabling parallel downloads" \
        "echo 'max_parallel_downloads=10' | sudo tee -a /etc/dnf/dnf.conf >/dev/null"
    step "Enabling fastest mirror" \
        "echo 'fastestmirror=True' | sudo tee -a /etc/dnf/dnf.conf >/dev/null"
else
    success "DNF already configured"
end

# Install essential packages
echo ""
subsection "Installing essential packages"
install_packages fish git wget curl unzip

# Set up Fish shell
echo ""
subsection "Setting up Fish shell"
set fish_path (which fish)
if not grep -q "$fish_path" /etc/shells
    step "Adding Fish to /etc/shells" "echo $fish_path | sudo tee -a /etc/shells"
end

if test "$SHELL" != "$fish_path"
    step "Setting Fish as default shell" "sudo chsh -s $fish_path $USER"
    info "Fish shell will be active after logout/login"
else
    success "Fish is already the default shell"
end

# Install Rust/Cargo (needed for many tools)
echo ""
subsection "Installing Rust toolchain"
if not command -v cargo >/dev/null
    step "Installing Rust via rustup" \
        "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --profile minimal"
    # Add cargo to PATH for this session (fish doesn't source bash scripts)
    set -gx PATH "$HOME/.cargo/bin" $PATH
else
    success "Rust already installed"
end

# Install Starship prompt
echo ""
subsection "Installing Starship"
if not command -v starship >/dev/null
    step "Enabling Starship COPR repository" \
        "sudo dnf copr enable -qy atim/starship"
    step "Installing Starship via DNF" \
        "sudo dnf install --refresh -qy starship"
else
    success "Starship already installed"
end

# Install Gum (TUI library for scripts)
echo ""
subsection "Installing Gum"
if not command -v gum >/dev/null
    step "Installing Gum via go install" \
        "go install github.com/charmbracelet/gum@latest"

    # If go install failed, try cargo
    if not command -v gum >/dev/null
        step "Installing Gum via cargo" \
            "cargo install gum"
    end
else
    success "Gum already installed"
end

echo ""
box "Core System Setup Complete!" $GUM_SUCCESS
