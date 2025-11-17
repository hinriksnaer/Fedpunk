#!/usr/bin/env fish
# Terminal Package Installation
# Install packages for terminal-only components

# Source helper functions
source "$FEDPUNK_INSTALL/helpers/all.fish"

# Yazi file manager installation (prompt user)
echo ""
if confirm "Install Yazi file manager?" "yes"
    source "$FEDPUNK_INSTALL/terminal/packaging/yazi.fish"
else
    info "Skipping Yazi file manager installation"
    echo "[SKIPPED] Yazi file manager installation declined by user" >> $FEDPUNK_LOG_FILE
end

# Claude installation (prompt user)
echo ""
if confirm "Install Claude CLI?" "yes"
    source "$FEDPUNK_INSTALL/terminal/packaging/claude.fish"
else
    info "Skipping Claude CLI installation"
    echo "[SKIPPED] Claude CLI installation declined by user" >> $FEDPUNK_LOG_FILE
end
