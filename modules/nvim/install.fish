#!/usr/bin/env fish
# ============================================================================
# NVIM MODULE: Install Neovim
# ============================================================================

source "$FEDPUNK_LIB_PATH/helpers.fish"

subsection "Installing Neovim"

# Get module parameter (default from module.yaml or override from profile)
set -q FEDPUNK_MODULE_NVIM_PACKAGE_NAME; or set FEDPUNK_MODULE_NVIM_PACKAGE_NAME "neovim"

install_if_missing nvim $FEDPUNK_MODULE_NVIM_PACKAGE_NAME

success "Neovim installed"
