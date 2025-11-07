#!/usr/bin/env fish

echo "🪟 Fedpunk Desktop Setup"
echo "========================="
echo "Installing Hyprland desktop environment and applications..."

# Verify Fish is available
if not command -v fish >/dev/null 2>&1
    echo "❌ Fish shell not found!"
    echo "   Please run 'install-terminal.fish' first"
    exit 1
end

# Desktop-focused installers
set desktop_tools \
  foot \
  hyprland \
  walker \
  firefox

# Optional components (ask user)
set optional_tools \
  nvidia

echo ""
echo "→ Installing desktop environment..."

# Helper function to run installer
function run_installer
    set name $argv[1]
    
    if test -f "./scripts/install-$name.fish"
        echo "→ Installing $name"
        fish "./scripts/install-$name.fish"
    else if test -f "./scripts/install-$name.sh"
        echo "→ Installing $name (bash fallback)"
        bash "./scripts/install-$name.sh"
    else
        echo "⚠️ No installer found for $name"
        return 1
    end
end

# Install desktop tools
for tool in $desktop_tools
    run_installer $tool
end

echo ""
echo "🔧 Optional components:"

# Ask about NVIDIA
if lspci | grep -i nvidia >/dev/null
    echo "🎮 NVIDIA GPU detected!"
    read -P "Install NVIDIA proprietary drivers? [y/N]: " nvidia_choice
    if test "$nvidia_choice" = "y" -o "$nvidia_choice" = "Y"
        run_installer nvidia
    end
else
    echo "ℹ️  No NVIDIA GPU detected, skipping NVIDIA drivers"
end

# Ask about additional browsers
echo ""
read -P "Install additional browsers (Chromium, Brave)? [y/N]: " browsers_choice
if test "$browsers_choice" = "y" -o "$browsers_choice" = "Y"
    fish "./scripts/install-browsers.fish"
end

echo ""
echo "✅ Desktop setup complete!"
echo ""
echo "🎯 What's installed:"
echo "  🪟 Hyprland - Wayland tiling compositor"
echo "  🦶 Foot - Fast Wayland terminal"
echo "  🚀 Walker - Application launcher"
echo "  🦊 Firefox - Default web browser"
echo "  🔔 Dunst - Notification daemon"
echo "  🎨 Desktop portals and authentication"
if lspci | grep -i nvidia >/dev/null; and test "$nvidia_choice" = "y" -o "$nvidia_choice" = "Y"
    echo "  🎮 NVIDIA proprietary drivers"
end
if test "$browsers_choice" = "y" -o "$browsers_choice" = "Y"
    echo "  🌐 Additional browsers (Chromium/Brave)"
end
echo ""
echo "🚀 Next steps:"
echo "  • Log out and select 'Hyprland' from your display manager"
echo "  • Or run 'Hyprland' from a TTY"
echo ""
echo "⌨️  Key bindings:"
echo "  Super+Q: Terminal  │  Super+R: Launcher  │  Super+C: Close"
echo "  Super+1-9: Workspaces  │  Print: Screenshot"
echo ""
echo "🐛 Troubleshooting:"
echo "  • Browser login issues: gh auth login --web=false"
echo "  • Check logs: journalctl -u display-manager"