#!/usr/bin/env fish
# Fedpunk Installer (Simplified wrapper for new deployment system)
# Use 'fedpunk deploy profile' instead

# Get the directory where this script is located
set -l script_dir (dirname (status -f))

# Source path detection library
if not test -f "$script_dir/lib/fish/paths.fish"
    echo "Error: Could not find paths library at $script_dir/lib/fish/paths.fish" >&2
    echo "Please ensure you're running from a complete Fedpunk installation" >&2
    exit 1
end
source "$script_dir/lib/fish/paths.fish"

# Ensure user space exists
fedpunk-ensure-user-space

# Source deployer library
if not test -f "$FEDPUNK_SYSTEM/lib/fish/deployer.fish"
    echo "Error: Could not find deployer library at $FEDPUNK_SYSTEM/lib/fish/deployer.fish" >&2
    exit 1
end
source "$FEDPUNK_SYSTEM/lib/fish/deployer.fish"

# Show deprecation notice
echo "╔════════════════════════════════════════════════════════╗"
echo "║  Fedpunk Installer                                     ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""
echo "Note: 'fedpunk install' is now a wrapper for:"
echo "  fedpunk deploy profile"
echo ""

# Deploy profile with provided arguments
deployer-deploy-profile $argv
