#!/usr/bin/env fish
# Essential development environment
# Installs all core dev tools, languages, and modern CLI utilities

# Source helper functions
# Don't override if already set
if not set -q FEDPUNK_PATH
    set -gx FEDPUNK_PATH "$HOME/.local/share/fedpunk"
end

if not set -q FEDPUNK_INSTALL
    set -gx FEDPUNK_INSTALL "$FEDPUNK_PATH/install"
end

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

step "Installing core tools" "sudo dnf install -qy --skip-broken $core_tools"

# Note: Rust/Cargo is now installed in setup-cargo.fish (runs before this script)
# Ensure cargo is in PATH for current session
set -gx PATH $HOME/.cargo/bin $PATH

# Modern CLI tools (via DNF or cargo fallback)
# Note: Starship, Fisher, and fzf.fish are now installed in setup-fish.fish
echo ""
info "Installing modern CLI utilities"

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
set modern_tools ripgrep fd-find bat

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

step "Installing Python, Node.js, and Go" "sudo dnf install -qy --skip-broken $language_tools"

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
