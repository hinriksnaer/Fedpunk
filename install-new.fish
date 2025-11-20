#!/usr/bin/env fish
# Fedpunk Installer
# Orchestrates module deployment using profile/mode configuration

# Ensure we're running from the correct directory
if not test -f (status dirname)/lib/fish/installer.fish
    echo "Error: Must run from Fedpunk repository root" >&2
    exit 1
end

# Set FEDPUNK_ROOT to current directory
set -gx FEDPUNK_ROOT (pwd)

# Source installer library
source lib/fish/installer.fish

# Run installer with arguments
installer-run $argv
