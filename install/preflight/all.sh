#!/bin/bash
# Preflight checks and prerequisites

echo "→ Setting up prerequisites"
bash "$FEDPUNK_INSTALL/preflight/init.sh"

echo "→ Installing Fish shell"
bash "$FEDPUNK_INSTALL/preflight/install-fish.sh"

# Verify Fish installation
if ! command -v fish >/dev/null 2>&1; then
    echo "❌ Fish installation failed!"
    exit 1
fi

echo "→ Checking SELinux configuration"
fish "$FEDPUNK_INSTALL/preflight/selinux-check.fish"

echo "✅ Prerequisites complete"
