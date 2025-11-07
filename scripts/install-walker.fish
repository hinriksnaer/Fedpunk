#!/usr/bin/env fish

# Get target directory (either /root or /home/USER)
set TARGET_DIR (test (id -u) -eq 0; and echo "/root"; or echo "/home/"(whoami))

cd (dirname (status -f))/../

echo "→ Installing Walker launcher"

# Install walker dependencies
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

echo "✅ Walker installation complete!"
echo ""
echo "Usage:"
echo "  - Run 'walker' to launch"
echo "  - Config: ~/.config/walker/config.toml"
echo "  - Theme: ~/.config/walker/style.css"
