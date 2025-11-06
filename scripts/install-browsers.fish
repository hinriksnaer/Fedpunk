#!/usr/bin/env fish

echo "🌐 Fedpunk Browser Selection"
echo "============================"

echo "Choose browsers to install:"
echo "1. 🦊 Firefox (default, already installed)"
echo "2. 🟦 Chromium (Google Chrome alternative)"
echo "3. 🦁 Brave (Privacy-focused)"
echo "4. 📱 All browsers"
echo ""

read -P "Enter choice [1-4]: " choice

function install_chromium
    echo "→ Installing Chromium"
    sudo dnf install -qy chromium chromium-freeworld
    
    # Configure Chromium for Wayland
    mkdir -p ~/.config/chromium-flags.conf
    echo "--enable-features=UseOzonePlatform --ozone-platform=wayland" > ~/.config/chromium-flags.conf
    
    echo "✅ Chromium installed with Wayland support"
end

function install_brave
    echo "→ Installing Brave Browser"
    
    # Add Brave repository
    sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo
    sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
    
    sudo dnf install -qy brave-browser
    
    # Configure Brave for Wayland
    mkdir -p ~/.config/brave-flags.conf
    echo "--enable-features=UseOzonePlatform --ozone-platform=wayland" > ~/.config/brave-flags.conf
    
    echo "✅ Brave Browser installed with Wayland support"
end

switch $choice
    case "1"
        echo "Firefox is already installed as default!"
    case "2"
        install_chromium
    case "3" 
        install_brave
    case "4"
        install_chromium
        install_brave
    case "*"
        echo "❌ Invalid choice"
        exit 1
end

echo ""
echo "🎯 Browser Summary:"
echo "  🦊 Firefox - Default browser with privacy focus"
if test "$choice" = "2" -o "$choice" = "4"
    echo "  🟦 Chromium - Open-source Chrome for web development"
end
if test "$choice" = "3" -o "$choice" = "4"
    echo "  🦁 Brave - Privacy-first with built-in ad blocking"
end
echo ""
echo "🚀 All browsers configured for optimal Wayland performance!"