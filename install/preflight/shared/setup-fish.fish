#!/usr/bin/env fish
# Fish Shell Setup - SECOND PREFLIGHT STEP (after cargo)
# Sets up Fish shell enhancements, configuration, and required tools
# Note: Assumes gum is already installed by boot.sh

# FEDPUNK_PATH and FEDPUNK_INSTALL should be set by parent install.fish
# Source helper functions
if test -f "$FEDPUNK_INSTALL/helpers/all.fish"
    source "$FEDPUNK_INSTALL/helpers/all.fish"
end

echo ""
section "Fish Shell Setup"

# Install chezmoi (CRITICAL - needed for configuration deployment)
mkdir -p $HOME/.local/bin
if gum spin --spinner dot --title "Installing chezmoi (configuration management)..." -- fish -c '
    curl -sL https://github.com/twpayne/chezmoi/releases/latest/download/chezmoi-linux-amd64 -o $HOME/.local/bin/chezmoi >>'"$FEDPUNK_LOG_FILE"' 2>&1 && chmod +x $HOME/.local/bin/chezmoi
'
    success "chezmoi installed"
else
    error "Failed to install chezmoi"
    exit 1
end

# Initialize chezmoi with fedpunk as source
if test ! -f "$HOME/.config/chezmoi/chezmoi.toml"
    mkdir -p "$HOME/.config/chezmoi"
    # Use $FEDPUNK_PATH for correct path in both host and container environments
    echo "sourceDir = \"$FEDPUNK_PATH\"" > "$HOME/.config/chezmoi/chezmoi.toml"
    success "Chezmoi configured with sourceDir: $FEDPUNK_PATH"
end

# Fish configuration will be deployed by chezmoi at the end of installation
info "Fish configuration prepared (will be deployed with chezmoi)"

# Install chsh utility if needed
if not command -v chsh >/dev/null 2>&1
    if gum spin --spinner dot --title "Installing chsh utility..." -- \
        fish -c "sudo dnf install -qy util-linux-user >>$FEDPUNK_LOG_FILE 2>&1"
        success "chsh utility installed"
    else
        error "Failed to install chsh utility"
    end
end

# Change shell for the current user
if gum spin --spinner dot --title "Setting Fish as default shell..." -- \
    fish -c "if command -v sudo >/dev/null 2>&1
                sudo chsh -s /usr/bin/fish (whoami) >>$FEDPUNK_LOG_FILE 2>&1
             else
                chsh -s /usr/bin/fish >>$FEDPUNK_LOG_FILE 2>&1
             end"
    success "Fish set as default shell"
else
    warning "Failed to set Fish as default shell (may require manual setup)"
end

# Install Starship prompt
echo ""
info "Installing Starship prompt"
if gum spin --spinner dot --title "Installing Starship prompt..." -- fish -c '
    sudo dnf copr enable -qy atim/starship >>'"$FEDPUNK_LOG_FILE"' 2>&1
    sudo dnf install --refresh -qy starship >>'"$FEDPUNK_LOG_FILE"' 2>&1
'
    success "Starship prompt installed"
else
    warning "Starship installation failed"
end

# Install Fisher (fish plugin manager)
echo ""
info "Installing Fisher plugin manager"
if not test -f ~/.config/fish/functions/fisher.fish
    if gum spin --spinner dot --title "Installing Fisher plugin manager..." -- fish -c '
        curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher >>'"$FEDPUNK_LOG_FILE"' 2>&1
    '
        success "Fisher plugin manager installed"
    else
        warning "Fisher installation failed"
    end
else
    success "Fisher already installed"
end

# Install fzf.fish plugin
if not fish -c "fisher list" 2>/dev/null | grep -q "fzf.fish"
    if gum spin --spinner dot --title "Installing fzf.fish plugin..." -- \
        fish -c "fisher install PatrickF1/fzf.fish >>$FEDPUNK_LOG_FILE 2>&1"
        success "fzf.fish plugin installed"
    else
        warning "fzf.fish installation failed"
    end
else
    success "fzf.fish already installed"
end

# Reload fish config to pick up starship and fzf for the current session
echo ""
info "Reloading Fish configuration"
if test -f ~/.config/fish/config.fish
    source ~/.config/fish/config.fish 2>/dev/null
    and success "Fish config reloaded"
    or info "Fish config will be active on next shell restart"
end

echo ""
box "Fish Shell Setup Complete!

Configured:
  🐟 Fish shell - Set as default shell
  📦 chezmoi - Configuration management
  ⭐ Starship - Fast, customizable prompt
  🎣 Fisher - Fish plugin manager
  🔎 fzf.fish - Fuzzy finder integration
  ⚙️  Fish config - Managed by chezmoi

Note: gum was installed by boot.sh and is available system-wide" $GUM_SUCCESS
echo ""
