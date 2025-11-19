#!/usr/bin/env fish
# Development Profile - Desktop Mode
# Full desktop environment with all development tools

set -gx FEDPUNK_MODE desktop

# Terminal packages (unset = prompt user)
set -gx FEDPUNK_INSTALL_YAZI true
set -gx FEDPUNK_INSTALL_CLAUDE true
set -gx FEDPUNK_INSTALL_GH true

# Terminal configuration
set -gx FEDPUNK_INSTALL_TMUX true
set -gx FEDPUNK_INSTALL_NEOVIM true
set -gx FEDPUNK_INSTALL_BTOP true
set -gx FEDPUNK_INSTALL_LAZYGIT true

# Development tools
set -gx FEDPUNK_INSTALL_CLI_TOOLS true
set -gx FEDPUNK_INSTALL_LANGUAGES true

# Desktop packages
set -gx FEDPUNK_INSTALL_FONTS true
set -gx FEDPUNK_INSTALL_AUDIO true
set -gx FEDPUNK_INSTALL_MULTIMEDIA true
set -gx FEDPUNK_INSTALL_BLUETOOTH true
