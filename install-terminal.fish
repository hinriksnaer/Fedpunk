#!/usr/bin/env fish

echo "🐟 Fedpunk Terminal Setup"
echo "========================="
echo "Installing Fish shell and essential terminal tools..."

# Initialize prerequisites first
echo "→ Setting up prerequisites"
if test -f "./scripts/init.sh"
    bash "./scripts/init.sh"
else
    echo "❌ Prerequisites script not found!"
    exit 1
end

# Install Fish first (required for everything else)
echo "→ Installing Fish shell"
if test -f "./scripts/install-fish.sh"
    bash "./scripts/install-fish.sh"
else
    echo "❌ Fish installer not found!"
    exit 1
end

# Verify Fish installation
if not command -v fish >/dev/null 2>&1
    echo "❌ Fish installation failed!"
    exit 1
end

echo "✅ Fish installed successfully!"

# Terminal-focused installers
set terminal_tools \
  btop \
  lazygit \
  neovim \
  tmux

echo ""
echo "→ Installing terminal tools..."

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

# Install all terminal tools
for tool in $terminal_tools
    run_installer $tool
end

echo ""
echo "✅ Terminal setup complete!"
echo ""
echo "🎯 What's installed:"
echo "  🐟 Fish shell with Starship prompt"
echo "  📊 btop - Resource monitor"
echo "  🌊 lazygit - Git terminal UI"
echo "  ✏️  Neovim - Modern text editor"
echo "  🪟 tmux - Terminal multiplexer"
echo ""
echo "🚀 Next steps:"
echo "  • Restart your terminal or run: exec fish"
echo "  • Run 'install-desktop.fish' for Hyprland desktop environment"
echo "  • Type 'nvim' to start configuring Neovim"