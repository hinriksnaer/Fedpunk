#!/usr/bin/env fish
# ============================================================================
# NVIM MODULE: Setup lazy.nvim plugin manager
# ============================================================================

source "$FEDPUNK_LIB_PATH/helpers.fish"

# Check if plugin setup is enabled
set -q FEDPUNK_MODULE_NVIM_SETUP_PLUGINS; or set FEDPUNK_MODULE_NVIM_SETUP_PLUGINS "true"

if test "$FEDPUNK_MODULE_NVIM_SETUP_PLUGINS" != "true"
    info "Skipping Neovim plugin setup (disabled in module config)"
    exit 0
end

if not command -v nvim >/dev/null
    warning "Neovim not found, skipping plugin setup"
    exit 0
end

subsection "Setting up Neovim plugins"

set lazy_path "$HOME/.local/share/nvim/lazy/lazy.nvim"
if not test -d "$lazy_path"
    step "Installing lazy.nvim" \
        "git clone --quiet --filter=blob:none https://github.com/folke/lazy.nvim.git --branch=stable $lazy_path"
else
    success "lazy.nvim already installed"
end

success "Neovim plugins ready"
