#!/bin/bash
# Post-installation tasks

echo "→ Running post-installation tasks"

# Setup theme system
bash "$FEDPUNK_INSTALL/post-install/setup-themes.sh"

echo "✅ Post-installation complete"
