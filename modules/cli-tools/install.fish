#!/usr/bin/env fish
# ============================================================================
# CLI-TOOLS MODULE: Install essential command-line tools
# ============================================================================

source "$FEDPUNK_LIB_PATH/helpers.fish"

subsection "Installing CLI tools"

install_packages ripgrep fd-find bat eza fzf

success "CLI tools installed"
