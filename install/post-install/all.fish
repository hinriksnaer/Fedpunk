#!/usr/bin/env fish
# Post-installation tasks

echo "→ Running post-installation tasks"

# Setup theme system
fish "$FEDPUNK_INSTALL/post-install/setup-themes.fish"

echo "✅ Post-installation complete"
