#!/usr/bin/env fish

# Essential utilities and development tools
# Run this before other installers that depend on these tools

echo "🔧 Installing Essential Utilities"
echo "=================================="

# Get target directory (either /root or /home/USER)
set TARGET_DIR (test (id -u) -eq 0; and echo "/root"; or echo "/home/"(whoami))

cd (dirname (status -f))/../

# Core development tools
echo "→ Installing core development tools"
set core_tools \
  git \
  curl \
  wget \
  unzip \
  tar \
  gcc \
  gcc-c++ \
  make \
  cmake \
  pkg-config \
  openssl-devel

sudo dnf install -qy $core_tools

# Rust and Cargo
echo "→ Installing Rust toolchain"
if not command -v rustc >/dev/null 2>&1
    echo "  • Installing rustup and cargo"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable

    # Source cargo env for current session
    source $HOME/.cargo/env

    # Add to fish config if not already there
    if not grep -q "cargo/env" ~/.config/fish/config.fish 2>/dev/null
        echo "" >> ~/.config/fish/config.fish
        echo "# Rust/Cargo" >> ~/.config/fish/config.fish
        echo "set -gx PATH \$HOME/.cargo/bin \$PATH" >> ~/.config/fish/config.fish
    end

    echo "  ✅ Rust toolchain installed"
else
    echo "  ✅ Rust already installed: "(rustc --version)

    # Ensure cargo is in PATH for current session
    set -gx PATH $HOME/.cargo/bin $PATH
end

# Update Rust to latest stable
echo "→ Updating Rust to latest stable"
rustup update stable

# Additional useful Rust tools
echo "→ Installing common Rust utilities"
set rust_tools \
  ripgrep \
  fd-find \
  bat \
  exa

for tool in $rust_tools
    if not sudo dnf install -qy $tool 2>/dev/null
        echo "  • Installing $tool via cargo"
        cargo install $tool
    end
end

# Build tools for various languages
echo "→ Installing language-specific build tools"
set build_tools \
  python3-devel \
  python3-pip \
  nodejs \
  npm \
  golang

sudo dnf install -qy $build_tools

echo ""
echo "✅ Essential utilities installed!"
echo ""
echo "📦 What's installed:"
echo "  🦀 Rust & Cargo - Rust toolchain"
echo "  🔨 GCC/G++/Make - C/C++ compiler toolchain"
echo "  🐍 Python3 & pip - Python development"
echo "  📦 Node.js & npm - JavaScript development"
echo "  🐹 Go - Go programming language"
echo "  🔍 ripgrep, fd, bat, exa - Modern CLI tools"
echo ""
echo "💡 Cargo is now available in your PATH"
echo "   Current session: source ~/.cargo/env"
echo "   Future sessions: automatically loaded"
