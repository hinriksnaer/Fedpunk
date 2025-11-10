#!/usr/bin/env fish

echo "→ Installing fonts"

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

sudo dnf upgrade --refresh -qy
sudo dnf install -qy $packages

# Create fonts directory
mkdir -p ~/.local/share/fonts

echo "→ Downloading JetBrains Mono Nerd Font"

# Download and install JetBrains Mono Nerd Font
set TMPDIR (mktemp -d)

function cleanup_tmpdir --on-process-exit
    rm -rf $TMPDIR
end

if curl -fL --retry 2 -o "$TMPDIR/JetBrainsMono.tar.xz" \
    "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz"

    # Remove old installation if exists
    rm -rf ~/.local/share/fonts/JetBrainsMonoNerd

    # Create directory and extract
    mkdir -p ~/.local/share/fonts/JetBrainsMonoNerd
    tar -xJf "$TMPDIR/JetBrainsMono.tar.xz" -C ~/.local/share/fonts/JetBrainsMonoNerd

    echo "✓ JetBrains Mono Nerd Font installed"
else
    echo "✗ Failed to download JetBrains Mono Nerd Font"
end

echo "→ Downloading Fantasque Sans Mono Nerd Font"

# Download and install Fantasque Sans Mono Nerd Font
if curl -fL --retry 2 -o "$TMPDIR/FantasqueSansMono.zip" \
    "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/FantasqueSansMono.zip"

    mkdir -p ~/.local/share/fonts/FantasqueSansMonoNerd
    unzip -o -q "$TMPDIR/FantasqueSansMono.zip" -d ~/.local/share/fonts/FantasqueSansMonoNerd

    echo "✓ Fantasque Sans Mono Nerd Font installed"
else
    echo "✗ Failed to download Fantasque Sans Mono Nerd Font"
end

echo "→ Downloading Victor Mono Font"

# Download and install Victor Mono Font
if curl -fL --retry 2 -o "$TMPDIR/VictorMonoAll.zip" \
    "https://rubjo.github.io/victor-mono/VictorMonoAll.zip"

    mkdir -p ~/.local/share/fonts/VictorMono
    unzip -o -q "$TMPDIR/VictorMonoAll.zip" -d ~/.local/share/fonts/VictorMono

    echo "✓ Victor Mono Font installed"
else
    echo "✗ Failed to download Victor Mono Font"
end

echo "→ Updating font cache"
fc-cache -fv >/dev/null 2>&1

echo "✓ Fonts installation complete"
