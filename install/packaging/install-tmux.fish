#!/usr/bin/env fish

# Source helper functions
# Don't override FEDPUNK_INSTALL if it's already set
if not set -q FEDPUNK_INSTALL
    set -gx FEDPUNK_INSTALL "$HOME/.local/share/fedpunk/install"
end
if test -f "$FEDPUNK_INSTALL/helpers/all.fish"
    source "$FEDPUNK_INSTALL/helpers/all.fish"
end

# Get target directory (either /root or /home/USER)
set TARGET_DIR (test (id -u) -eq 0; and echo "/root"; or echo "/home/"(whoami))

cd $FEDPUNK_PATH

info "Installing tmux and dependencies"

# Packages to install
set packages tmux

step "Installing tmux" "sudo dnf install -qy $packages"

# Stow the configuration
step "Deploying tmux configuration" "stow -d config -t $TARGET_DIR tmux"

info "Setting up tmux plugin manager"

# Setup tmux plugins - clone TPM if it doesn't exist
if not test -d ~/.tmux/plugins/tpm
    gum spin --spinner dot --title "Cloning tmux plugin manager..." -- fish -c '
        git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm >>'"$FEDPUNK_LOG_FILE"' 2>&1
    ' && success "Cloned tmux plugin manager" || error "Failed to clone tmux plugin manager"
else
    success "Tmux plugin manager already installed"
end

# Set up token for synchronization
set token tpm_done

# Start tmux and install plugins
gum spin --spinner dot --title "Installing tmux plugins..." -- fish -c '
    tmux start-server \; \
      set -g exit-empty off \; \
      source-file ~/.config/tmux/tmux.conf \; \
      run-shell "~/.tmux/plugins/tpm/scripts/install_plugins.sh && tmux wait-for -S '$token'" \; \
      wait-for "'$token'" \; \
      set -g exit-empty on >>'"$FEDPUNK_LOG_FILE"' 2>&1
' && success "Tmux plugins installed" || warning "Tmux plugins installation may have issues"