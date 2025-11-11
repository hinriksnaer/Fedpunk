#!/usr/bin/env fish
# Terminal Package Installation
# Install packages for terminal-only components

# Source helper functions
source "$FEDPUNK_INSTALL/helpers/all.fish"

# Claude installation (prompt user)
echo ""
if confirm "Install Claude CLI?" "yes"
    fish "$FEDPUNK_INSTALL/terminal/packaging/claude.fish"
else
    info "Skipping Claude CLI installation"
    echo "[SKIPPED] Claude CLI installation declined by user" >> $FEDPUNK_LOG_FILE
end
