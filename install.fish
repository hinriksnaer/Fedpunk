#!/usr/bin/env fish

echo "🐟 Fedpunk Linux Setup"
echo "======================"
echo "Choose your installation type:"
echo ""

# Show menu options
echo "1. 🖥️  Full Setup (Terminal + Desktop)"
echo "2. 🐟 Terminal Only (Fish, Neovim, tmux, etc.)"
echo "3. 🪟 Desktop Only (Hyprland environment)"
echo "4. 🛠️  Custom (specify components)"
echo ""

# Check if arguments provided (skip menu)
if test (count $argv) -gt 0
    switch $argv[1]
        case "terminal" "1"
            fish "./install-terminal.fish"
            exit
        case "desktop" "2"
            fish "./install-desktop.fish"
            exit
        case "full" "3"
            echo "→ Running full setup..."
            fish "./install-terminal.fish"
            and fish "./install-desktop.fish"
            exit
        case "custom" "4"
            set components $argv[2..-1]
            # Fall through to custom logic below
        case '*'
            echo "❌ Invalid option: $argv[1]"
            echo "   Valid options: terminal, desktop, full, custom"
            exit 1
    end
else
    # Interactive menu
    read -P "Enter choice [1-4]: " choice
    
    switch $choice
        case "1"
            echo "→ Running full setup..."
            fish "./install-terminal.fish"
            and fish "./install-desktop.fish"
            exit
        case "2"
            fish "./install-terminal.fish"
            exit
        case "3"
            fish "./install-desktop.fish"
            exit
        case "4"
            echo "→ Custom installation mode"
            # Fall through to custom logic
        case '*'
            echo "❌ Invalid choice"
            exit 1
    end
end

# Custom installation logic
echo ""
echo "🛠️ Custom Installation"
echo "Available components:"

set all_components essentials btop bluetui lazygit neovim tmux claude foot hyprland walker firefox nvidia

for component in $all_components
    echo "  --$component"
end

if test (count $argv) -eq 1 -a "$argv[1]" = "custom"
    echo ""
    read -P "Enter components (e.g., --neovim --tmux --hyprland): " -a components
else if test "$argv[1]" = "custom"
    set components $argv[2..-1]
else
    set components $argv
end

# Initialize submodules
echo "→ Initializing git submodules"
git submodule sync --recursive
git submodule update --init --recursive

# Ensure Fish is available
if not command -v fish >/dev/null 2>&1
    echo "→ Installing Fish first..."
    if test -f "./scripts/init.sh"
        bash "./scripts/init.sh"
    end
    if test -f "./scripts/install-fish.sh"
        bash "./scripts/install-fish.sh"
    end
end

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

# Install selected components
for arg in $components
    switch $arg
        case '--*'
            set name (string sub -s 3 $arg)
            if contains $name $all_components
                run_installer $name
            else
                echo "⚠️ Unknown component: $arg"
                echo "   Available components: $all_components"
                echo "   Extracted name: '$name'"
            end
        case '*'
            echo "⚠️ Invalid format: $arg (use --component)"
    end
end

echo ""
echo "✅ Custom installation complete!"