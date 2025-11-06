#!/usr/bin/env bash
set -euo pipefail

echo "🐟 Fedpunk Linux Setup"
echo "======================"
echo "Installing complete Fedpunk environment..."
echo ""

# Initialize prerequisites
echo "→ Setting up prerequisites and Fish shell"
if [ -f "./scripts/init.sh" ]; then
    bash "./scripts/init.sh"
else
    echo "❌ Prerequisites script not found!"
    exit 1
fi

# Install Fish first
if [ -f "./scripts/install-fish.sh" ]; then
    bash "./scripts/install-fish.sh"
else
    echo "❌ Fish installer not found!"
    exit 1
fi

# Verify Fish installation
if ! command -v fish >/dev/null 2>&1; then
    echo "❌ Fish installation failed!"
    exit 1
fi

echo "✅ Fish installed successfully!"
echo ""

# Hand off to Fish for full installation
echo "→ Running full Fedpunk setup via Fish..."
fish "./install.fish" full

echo ""
echo "🎉 Fedpunk installation complete!"
echo ""
echo "🚀 Next steps:"
echo "  • Restart your terminal or run: exec fish"
echo "  • Log out and select 'Hyprland' from your display manager"
echo "  • Or run 'Hyprland' from a TTY"
echo ""
echo "⌨️  Hyprland key bindings:"
echo "  Super+Q: Terminal  │  Super+R: Launcher  │  Super+C: Close"
echo "  Super+1-9: Workspaces  │  Print: Screenshot"