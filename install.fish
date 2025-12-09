#!/usr/bin/env fish
# Fedpunk Installer
# Orchestrates module deployment using profile/mode configuration

# Get the directory where this script is located (works regardless of cwd)
set -l script_dir (dirname (status -f))

# Source path detection library
if not test -f "$script_dir/lib/fish/paths.fish"
    echo "Error: Could not find paths library at $script_dir/lib/fish/paths.fish" >&2
    echo "Please ensure you're running from a complete Fedpunk installation" >&2
    exit 1
end
source "$script_dir/lib/fish/paths.fish"

# Auto-detect installation type and set up paths
# This sources paths.fish which runs fedpunk-setup-paths automatically
# Result: FEDPUNK_SYSTEM, FEDPUNK_USER, FEDPUNK_ROOT are now set

# Ensure user space exists (auto-creates on first run)
fedpunk-ensure-user-space

# Verify installer library exists
if not test -f "$FEDPUNK_SYSTEM/lib/fish/installer.fish"
    echo "Error: Could not find installer library at $FEDPUNK_SYSTEM/lib/fish/installer.fish" >&2
    echo "Please ensure you're running from a complete Fedpunk installation" >&2
    exit 1
end

# Source installer library (use absolute path)
source "$FEDPUNK_SYSTEM/lib/fish/installer.fish"

# Run installer with arguments
installer-run $argv
