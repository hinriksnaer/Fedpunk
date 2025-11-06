#!/usr/bin/env fish

echo "🚀 Fedpunk Dotfiles Installer (Fish)"
echo "======================================"

# Initialize submodules
echo "→ Initializing git submodules"
git submodule sync --recursive
git submodule update --init --recursive

# Available installers (Fish is implicit as prerequisite)
set installers \
  btop \
  lazygit \
  neovim \
  tmux \
  foot \
  hyprland \
  nvidia

# Helper function to run installer
function run_installer
    set name $argv[1]
    
    # Prefer Fish scripts (should always exist now)
    if test -f "./scripts/install-$name.fish"
        echo "→ Installing $name (using Fish)"
        fish "./scripts/install-$name.fish"
    else if test -f "./scripts/install-$name.sh"
        echo "→ Installing $name (using Bash fallback)"
        bash "./scripts/install-$name.sh"
    else
        echo "⚠️ No installer found for $name"
        return 1
    end
end

# Parse arguments
if test (count $argv) -eq 0
    # No arguments - install everything
    echo "→ No arguments provided, installing everything..."
    for name in $installers
        run_installer $name
    end
else
    # Selective installation
    for arg in $argv
        switch $arg
            case '--*'
                # Strip leading '--'
                set name (string sub -s 3 $arg)
                
                # Check if valid installer
                if contains $name $installers
                    run_installer $name
                else
                    echo "⚠️ Unknown option: $arg"
                    echo "   Valid options:"
                    for installer in $installers
                        echo "     --$installer"
                    end
                    exit 1
                end
            case '*'
                echo "⚠️ Unexpected argument: $arg"
                echo "   Use flags like --neovim, --tmux, etc."
                exit 1
        end
    end
end

echo ""
echo "✅ Installation complete!"
echo "   Don't forget to restart your shell or run: exec fish"