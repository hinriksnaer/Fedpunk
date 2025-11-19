#!/usr/bin/env fish
# Development Profile - Container Mode
# Minimal development environment for containers/devcontainers

set -gx FEDPUNK_MODE container

# Terminal packages - only set what we want (unset = prompt)
set -gx FEDPUNK_INSTALL_CLAUDE true
set -gx FEDPUNK_INSTALL_GH true

# Terminal configuration - minimal
set -gx FEDPUNK_INSTALL_NEOVIM true
set -gx FEDPUNK_INSTALL_LAZYGIT true

# Development tools
set -gx FEDPUNK_INSTALL_CLI_TOOLS true
set -gx FEDPUNK_INSTALL_LANGUAGES true
