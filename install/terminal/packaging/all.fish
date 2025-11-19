#!/usr/bin/env fish
# Terminal Package Installation
# Install packages for terminal-only components

# Source helper functions
source "$FEDPUNK_INSTALL/helpers/all.fish"

# Yazi file manager installation (checks $FEDPUNK_INSTALL_YAZI or prompts)
install_if_enabled "FEDPUNK_INSTALL_YAZI" \
    "Install Yazi file manager?" \
    "$FEDPUNK_INSTALL/terminal/packaging/yazi.fish" \
    "yes"

# Claude CLI installation (checks $FEDPUNK_INSTALL_CLAUDE or prompts)
install_if_enabled "FEDPUNK_INSTALL_CLAUDE" \
    "Install Claude CLI?" \
    "$FEDPUNK_INSTALL/terminal/packaging/claude.fish" \
    "yes"

# GitHub CLI installation (checks $FEDPUNK_INSTALL_GH or prompts)
install_if_enabled "FEDPUNK_INSTALL_GH" \
    "Install GitHub CLI (gh)?" \
    "$FEDPUNK_INSTALL/terminal/packaging/gh.fish" \
    "yes"
