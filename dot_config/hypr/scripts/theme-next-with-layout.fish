#!/usr/bin/env fish
# Wrapper for fedpunk-theme-next that preserves layout preference

# Update general.conf to match current layout BEFORE theme reload
fish $HOME/.config/hypr/scripts/restore-layout.fish

# Switch to next theme (will reload with correct layout)
$HOME/.local/bin/fedpunk-theme-next
