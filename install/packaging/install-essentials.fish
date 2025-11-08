#!/usr/bin/env fish
# Essential development environment
# Installs all core dev tools, languages, and modern CLI utilities

echo "🔧 Installing Essential Development Environment"
echo "================================================"

# Get target directory (either /root or /home/USER)
set TARGET_DIR (test (id -u) -eq 0; and echo "/root"; or echo "/home/"(whoami))

cd (dirname (status -f))/../

# Core development tools and utilities
echo "→ Installing core development tools"
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

sudo dnf install -qy $core_tools

# Modern CLI tools (via DNF or cargo fallback)
echo "→ Installing modern CLI utilities"

# Starship prompt
echo "  • Installing Starship prompt"
if not sudo dnf copr enable -qy atim/starship 2>/dev/null
    echo "    ⚠️  Starship COPR already enabled or unavailable"
end
sudo dnf install -qy starship 2>/dev/null || true

# lsd (modern ls)
if not command -v lsd >/dev/null 2>&1
    echo "  • Installing lsd"
    if not sudo dnf install -qy lsd 2>/dev/null
        echo "    Falling back to cargo install"
        cargo install lsd 2>/dev/null || true
    end
end

# Other modern CLI tools
set modern_tools \
  ripgrep \
  fd-find \
  bat \
  exa

for tool in $modern_tools
    if not command -v $tool >/dev/null 2>&1
        echo "  • Installing $tool"
        if not sudo dnf install -qy $tool 2>/dev/null
            echo "    Falling back to cargo install"
            cargo install $tool 2>/dev/null || true
        end
    end
end

# Programming languages and runtimes
echo "→ Installing programming languages"

# Rust and Cargo
if not command -v rustc >/dev/null 2>&1
    echo "  • Installing Rust toolchain"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable --no-modify-path

    # Source cargo env for current session
    source $HOME/.cargo/env

    # Add to fish config if not already there
    if not grep -q "cargo/bin" ~/.config/fish/config.fish 2>/dev/null
        echo "" >> ~/.config/fish/config.fish
        echo "# Rust/Cargo" >> ~/.config/fish/config.fish
        echo "set -gx PATH \$HOME/.cargo/bin \$PATH" >> ~/.config/fish/config.fish
    end

    echo "    ✅ Rust toolchain installed"
else
    echo "  ✅ Rust already installed: "(rustc --version)

    # Ensure cargo is in PATH for current session
    set -gx PATH $HOME/.cargo/bin $PATH
end

# Update Rust to latest stable
echo "  • Updating Rust to latest stable"
rustup update stable 2>/dev/null || true

# Python, Node.js, Go
echo "  • Installing Python, Node.js, and Go"
set language_tools \
  python3-devel \
  python3-pip \
  nodejs \
  npm \
  golang

sudo dnf install -qy $language_tools

# Fish shell enhancements
echo "→ Setting up Fish shell enhancements"

# Install Fisher (fish plugin manager)
if not test -f ~/.config/fish/functions/fisher.fish
    echo "  • Installing Fisher plugin manager"
    fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher" 2>/dev/null
    and echo "    ✅ Fisher installed"
    or echo "    ⚠️  Fisher installation failed"
else
    echo "  ✅ Fisher already installed"
end

# Install fzf.fish plugin
if not fish -c "fisher list" 2>/dev/null | grep -q "fzf.fish"
    echo "  • Installing fzf.fish plugin"
    fish -c "fisher install PatrickF1/fzf.fish" 2>/dev/null
    and echo "    ✅ fzf.fish installed"
    or echo "    ⚠️  fzf.fish installation failed"
else
    echo "  ✅ fzf.fish already installed"
end

echo ""
echo "✅ Essential development environment installed!"
echo ""
echo "📦 What's installed:"
echo "  🐟 Fish shell - Modern shell with intelligent features"
echo "  ⭐ Starship - Fast, customizable prompt"
echo "  📁 lsd, exa - Modern ls replacements"
echo "  🔍 ripgrep, fd - Fast search tools"
echo "  🦇 bat - Better cat with syntax highlighting"
echo "  🦀 Rust & Cargo - Rust toolchain and package manager"
echo "  🔨 GCC/G++/Make - C/C++ compiler toolchain"
echo "  🐍 Python3 & pip - Python development"
echo "  📦 Node.js & npm - JavaScript development"
echo "  🐹 Go - Go programming language"
echo "  🎣 Fisher - Fish plugin manager"
echo "  🔎 fzf.fish - Fuzzy finder integration"
echo "  🦊 Firefox - Web browser"
echo ""
echo "💡 Next steps:"
echo "  • Restart your shell: exec fish"
echo "  • Cargo is available in: \$HOME/.cargo/bin"
echo "  • Install more components with: fish install.fish custom --<component>"
echo ""
