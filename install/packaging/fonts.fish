#!/usr/bin/env fish
# Fonts - Programming and UI fonts
# Pure package installation (no config to stow)

# Source helper functions
if not set -q FEDPUNK_PATH
    set -gx FEDPUNK_PATH "$HOME/.local/share/fedpunk"
end
if not set -q FEDPUNK_INSTALL
    set -gx FEDPUNK_INSTALL "$FEDPUNK_PATH/install"
end
if test -f "$FEDPUNK_INSTALL/helpers/all.fish"
    source "$FEDPUNK_INSTALL/helpers/all.fish"
end

# Base fonts from dnf
set packages \
    adobe-source-code-pro-fonts \
    fira-code-fonts \
    fontawesome-fonts-all \
    google-droid-sans-fonts \
    google-noto-sans-cjk-fonts \
    google-noto-color-emoji-fonts \
    google-noto-emoji-fonts \
    jetbrains-mono-fonts

step "Installing base fonts" "sudo dnf install -qy $packages"

# Create fonts directory
step "Creating fonts directory" "mkdir -p ~/.local/share/fonts"

# Download and install JetBrains Mono Nerd Font
set TMPDIR (mktemp -d)

function cleanup_tmpdir --on-event fish_exit
    rm -rf $TMPDIR 2>/dev/null
end

gum spin --spinner line --title "Downloading JetBrains Mono Nerd Font..." -- fish -c '
    curl -fL --retry 2 -o "'$TMPDIR'/JetBrainsMono.tar.xz" \
        "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz" >>'"$FEDPUNK_LOG_FILE"' 2>&1
'

if test $status -eq 0
    gum spin --spinner dot --title "Installing JetBrains Mono Nerd Font..." -- fish -c '
        rm -rf ~/.local/share/fonts/JetBrainsMonoNerd
        mkdir -p ~/.local/share/fonts/JetBrainsMonoNerd
        tar -xJf "'$TMPDIR'/JetBrainsMono.tar.xz" -C ~/.local/share/fonts/JetBrainsMonoNerd >>'"$FEDPUNK_LOG_FILE"' 2>&1
    ' && success "JetBrains Mono Nerd Font installed" || error "Failed to install JetBrains Mono Nerd Font"
else
    error "Failed to download JetBrains Mono Nerd Font"
end

# Download and install Fantasque Sans Mono Nerd Font
gum spin --spinner line --title "Downloading Fantasque Sans Mono Nerd Font..." -- fish -c '
    curl -fL --retry 2 -o "'$TMPDIR'/FantasqueSansMono.zip" \
        "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/FantasqueSansMono.zip" >>'"$FEDPUNK_LOG_FILE"' 2>&1
'

if test $status -eq 0
    gum spin --spinner dot --title "Installing Fantasque Sans Mono Nerd Font..." -- fish -c '
        mkdir -p ~/.local/share/fonts/FantasqueSansMonoNerd
        unzip -o -q "'$TMPDIR'/FantasqueSansMono.zip" -d ~/.local/share/fonts/FantasqueSansMonoNerd >>'"$FEDPUNK_LOG_FILE"' 2>&1
    ' && success "Fantasque Sans Mono Nerd Font installed" || error "Failed to install Fantasque Sans Mono Nerd Font"
else
    error "Failed to download Fantasque Sans Mono Nerd Font"
end

# Download and install Victor Mono Font
gum spin --spinner line --title "Downloading Victor Mono Font..." -- fish -c '
    curl -fL --retry 2 -o "'$TMPDIR'/VictorMonoAll.zip" \
        "https://rubjo.github.io/victor-mono/VictorMonoAll.zip" >>'"$FEDPUNK_LOG_FILE"' 2>&1
'

if test $status -eq 0
    gum spin --spinner dot --title "Installing Victor Mono Font..." -- fish -c '
        mkdir -p ~/.local/share/fonts/VictorMono >>'"$FEDPUNK_LOG_FILE"' 2>&1
        unzip -o -q "'$TMPDIR'/VictorMonoAll.zip" -d ~/.local/share/fonts/VictorMono >>'"$FEDPUNK_LOG_FILE"' 2>&1
    ' && success "Victor Mono Font installed" || error "Failed to install Victor Mono Font"
else
    error "Failed to download Victor Mono Font"
end

step "Updating font cache" "fc-cache -fv"
