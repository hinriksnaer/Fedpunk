#!/usr/bin/env fish
# Deploy configuration files

echo "→ Deploying configuration files"

# Initialize git submodules
echo "  • Initializing git submodules"
cd "$FEDPUNK_PATH"
git submodule sync --recursive
git submodule update --init --recursive

# Use GNU Stow to deploy configs
echo "  • Deploying configs with stow"
cd "$FEDPUNK_PATH"

# Stow all config directories
for config_dir in config/*/
    if test -d "$config_dir"
        set config_name (basename "$config_dir")
        echo "    - Stowing $config_name"
        stow -d config -t ~ "$config_name" 2>/dev/null; or true
    end
end

# Link bin directory
echo "  • Linking bin scripts"
mkdir -p "$HOME/.local/bin"
stow -d . -t "$HOME/.local" bin 2>/dev/null; or true

echo "✅ Configuration deployment complete"
