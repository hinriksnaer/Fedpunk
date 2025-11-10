#!/usr/bin/env fish
# Deploy configuration files

# Source helper functions
source "$FEDPUNK_INSTALL/helpers/all.fish"

section "Deploying Configuration"

# Initialize git submodules
run_quiet "Syncing git submodules" git submodule sync --recursive
run_quiet "Updating git submodules" git submodule update --init --recursive

# Use GNU Stow to deploy configs
info "Stowing configuration files"
cd "$FEDPUNK_PATH"

# Stow all config directories
# Use --restow to properly handle already-stowed packages
for config_dir in config/*/
    if test -d "$config_dir"
        set config_name (basename "$config_dir")
        run_quiet "Stowing $config_name" stow --restow -d config -t ~ "$config_name"
    end
end

# Link bin directory
run_quiet "Linking bin scripts" bash -c "mkdir -p $HOME/.local/bin && stow --restow -d $FEDPUNK_PATH -t $HOME/.local bin"

success "Configuration deployment complete"
