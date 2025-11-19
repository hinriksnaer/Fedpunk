#!/usr/bin/env fish
# ============================================================================
# PLUGINS: Setup Neovim and Tmux plugins
# ============================================================================
# Purpose:
#   - Install lazy.nvim plugin manager
#   - Install Neovim plugins
#   - Install tmux plugin manager (TPM)
#   - Install tmux plugins
# Runs: After configs are deployed
# ============================================================================

source "$FEDPUNK_PROFILE_PATH/lib/helpers.fish"

section "Plugin Setup"

# Neovim plugins
if command -v nvim >/dev/null 2>&1
    subsection "Setting up Neovim plugins"

    set lazy_path "$HOME/.local/share/nvim/lazy/lazy.nvim"
    if not test -d "$lazy_path"
        step "Installing lazy.nvim" "git clone --quiet --filter=blob:none https://github.com/folke/lazy.nvim.git --branch=stable $lazy_path"
    else
        success "lazy.nvim already installed"
    end

    if test -f "$HOME/.config/nvim/init.lua"
        step "Installing Neovim plugins" "nvim --headless '+Lazy! sync' +qa"
    else
        warning "Neovim config not found"
    end
else
    info "Neovim not installed, skipping plugin setup"
end

# Tmux plugins
echo ""
if command -v tmux >/dev/null 2>&1
    subsection "Setting up tmux plugins"

    if not test -d "$HOME/.tmux/plugins/tpm"
        step "Installing TPM" "git clone --quiet https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm"
    else
        success "TPM already installed"
    end

    if test -f "$HOME/.config/tmux/tmux.conf"
        step "Installing tmux plugins" "tmux start-server \\; set -g exit-empty off \\; source-file ~/.config/tmux/tmux.conf \\; run-shell '~/.tmux/plugins/tpm/scripts/install_plugins.sh' \\; set -g exit-empty on"
    else
        warning "Tmux config not found"
    end
else
    info "Tmux not installed, skipping plugin setup"
end

echo ""
box "Plugin Setup Complete!" $GUM_SUCCESS
