#!/usr/bin/env fish
# Essential development environment
# Installs all core dev tools, languages, and modern CLI utilities

# FEDPUNK_PATH and FEDPUNK_INSTALL should be set by parent install.fish
# Source helper functions
if test -f "$FEDPUNK_INSTALL/helpers/all.fish"
    source "$FEDPUNK_INSTALL/helpers/all.fish"
end

# Core development tools and utilities
info "Installing core development tools"
set core_tools \
  git \
  fzf \
  unzip \
  tar \
  gcc \
  gcc-c++ \
  make \
  cmake \
  pkg-config \
  openssl-devel

# Show detailed progress for core tools installation
info "Installing essential development tools: $core_tools"
gum spin --spinner meter --title "Downloading and installing core development tools..." -- fish -c '
    sudo dnf install -qy --skip-broken '$core_tools' >>'"$FEDPUNK_LOG_FILE"' 2>&1
' && success "Core development tools installed successfully" || warning "Some development tools may already be installed"

# Note: Rust/Cargo is now installed in setup-cargo.fish (runs before this script)
# Ensure cargo is in PATH for current session
set -gx PATH $HOME/.cargo/bin $PATH

# Modern CLI tools (via DNF or cargo fallback)
# Note: Starship, Fisher, and fzf.fish are now installed in setup-fish.fish
echo ""
info "Installing modern CLI utilities"

# lsd (modern ls)
if not command -v lsd >/dev/null 2>&1
    gum spin --spinner dot --title "Installing lsd (modern ls replacement)..." -- fish -c '
        sudo dnf install -qy lsd >>'"$FEDPUNK_LOG_FILE"' 2>&1
    '
    if test $status -eq 0
        success "lsd installed successfully"
    else
        info "DNF installation failed, trying cargo..."
        gum spin --spinner dot --title "Building lsd from source via cargo..." -- fish -c '
            cargo install lsd >>'"$FEDPUNK_LOG_FILE"' 2>&1
        '
        if test $status -eq 0
            success "lsd installed via cargo"
        else
            warning "Failed to install lsd"
        end
    end
else
    success "lsd already installed"
end

# Other modern CLI tools
set modern_tools ripgrep fd-find bat

for tool in $modern_tools
    if not command -v $tool >/dev/null 2>&1
        gum spin --spinner dot --title "Installing $tool..." -- fish -c '
            sudo dnf install -qy '$tool' >>'"$FEDPUNK_LOG_FILE"' 2>&1
        '
        if test $status -eq 0
            success "$tool installed successfully"
        else
            info "DNF installation of $tool failed, trying cargo..."
            gum spin --spinner dot --title "Building $tool from source via cargo..." -- fish -c '
                cargo install '$tool' >>'"$FEDPUNK_LOG_FILE"' 2>&1
            '
            if test $status -eq 0
                success "$tool installed via cargo"
            else
                warning "Failed to install $tool"
            end
        end
    else
        success "$tool already installed"
    end
end

# Other programming languages and runtimes
echo ""
info "Installing Python, Node.js, and Go"

# Python, Node.js, Go
set language_tools \
  python3-devel \
  python3-pip \
  nodejs \
  npm \
  golang

# Show progress for programming language runtimes
info "Installing programming language runtimes: $language_tools"
gum spin --spinner line --title "Downloading and installing Python, Node.js, and Go..." -- fish -c '
    sudo dnf install -qy --skip-broken '$language_tools' >>'"$FEDPUNK_LOG_FILE"' 2>&1
' && success "Programming language runtimes installed successfully" || warning "Some language runtimes may already be installed"

echo ""
box "Essential Development Environment Installed!

Installed packages:
  📁 lsd - Modern ls replacement
  🔍 ripgrep, fd - Fast search tools
  🦇 bat - Better cat with syntax highlighting
  🔨 GCC/G++/Make - C/C++ compiler toolchain
  🐍 Python3 & pip - Python development
  📦 Node.js & npm - JavaScript development
  🐹 Go - Go programming language

Note: Rust/Cargo and Fish shell enhancements were installed in earlier preflight steps" $GUM_SUCCESS
echo ""
