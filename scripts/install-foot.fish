#!/usr/bin/env fish

echo "🦶 Installing Foot Terminal"
echo "=========================="

# Get target directory (either /root or /home/USER)
set TARGET_DIR (test (id -u) -eq 0; and echo "/root"; or echo "/home/"(whoami))

cd (dirname (status -f))/../

echo "→ Installing Foot terminal emulator"
sudo dnf install -y foot

echo "→ Installing Nerd Fonts for terminal icons"

# Check if Hack Nerd Font is already installed
if fc-list | grep -i "hack nerd font" >/dev/null
    echo "✅ Hack Nerd Font already installed"
else
    echo "→ Installing Hack Nerd Font"
    
    # Create fonts directory
    mkdir -p ~/.local/share/fonts
    
    # Download and install Hack Nerd Font
    set font_url "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Hack.zip"
    set temp_dir (mktemp -d)
    
    echo "  Downloading Hack Nerd Font..."
    curl -fL "$font_url" -o "$temp_dir/Hack.zip"
    
    echo "  Extracting font files..."
    unzip -q "$temp_dir/Hack.zip" -d "$temp_dir"
    
    echo "  Installing font files..."
    cp "$temp_dir"/*.ttf ~/.local/share/fonts/
    
    # Clean up
    rm -rf "$temp_dir"
    
    # Refresh font cache
    echo "  Refreshing font cache..."
    fc-cache -fv ~/.local/share/fonts >/dev/null 2>&1
    
    echo "✅ Hack Nerd Font installed successfully"
end

echo "→ Installing Foot configuration"

# Stow the foot configuration
stow -t $TARGET_DIR foot

# Verify configuration was installed
if test -f "$TARGET_DIR/.config/foot/foot.ini"
    echo "✅ Foot configuration installed"
else
    echo "❌ Failed to install Foot configuration"
    exit 1
end

# Set Foot as default terminal for Wayland
echo "→ Configuring Foot as default terminal"

# Create desktop entry override if needed
mkdir -p ~/.config/mimeapps.list.d
printf "%s\n" \
    "[Default Applications]" \
    "x-scheme-handler/terminal=foot.desktop" \
    "application/x-terminal-emulator=foot.desktop" > ~/.config/mimeapps.list

# Set environment variable for terminal applications
printf "%s\n" \
    "" \
    "# Default terminal for GUI applications" \
    "set -gx TERMINAL foot" >> ~/.config/fish/config.fish

echo ""
echo "✅ Foot terminal setup complete!"
echo ""
echo "🎯 Features configured:"
echo "  🦶 Foot terminal with Wayland support"
echo "  🔤 Hack Nerd Font with icon support"
echo "  🎨 Color scheme matching Wezterm"
echo "  ⌨️  Copy/paste: Ctrl+Shift+C/V or Alt+C/V"
echo "  🔍 Search: Ctrl+Shift+F"
echo "  📖 URL mode: Ctrl+Shift+U"
echo "  🔀 Spawn new terminal: Ctrl+Shift+N"
echo ""
echo "💡 Tip: Font changes require restarting Foot"