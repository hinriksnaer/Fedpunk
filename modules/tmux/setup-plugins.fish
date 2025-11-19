#!/usr/bin/env fish
# ============================================================================
# TMUX MODULE: Setup TPM plugin manager
# ============================================================================

source "$FEDPUNK_LIB_PATH/helpers.fish"

set -q FEDPUNK_MODULE_TMUX_SETUP_TPM; or set FEDPUNK_MODULE_TMUX_SETUP_TPM "true"

if test "$FEDPUNK_MODULE_TMUX_SETUP_TPM" != "true"
    info "Skipping tmux plugin setup (disabled in module config)"
    exit 0
end

if not command -v tmux >/dev/null
    warning "tmux not found, skipping plugin setup"
    exit 0
end

subsection "Setting up tmux plugins"

set tpm_path "$HOME/.tmux/plugins/tpm"
if not test -d "$tpm_path"
    step "Installing TPM" \
        "git clone --quiet https://github.com/tmux-plugins/tpm $tpm_path"
else
    success "TPM already installed"
end

success "tmux plugins ready"
