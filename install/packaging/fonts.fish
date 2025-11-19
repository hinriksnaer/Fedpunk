#!/usr/bin/env fish
# Fonts - Programming and UI fonts
# Pure package installation (configs managed by chezmoi)

# Source helper functions
source "$FEDPUNK_INSTALL/helpers/all.fish"

section "Font Installation"

subsection "Installing base fonts"

set packages \
    adobe-source-code-pro-fonts \
    fira-code-fonts \
    fontawesome-fonts-all \
    google-droid-sans-fonts \
    google-noto-sans-cjk-fonts \
    google-noto-color-emoji-fonts \
    google-noto-emoji-fonts \
    jetbrains-mono-fonts

install_packages $packages

subsection "Installing Nerd Fonts"

step "Creating fonts directory" "mkdir -p ~/.local/share/fonts"

download_and_extract \
    "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz" \
    "$HOME/.local/share/fonts/JetBrainsMonoNerd"

download_and_extract \
    "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/FantasqueSansMono.zip" \
    "$HOME/.local/share/fonts/FantasqueSansMonoNerd"

# Download and install Victor Mono Font
download_and_extract \
    "https://rubjo.github.io/victor-mono/VictorMonoAll.zip" \
    "$HOME/.local/share/fonts/VictorMono"

# Update font cache
step "Updating font cache" "fc-cache -fv"

echo ""
box "Font Installation Complete!

Installed:
  • Adobe Source Code Pro
  • Fira Code
  • FontAwesome
  • Google Droid Sans
  • Google Noto (Sans CJK, Color Emoji, Emoji)
  • JetBrains Mono
  • JetBrains Mono Nerd Font
  • Fantasque Sans Mono Nerd Font
  • Victor Mono

💡 Fonts are now available system-wide" $GUM_SUCCESS
echo ""
