#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -eEo pipefail

# Define Fedpunk locations
export FEDPUNK_PATH="$HOME/.local/share/fedpunk"
export FEDPUNK_INSTALL="$FEDPUNK_PATH/install"
export PATH="$FEDPUNK_PATH/bin:$PATH"

echo "🐟 Fedpunk Linux Setup"
echo "======================"
echo "Installing complete Fedpunk environment..."
echo "Installation path: $FEDPUNK_PATH"
echo ""

# Install - Bootstrap phase (bash until fish is installed)
source "$FEDPUNK_INSTALL/helpers/all.sh"
source "$FEDPUNK_INSTALL/preflight/all.sh"

# After fish is installed, use fish for all remaining scripts
fish "$FEDPUNK_INSTALL/packaging/all.fish"
fish "$FEDPUNK_INSTALL/config/all.fish"
fish "$FEDPUNK_INSTALL/post-install/all.fish"

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
