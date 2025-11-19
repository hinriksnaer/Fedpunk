#!/usr/bin/env fish
# ============================================================================
# PREFLIGHT: System preparation (all modes)
# ============================================================================
# Purpose:
#   - Configure DNF for faster downloads
#   - Install essential packages (fish, git, curl, gum, cargo)
# Runs: Always (all modes)
# ============================================================================

source "$FEDPUNK_PROFILE_PATH/lib/helpers.fish"

section "System Preflight"

# Configure DNF
subsection "Configuring DNF"
if not grep -q "max_parallel_downloads" /etc/dnf/dnf.conf
    echo "max_parallel_downloads=10" | sudo tee -a /etc/dnf/dnf.conf >/dev/null
    echo "fastestmirror=True" | sudo tee -a /etc/dnf/dnf.conf >/dev/null
    success "DNF configured for faster downloads"
else
    success "DNF already configured"
end

# Install essentials
subsection "Installing essential packages"
install_packages git curl wget unzip fish

# Setup Cargo
subsection "Setting up Rust/Cargo"
if not command -v cargo >/dev/null
    step "Installing Rust" "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y"
    set -Ux fish_user_paths $HOME/.cargo/bin $fish_user_paths
else
    success "Cargo already installed"
end

# Install starship (prompt)
subsection "Installing starship"
if not command -v starship >/dev/null
    step "Enabling Starship COPR" "sudo dnf copr enable -qy atim/starship"
    step "Installing starship" "sudo dnf install --refresh -qy starship"
else
    success "starship already installed"
end

# Install gum (UI library)
subsection "Installing gum"
if not command -v gum >/dev/null
    step "Installing gum via cargo" "cargo install gum"
else
    success "gum already installed"
end

echo ""
box "Preflight Complete!" $GUM_SUCCESS
