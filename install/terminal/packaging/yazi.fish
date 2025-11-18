#!/usr/bin/env fish
# Yazi - Blazing fast terminal file manager
# Pure package installation and configuration

# Source helper functions
source "$FEDPUNK_INSTALL/helpers/all.fish"

section "Yazi File Manager"

# Enable Yazi Copr repository
step "Enabling Yazi Copr repository" "sudo dnf copr enable -qy lihaohong/yazi"

# Install Yazi and all dependencies at once
set yazi_packages \
    yazi \
    file \
    ffmpegthumbnailer \
    poppler-utils \
    fd-find \
    ripgrep \
    fzf \
    zoxide \
    ImageMagick

install_packages $yazi_packages

# Verify installation
if command -v yazi >/dev/null 2>&1
    success "Yazi installed successfully: "(yazi --version)
else
    error "Yazi installation failed"
    exit 1
end

# Yazi configuration is managed by chezmoi
echo ""
info "Yazi config prepared (will be deployed with chezmoi)"

# Set up Fish integration
echo ""
info "Configuring Fish shell integration"

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

# Create setup note
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
