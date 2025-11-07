#!/usr/bin/env fish
# Install bluetui - Bluetooth TUI manager
# Usage: fish scripts/install-bluetui.fish

echo "📱 Installing bluetui (Bluetooth TUI)..."

# Check if cargo is installed
if not command -v cargo >/dev/null 2>&1
    echo "❌ Cargo not found!"
    echo "   Please install Rust first:"
    echo "   curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
    exit 1
end

# Check if bluetui is already installed
if command -v bluetui >/dev/null 2>&1
    echo "✓ bluetui is already installed"
    bluetui --version
    exit 0
end

# Install bluetui
echo "→ Installing bluetui with cargo..."
cargo install bluetui

# Verify installation
if command -v bluetui >/dev/null 2>&1
    echo "✅ bluetui installed successfully!"
    bluetui --version
else
    echo "❌ bluetui installation failed"
    exit 1
end

echo ""
echo "🎯 Usage:"
echo "  Run: bluetui"
echo "  Or use keybinding: Super + Shift + B (after setup)"
