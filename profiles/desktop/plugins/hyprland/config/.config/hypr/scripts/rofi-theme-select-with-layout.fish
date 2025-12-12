#!/usr/bin/env fish
# Wrapper for rofi-theme-select that preserves layout preference

# Update general.conf to match current layout BEFORE theme reload
fish $HOME/.config/hypr/scripts/restore-layout.fish

# Open rofi theme selector (blocks until selection made)
# Will reload with correct layout already in config
$HOME/.local/bin/rofi-theme-select
