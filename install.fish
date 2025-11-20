#!/usr/bin/env fish
# Fedpunk Installer
# Orchestrates module deployment using profile/mode configuration

# Get the directory where this script is located (works regardless of cwd)
set -l script_dir (dirname (status -f))
set -gx FEDPUNK_ROOT (realpath "$script_dir")

# Verify installer library exists
if not test -f "$FEDPUNK_ROOT/lib/fish/installer.fish"
    echo "Error: Could not find installer library at $FEDPUNK_ROOT/lib/fish/installer.fish" >&2
    echo "Please ensure you're running from a complete Fedpunk installation" >&2
    exit 1
end

# Source installer library (use absolute path)
source "$FEDPUNK_ROOT/lib/fish/installer.fish"

# Run installer with arguments
installer-run $argv
