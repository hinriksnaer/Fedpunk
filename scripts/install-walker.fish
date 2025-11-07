#!/usr/bin/env fish

# Get target directory (either /root or /home/USER)
set TARGET_DIR (test (id -u) -eq 0; and echo "/root"; or echo "/home/"(whoami))

cd (dirname (status -f))/../

echo "→ Installing Walker launcher"

# Install walker dependencies
set packages \
  gtk4 \
  gtk4-devel \
  gobject-introspection-devel \
  cairo-devel \
  pango-devel

sudo dnf install -qy $packages

# Check if walker is already installed
if not command -v walker >/dev/null 2>&1
    echo "→ Walker not found in PATH"
    echo "→ Installing Walker from GitHub releases"

    # Get latest release
    set WALKER_VERSION (curl -s https://api.github.com/repos/abenz1267/walker/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')

    if test -z "$WALKER_VERSION"
        echo "⚠️  Could not determine latest Walker version"
        echo "→ Please install Walker manually from: https://github.com/abenz1267/walker"
        exit 1
    end

    echo "→ Latest version: $WALKER_VERSION"

    # Download and install (adjust based on actual release assets)
    set TEMP_DIR (mktemp -d)
    cd $TEMP_DIR

    # Try to download the binary (adjust URL based on actual releases)
    curl -LO "https://github.com/abenz1267/walker/releases/download/$WALKER_VERSION/walker-linux-amd64"

    if test -f walker-linux-amd64
        chmod +x walker-linux-amd64
        sudo mv walker-linux-amd64 /usr/local/bin/walker
        echo "✅ Walker installed to /usr/local/bin/walker"
    else
        echo "⚠️  Could not download Walker binary"
        echo "→ You may need to build from source or check releases at:"
        echo "   https://github.com/abenz1267/walker/releases"
    end

    cd -
    rm -rf $TEMP_DIR
else
    echo "✅ Walker already installed: "(which walker)
end

echo "→ Stowing Walker configuration"
stow -R walker

echo "✅ Walker installation complete!"
echo ""
echo "Usage:"
echo "  - Run 'walker' to launch"
echo "  - Config: ~/.config/walker/config.toml"
echo "  - Theme: ~/.config/walker/style.css"
