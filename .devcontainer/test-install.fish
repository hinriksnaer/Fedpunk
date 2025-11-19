#!/usr/bin/env fish
# Test script for fedpunk in container mode

echo "╔════════════════════════════════════════════╗"
echo "║   Fedpunk Container Mode Test             ║"
echo "╚════════════════════════════════════════════╝"
echo ""

# Set up environment
set -gx FEDPUNK_PATH /workspace
set -gx FEDPUNK_PROFILE "dev"
set -gx FEDPUNK_MODE "container"
set -gx FEDPUNK_NON_INTERACTIVE "true"

# Check for container indicators
echo "→ Container Detection:"
set container_detected false
if test -f /.dockerenv
    echo "  ✓ Found /.dockerenv"
    set container_detected true
end
if test -f /run/.containerenv
    echo "  ✓ Found /run/.containerenv"
    set container_detected true
end
if set -q CONTAINER
    echo "  ✓ CONTAINER env var is set"
    set container_detected true
end

if not $container_detected
    echo "  ⚠ No container indicators found (this is OK for testing)"
end
echo ""

# Install chezmoi if needed
echo "→ Setting up chezmoi:"
if not command -v chezmoi >/dev/null 2>&1
    echo "  Installing chezmoi..."
    mkdir -p $HOME/.local/bin
    set -gx PATH $HOME/.local/bin $PATH
    sh -c "(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
    echo "  ✓ Installed"
else
    echo "  ✓ Already installed"
end
echo ""

# Initialize chezmoi
echo "→ Initializing chezmoi:"
cd "$FEDPUNK_PATH"
chezmoi init --source="$FEDPUNK_PATH" 2>&1 | grep -v "chezmoi:" || true
echo "  ✓ Initialized with source=$FEDPUNK_PATH"
echo ""

# Show detected configuration
echo "→ Configuration:"
cat ~/.config/chezmoi/chezmoi.toml
echo ""

# Show profile info
echo "→ Profile Information:"
set profile_path "$FEDPUNK_PATH/profiles/$FEDPUNK_PROFILE"
if test -d "$profile_path"
    echo "  Profile: $FEDPUNK_PROFILE"
    echo "  Path: $profile_path"

    if test -f "$profile_path/fedpunk.yaml"
        echo "  Manifest: Found"
    end

    if test -d "$profile_path/install"
        set script_count (count $profile_path/install/*.fish 2>/dev/null)
        echo "  Install scripts: $script_count"
    end
else
    echo "  ✗ Profile not found at: $profile_path"
end
echo ""

# Show what files would be deployed
echo "→ Files to be deployed:"
set file_count (chezmoi managed | wc -l)
echo "  Total managed files: $file_count"
echo ""
echo "  Sample files:"
chezmoi managed | head -10
if test $file_count -gt 10
    echo "  ... and "(math $file_count - 10)" more"
end
echo ""

# Dry run
echo "→ Testing chezmoi apply (dry-run):"
set dry_run_output (chezmoi apply --dry-run 2>&1)
if test $status -eq 0
    echo "  ✓ Dry-run successful"
    set change_count (echo "$dry_run_output" | grep -c "^diff" || echo "0")
    echo "  Changes to apply: $change_count"
else
    echo "  ✗ Dry-run failed"
    echo "$dry_run_output"
end
echo ""

echo "╔════════════════════════════════════════════╗"
echo "║   Test Summary                             ║"
echo "╚════════════════════════════════════════════╝"
echo ""
echo "Profile: $FEDPUNK_PROFILE"
echo "Mode: $FEDPUNK_MODE"
echo "Source: $FEDPUNK_PATH"
echo ""
echo "Next steps:"
echo "  1. Review the output above"
echo "  2. Run: chezmoi apply"
echo "  3. Run profile install scripts manually if needed:"
echo "     cd $profile_path/install"
echo "     for script in *.fish; fish \$script; end"
echo ""
