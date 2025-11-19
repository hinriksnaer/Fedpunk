#!/usr/bin/env fish
# ============================================================================
# DEV SETUP: Run development environment setup scripts
# ============================================================================
# Purpose:
#   - Set up Neovim MCP integration
#   - Configure podman for rootless containers
#   - Set up devcontainer support
#   - Install Bitwarden CLI
#   - Configure Claude integration
# Runs: During installation (all modes)
# ============================================================================

source "$FEDPUNK_PATH/lib/helpers.fish"

section "Development Environment Setup"

# List of setup scripts to run
set setup_scripts \
    "install-nvim-mcp.fish" \
    "setup-podman.fish" \
    "setup-devcontainer.fish" \
    "setup-bitwarden.fish" \
    "setup-claude.fish"

# Run each setup script
for script in $setup_scripts
    echo ""
    subsection "Running: $script"

    set script_path "$FEDPUNK_PATH/home/scripts/$script"
    if test -f "$script_path"
        step "Executing $script" "fish $script_path"
    else
        warning "Script not found: $script_path (skipping)"
    end
end

echo ""
box "Development Environment Ready!" $GUM_SUCCESS
