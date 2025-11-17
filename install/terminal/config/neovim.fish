#!/usr/bin/env fish
# Neovim - Modern text editor
# End-to-end setup: install package → deploy config

# FEDPUNK_PATH and FEDPUNK_INSTALL should be set by parent install.fish
# Source helper functions
if test -f "$FEDPUNK_INSTALL/helpers/all.fish"
    source "$FEDPUNK_INSTALL/helpers/all.fish"
end

echo ""
info "Setting up Neovim"

# Figure out target user and home directory (works with/without sudo)
if test (id -u) -eq 0
    if set -q SUDO_USER; and test "$SUDO_USER" != "root"
        set TARGET_USER $SUDO_USER
        set TARGET_HOME (getent passwd $SUDO_USER | cut -d: -f6)
    else
        set TARGET_USER root
        set TARGET_HOME /root
    end
else
    set TARGET_USER (whoami)
    set TARGET_HOME $HOME
end

# Install dependencies
set packages ripgrep fzf
set SUDO_CMD ""
if test (id -u) -ne 0
    set SUDO_CMD sudo
end

step "Installing Neovim dependencies" "$SUDO_CMD dnf install -qy $packages"

# User-local Neovim install (no sudo)
set TMPDIR (mktemp -d)

function cleanup_tmpdir --on-event fish_exit
    rm -rf $TMPDIR 2>/dev/null
end

step "Creating directories" "mkdir -p $TARGET_HOME/.local $TARGET_HOME/.local/bin"

gum spin --spinner line --title "Downloading Neovim..." -- fish -c '
    curl -fL --retry 3 -o "'$TMPDIR'/nvim.tar.gz" \
        "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz" >>'"$FEDPUNK_LOG_FILE"' 2>&1
' && success "Neovim downloaded" || error "Failed to download Neovim"

gum spin --spinner dot --title "Installing Neovim..." -- fish -c '
    tar -xzf "'$TMPDIR'/nvim.tar.gz" -C "'$TARGET_HOME'/.local" >>'"$FEDPUNK_LOG_FILE"' 2>&1
    ln -sfn "'$TARGET_HOME'/.local/nvim-linux-x86_64/bin/nvim" "'$TARGET_HOME'/.local/bin/nvim" >>'"$FEDPUNK_LOG_FILE"' 2>&1
' && success "Neovim installed" || error "Failed to install Neovim"

# Ensure ownership if script was run with sudo
if test (id -u) -eq 0; and test "$TARGET_USER" != "root"
    step "Setting ownership" "chown -R $TARGET_USER:$TARGET_USER $TARGET_HOME/.local"
end

# Ensure ~/.local/bin is on PATH for future shells
gum spin --spinner dot --title "Configuring PATH..." -- fish -c '
    set add_path_line "export PATH=\"\$HOME/.local/bin:\$PATH\""
    for rc in "'$TARGET_HOME'/.bashrc" "'$TARGET_HOME'/.zshrc"
        if test -f $rc; and not grep -qF "$add_path_line" $rc
            echo $add_path_line >> $rc
        end
    end >>'"$FEDPUNK_LOG_FILE"' 2>&1
' && success "PATH configured" || warning "Failed to configure PATH"

# Configuration is deployed by chezmoi (before this script runs)
info "Neovim configuration deployed by chezmoi"

success "Neovim setup complete"
