#!/usr/bin/env fish
# Yazi - Blazing fast terminal file manager
# Pure package installation and configuration

# FEDPUNK_PATH and FEDPUNK_INSTALL should be set by parent install.fish
# Source helper functions
if test -f "$FEDPUNK_INSTALL/helpers/all.fish"
    source "$FEDPUNK_INSTALL/helpers/all.fish"
end

echo ""
info "Installing Yazi file manager"

# Install Rust/Cargo if not present (required for yazi)
if not command -v cargo >/dev/null 2>&1
    step "Installing Rust toolchain" "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y"
    # Source cargo env
    source ~/.cargo/env
else
    success "Rust/Cargo already installed"
end

# Install required dependencies for yazi
echo ""
info "Installing Yazi dependencies"

# File and ffmpeg for file previews
step "Installing file command" "sudo dnf install -qy file"
step "Installing ffmpegthumbnailer" "sudo dnf install -qy ffmpegthumbnailer"
step "Installing poppler-utils" "sudo dnf install -qy poppler-utils"
step "Installing fd-find" "sudo dnf install -qy fd-find"
step "Installing ripgrep" "sudo dnf install -qy ripgrep"
step "Installing fzf" "sudo dnf install -qy fzf"
step "Installing zoxide" "sudo dnf install -qy zoxide"
step "Installing imagemagick" "sudo dnf install -qy ImageMagick"

# Install Yazi via cargo
echo ""
info "Installing Yazi via cargo"
gum spin --spinner dot --title "Building Yazi from source (this may take a few minutes)..." -- fish -c '
    cargo install --locked yazi-fm yazi-cli >>'"$FEDPUNK_LOG_FILE"' 2>&1
'

# Verify installation
if command -v yazi >/dev/null 2>&1
    success "Yazi installed successfully: "(yazi --version)
else
    error "Yazi installation failed"
    info "Trying alternative installation method..."

    # Try installing from GitHub releases
    set YAZI_VERSION (curl -s https://api.github.com/repos/sxyazi/yazi/releases/latest | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/')
    set YAZI_URL "https://github.com/sxyazi/yazi/releases/download/v$YAZI_VERSION/yazi-x86_64-unknown-linux-gnu.zip"

    step "Creating local bin directory" "mkdir -p ~/.local/bin"

    gum spin --spinner line --title "Downloading Yazi binary..." -- fish -c '
        cd /tmp
        curl -fL "'$YAZI_URL'" -o yazi.zip >>'"$FEDPUNK_LOG_FILE"' 2>&1
        unzip -o yazi.zip >>'"$FEDPUNK_LOG_FILE"' 2>&1
        cd yazi-x86_64-unknown-linux-gnu
        cp yazi ya ~/.local/bin/ >>'"$FEDPUNK_LOG_FILE"' 2>&1
        chmod +x ~/.local/bin/yazi ~/.local/bin/ya >>'"$FEDPUNK_LOG_FILE"' 2>&1
        rm -rf /tmp/yazi.zip /tmp/yazi-x86_64-unknown-linux-gnu >>'"$FEDPUNK_LOG_FILE"' 2>&1
    '

    if command -v yazi >/dev/null 2>&1
        success "Yazi installed via binary download"
    else
        error "Yazi installation failed with both methods"
        info "Please install manually from https://github.com/sxyazi/yazi"
        exit 1
    end
end

# Stow yazi configuration
echo ""
info "Setting up Yazi configuration"
if test -d "$FEDPUNK_PATH/config/yazi"
    step "Deploying yazi config with stow" "cd $FEDPUNK_PATH/config && stow -t ~ yazi"
else
    warning "Yazi config directory not found, skipping stow"
    # Create minimal config directory
    step "Creating config directory" "mkdir -p ~/.config/yazi"
end

# Set up Fish integration
echo ""
info "Configuring Fish shell integration"

# Add Yazi to Fish PATH (if using local install)
if test -f ~/.local/bin/yazi
    step "Adding Yazi to PATH" "set -U fish_user_paths ~/.local/bin \$fish_user_paths"
end

# Create Fish function for Yazi with cd on quit
gum spin --spinner dot --title "Creating Fish function..." -- fish -c '
    mkdir -p ~/.config/fish/functions
    printf "%s\n" \
        "function yy" \
        "    # Yazi with cd on quit functionality" \
        "    set tmp (mktemp -t \"yazi-cwd.XXXXXX\")" \
        "    yazi \$argv --cwd-file=\"\$tmp\"" \
        "    if set cwd (cat -- \"\$tmp\"); and [ -n \"\$cwd\" ]; and [ \"\$cwd\" != \"\$PWD\" ]" \
        "        cd -- \"\$cwd\"" \
        "    end" \
        "    rm -f -- \"\$tmp\"" \
        "end" > ~/.config/fish/functions/yy.fish >>'"$FEDPUNK_LOG_FILE"' 2>&1
' && success "Fish function created"

# Create Fish abbreviations
gum spin --spinner dot --title "Creating Fish abbreviations..." -- fish -c '
    printf "%s\n" \
        "# Yazi file manager abbreviations" \
        "abbr -a y \"yazi\"" \
        "abbr -a yy \"yy\"  # cd on quit" > ~/.config/fish/conf.d/yazi_abbr.fish >>'"$FEDPUNK_LOG_FILE"' 2>&1
' && success "Fish abbreviations created"

# Create zoxide integration note
gum spin --spinner dot --title "Creating setup files..." -- fish -c '
    printf "%s\n" \
        "# Yazi setup - integrated with Fish shell" \
        "# Use '\''yy'\'' to launch yazi and cd to selected directory on quit" \
        "# Use '\''y'\'' for regular yazi without cd on quit" > ~/.config/fish/conf.d/yazi_setup.fish >>'"$FEDPUNK_LOG_FILE"' 2>&1
' && success "Setup files created"

echo ""
box "Yazi Installation Complete!

Installed:
  📁 Yazi file manager
  🐟 Fish shell integration
  ⌨️  'y' abbreviation for yazi
  ⌨️  'yy' function (cd on quit)

Preview support:
  🖼️  Images (ImageMagick)
  📄 PDFs (poppler)
  🎬 Videos (ffmpegthumbnailer)

Getting started:
  1. Run 'yazi' or 'y' to open file manager
  2. Use 'yy' to cd to selected directory on quit
  3. Press '?' in yazi for help

💡 Tip: Run 'exec fish' to load the new abbreviations" $GUM_SUCCESS
echo ""
