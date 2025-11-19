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
# Runs: After apply (development profile only)
# ============================================================================

source "$FEDPUNK_PROFILE_PATH/../base/lib/helpers.fish"

section "Development Environment Setup"

# List of setup scripts to run (from profile manifest)
set setup_scripts \
    "scripts/install-nvim-mcp.fish" \
    "scripts/setup-podman.fish" \
    "scripts/setup-devcontainer.fish" \
    "scripts/setup-bitwarden.fish" \
    "scripts/setup-claude.fish"

# Run each setup script
for script in $setup_scripts
    echo ""
    subsection "Running: $script"

    set script_path "$FEDPUNK_PROFILE_PATH/$script"
    if test -f "$script_path"
        step "Executing $script" "fish $script_path"
    else
        warning "Script not found: $script_path (skipping)"
    end
end

echo ""
box "Development Environment Ready!" $GUM_SUCCESS
