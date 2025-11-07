#!/usr/bin/env fish

# Get target directory (either /root or /home/USER)
set TARGET_DIR (test (id -u) -eq 0; and echo "/root"; or echo "/home/"(whoami))

cd (dirname (status -f))/../

echo "→ Installing Walker launcher and Elephant service"

# Install dependencies
echo "→ Installing dependencies"
set packages \
  gtk4 \
  gtk4-devel \
  gtk4-layer-shell \
  gtk4-layer-shell-devel \
  gobject-introspection-devel \
  cairo-devel \
  pango-devel \
  poppler-glib \
  poppler-glib-devel \
  protobuf-compiler \
  rust \
  cargo

sudo dnf install -qy $packages

# Ensure cargo is in PATH
if test -d $HOME/.cargo/bin
    set -gx PATH $HOME/.cargo/bin $PATH
end

# Install Elephant service first
if not command -v elephant >/dev/null 2>&1
    echo "→ Building Elephant service from source"

    # Verify go is available
    if not command -v go >/dev/null 2>&1
        echo "❌ Go not found!"
        echo "   Please run './scripts/install-essentials.fish' first"
        exit 1
    end

    set TEMP_DIR (mktemp -d)
    cd $TEMP_DIR

    echo "→ Cloning Elephant repository"
    git clone https://github.com/abenz1267/elephant.git
    cd elephant

    echo "→ Building Elephant with Go"
    make build

    if test -f cmd/elephant/elephant
        echo "→ Installing Elephant to /usr/local/bin"
        sudo make install
        echo "✅ Elephant installed successfully"
    else
        echo "❌ Elephant build failed"
        cd -
        rm -rf $TEMP_DIR
        exit 1
    end

    cd -
    rm -rf $TEMP_DIR
else
    echo "✅ Elephant already installed: "(which elephant)
end

# Check if walker is already installed and working
if command -v walker >/dev/null 2>&1; and walker --version >/dev/null 2>&1
    echo "✅ Walker already installed: "(which walker)
else
    # Verify cargo is available
    if not command -v cargo >/dev/null 2>&1
        echo "❌ Cargo not found!"
        echo "   Please run './scripts/install-essentials.fish' first"
        exit 1
    end

    echo "→ Building Walker from source"

    set TEMP_DIR (mktemp -d)
    cd $TEMP_DIR

    echo "→ Cloning Walker repository"
    git clone https://github.com/abenz1267/walker.git
    cd walker

    echo "→ Building with Cargo (this may take a few minutes)"
    cargo build --release

    if test -f target/release/walker
        echo "→ Installing to /usr/local/bin"
        sudo cp target/release/walker /usr/local/bin/walker
        sudo chmod +x /usr/local/bin/walker
        echo "✅ Walker installed successfully"
    else
        echo "❌ Build failed"
        echo "→ Please check the error messages above"
        cd -
        rm -rf $TEMP_DIR
        exit 1
    end

    cd -
    rm -rf $TEMP_DIR
end

echo "→ Stowing Walker configuration"
stow -R walker

echo "→ Enabling Elephant systemd service"
elephant service enable
systemctl --user start elephant

echo ""
echo "✅ Walker and Elephant installation complete!"
echo ""
echo "🎉 Services configured:"
echo "  ✓ Elephant service enabled and started"
echo "  ✓ Elephant will auto-start on login"
echo ""
echo "🚀 Usage:"
echo "  - Launch Walker: walker"
echo "  - Or press Super+R in Hyprland"
echo ""
echo "📝 Configuration:"
echo "  - Walker config: ~/.config/walker/config.toml"
echo "  - Walker theme: ~/.config/walker/style.css"
echo ""
echo "🔧 Service management:"
echo "  - Check status: systemctl --user status elephant"
echo "  - Restart: systemctl --user restart elephant"
echo "  - Disable: elephant service disable"
