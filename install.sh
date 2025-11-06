#!/usr/bin/env bash
set -euo pipefail

echo "🐟 Fedpunk Dotfiles - Fish-First Installer"
echo "=========================================="

# Initialize dependencies and Fish if needed
echo "→ Setting up prerequisites"
bash "./scripts/init.sh"

# Check if Fish is available, install if not
if ! command -v fish >/dev/null 2>&1; then
    echo "→ Fish not found, installing Fish first..."
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
else
    echo "✅ Fish already available"
fi

# Hand off to the main Fish installer
echo ""
echo "→ Launching main Fish installer..."
fish "./install.fish" "$@"