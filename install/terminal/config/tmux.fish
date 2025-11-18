#!/usr/bin/env fish
# tmux - Terminal multiplexer
# End-to-end setup: install package → deploy config → setup plugins

# FEDPUNK_PATH and FEDPUNK_INSTALL should be set by parent install.fish
# Source helper functions
if test -f "$FEDPUNK_INSTALL/helpers/all.fish"
    source "$FEDPUNK_INSTALL/helpers/all.fish"
end

echo ""
info "Setting up tmux"

# Install package
step "Installing tmux" "sudo dnf install -qy tmux"

# Configuration will be deployed by chezmoi at end of installation
info "tmux config prepared (will be deployed with chezmoi)"

# Setup tmux plugin manager
if not test -d $HOME/.tmux/plugins/tpm
    gum spin --spinner dot --title "Cloning tmux plugin manager..." -- fish -c '
        git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm >>'"$FEDPUNK_LOG_FILE"' 2>&1
    ' && success "Cloned tmux plugin manager" || error "Failed to clone tmux plugin manager"
else
    success "Tmux plugin manager already installed"
end

# Install tmux plugins (only if config exists - should be deployed by chezmoi)
if not test -f "$HOME/.config/tmux/tmux.conf"
    warning "tmux config not found at ~/.config/tmux/tmux.conf"
    warning "This should have been deployed by chezmoi. Skipping plugin installation."
    warning "Run 'chezmoi apply' then manually install plugins with: ~/.tmux/plugins/tpm/scripts/install_plugins.sh"
else
    set token tpm_done
    gum spin --spinner dot --title "Installing tmux plugins..." -- fish -c '
        tmux start-server \; \
          set -g exit-empty off \; \
          source-file '$HOME'/.config/tmux/tmux.conf \; \
          run-shell "'$HOME'/.tmux/plugins/tpm/scripts/install_plugins.sh && tmux wait-for -S '$token'" \; \
          wait-for "'$token'" \; \
          set -g exit-empty on >>'"$FEDPUNK_LOG_FILE"' 2>&1
    ' && success "Tmux plugins installed" || warning "Tmux plugins installation may have issues"
end

success "tmux setup complete"
