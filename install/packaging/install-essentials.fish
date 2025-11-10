#!/usr/bin/env fish
# Essential development environment
# Installs all core dev tools, languages, and modern CLI utilities

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

# Core development tools and utilities
info "Installing core development tools"
set core_tools \
  git \
  firefox \
  fzf \
  unzip \
  tar \
  gcc \
  gcc-c++ \
  make \
  cmake \
  pkg-config \
  openssl-devel

step "Installing core tools" "sudo dnf install -qy --skip-broken $core_tools"

# Modern CLI tools (via DNF or cargo fallback)
echo ""
info "Installing modern CLI utilities"

# Starship prompt
gum spin --spinner dot --title "Installing Starship prompt..." -- fish -c '
    sudo dnf copr enable -qy atim/starship >>'"$FEDPUNK_LOG_FILE"' 2>&1
    sudo dnf install -qy starship >>'"$FEDPUNK_LOG_FILE"' 2>&1
' && success "Starship prompt installed" || warning "Starship installation failed"

# lsd (modern ls)
if not command -v lsd >/dev/null 2>&1
    if step "Installing lsd" "sudo dnf install -qy lsd"
        # Success
    else
        if step "Installing lsd via cargo" "cargo install lsd"
            # Success
        end
    end
else
    success "lsd already installed"
end

# Other modern CLI tools
set modern_tools ripgrep fd-find bat exa

for tool in $modern_tools
    if not command -v $tool >/dev/null 2>&1
        if step "Installing $tool" "sudo dnf install -qy $tool"
            # Success
        else
            if step "Installing $tool via cargo" "cargo install $tool"
                # Success
            end
        end
    else
        success "$tool already installed"
    end
end

# Programming languages and runtimes
echo ""
info "Installing programming languages"

# Rust and Cargo
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

# Python, Node.js, Go
set language_tools \
  python3-devel \
  python3-pip \
  nodejs \
  npm \
  golang

step "Installing Python, Node.js, and Go" "sudo dnf install -qy --skip-broken $language_tools"

# Fish shell enhancements
echo ""
info "Setting up Fish shell enhancements"

# Install Fisher (fish plugin manager)
if not test -f ~/.config/fish/functions/fisher.fish
    gum spin --spinner dot --title "Installing Fisher plugin manager..." -- fish -c '
        curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher >>'"$FEDPUNK_LOG_FILE"' 2>&1
    ' && success "Fisher plugin manager installed" || warning "Fisher installation failed"
else
    success "Fisher already installed"
end

# Install fzf.fish plugin
if not fish -c "fisher list" 2>/dev/null | grep -q "fzf.fish"
    gum spin --spinner dot --title "Installing fzf.fish plugin..." -- \
        fish -c "fisher install PatrickF1/fzf.fish >>$FEDPUNK_LOG_FILE 2>&1" && \
        success "fzf.fish plugin installed" || \
        warning "fzf.fish installation failed"
else
    success "fzf.fish already installed"
end

# Reload fish config to pick up starship and fzf for the current session
echo ""
info "Reloading Fish configuration"
if test -f ~/.config/fish/config.fish
    source ~/.config/fish/config.fish 2>/dev/null; and success "Fish config reloaded" || info "Fish config will be active on next shell restart"
end

echo ""
box "Essential Development Environment Installed!

Installed packages:
  🐟 Fish shell - Modern shell with intelligent features
  ⭐ Starship - Fast, customizable prompt
  📁 lsd, exa - Modern ls replacements
  🔍 ripgrep, fd - Fast search tools
  🦇 bat - Better cat with syntax highlighting
  🦀 Rust & Cargo - Rust toolchain and package manager
  🔨 GCC/G++/Make - C/C++ compiler toolchain
  🐍 Python3 & pip - Python development
  📦 Node.js & npm - JavaScript development
  🐹 Go - Go programming language
  🎣 Fisher - Fish plugin manager
  🔎 fzf.fish - Fuzzy finder integration
  🦊 Firefox - Web browser" $GUM_SUCCESS
echo ""
