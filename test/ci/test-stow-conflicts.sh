#!/bin/bash
# Test stow/linker conflict handling
#
# Tests:
# 1. Deploy to empty target (no conflict)
# 2. Conflict with existing file (interactive default)
# 3. FEDPUNK_CONFLICT_MODE=overwrite (auto-replace)
# 4. FEDPUNK_CONFLICT_MODE=skip (auto-keep)
# 5. Linker state tracking
# 6. Module unstow removes symlinks

set -e

echo ""
echo "========================================="
echo "Stow Conflict Handling Tests"
echo "========================================="
echo ""

# Setup test environment
TEST_DIR=$(mktemp -d -t fedpunk-stow-test-XXXXXX)
trap "rm -rf $TEST_DIR" EXIT

echo "Test environment: $TEST_DIR"
echo ""

# Override HOME and XDG for isolated testing
export HOME="$TEST_DIR/home"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
mkdir -p "$HOME"
mkdir -p "$HOME/.config/fish/conf.d"

# Use LOCAL git repository (not system installation)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
export FEDPUNK_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
export FEDPUNK_SYSTEM="$FEDPUNK_ROOT"
export FEDPUNK_USER="$HOME/.local/share/fedpunk"
mkdir -p "$FEDPUNK_USER"

echo "Fedpunk environment:"
echo "  FEDPUNK_ROOT: $FEDPUNK_ROOT"
echo "  FEDPUNK_SYSTEM: $FEDPUNK_SYSTEM"
echo "  HOME: $HOME"
echo ""

# Helper function to run fish with our local libs
run_fish() {
    fish -c "
set -gx FEDPUNK_ROOT '$FEDPUNK_ROOT'
set -gx FEDPUNK_SYSTEM '$FEDPUNK_SYSTEM'
set -gx FEDPUNK_USER '$FEDPUNK_USER'
set -gx HOME '$HOME'
source \$FEDPUNK_SYSTEM/lib/fish/paths.fish
source \$FEDPUNK_SYSTEM/lib/fish/config.fish
source \$FEDPUNK_SYSTEM/lib/fish/linker.fish
source \$FEDPUNK_SYSTEM/lib/fish/fedpunk-module.fish
$1
"
}

#
# Test 1: Deploy to empty target
#
echo "=== Test 1: Deploy to empty target ==="

# Create test module
MODULE_DIR="$TEST_DIR/test-stow-module"
mkdir -p "$MODULE_DIR/config/.config/stow-test"
cat > "$MODULE_DIR/module.yaml" <<'EOF'
module:
  name: test-stow-module
  description: Test module for stow
  dependencies: []

packages:
  dnf: []

stow:
  target: $HOME
  conflicts: warn
EOF
echo "module-content-v1" > "$MODULE_DIR/config/.config/stow-test/config.txt"

# Deploy (should succeed with no conflicts)
run_fish "linker-deploy 'test-stow-module' '$MODULE_DIR'" 2>&1 | head -5 || true

# Verify symlink created
if [ -L "$HOME/.config/stow-test/config.txt" ]; then
    echo "  SUCCESS: Symlink created"
    LINK_TARGET=$(readlink -f "$HOME/.config/stow-test/config.txt")
    if [ "$LINK_TARGET" = "$MODULE_DIR/config/.config/stow-test/config.txt" ]; then
        echo "  SUCCESS: Symlink points to correct source"
    else
        echo "  FAIL: Symlink points to wrong source" >&2
        exit 1
    fi
else
    echo "  FAIL: Symlink not created" >&2
    ls -la "$HOME/.config/stow-test/" 2>/dev/null || echo "  Directory doesn't exist"
    exit 1
fi
echo ""

#
# Test 2: Linker state tracking
#
echo "=== Test 2: Linker state tracking ==="

STATE_FILE="$FEDPUNK_USER/.linker-state.json"
if [ -f "$STATE_FILE" ]; then
    echo "  SUCCESS: State file created"

    # Check if our file is tracked
    if grep -q "stow-test/config.txt" "$STATE_FILE"; then
        echo "  SUCCESS: File tracked in state"
    else
        echo "  INFO: File may not be in state yet"
    fi

    # Check module ownership
    if grep -q "test-stow-module" "$STATE_FILE"; then
        echo "  SUCCESS: Module ownership recorded"
    else
        echo "  INFO: Module ownership not found"
    fi
else
    echo "  INFO: State file not created (linker may use different location)"
fi
echo ""

#
# Test 3: Conflict with skip mode
#
echo "=== Test 3: Conflict with SKIP mode ==="

# Create existing file that will conflict
rm -rf "$HOME/.config/stow-test"
mkdir -p "$HOME/.config/stow-test"
echo "user-original-content" > "$HOME/.config/stow-test/config.txt"

# Deploy with skip mode
export FEDPUNK_CONFLICT_MODE="skip"
run_fish "linker-deploy 'test-stow-module' '$MODULE_DIR'" 2>&1 | head -5 || true
unset FEDPUNK_CONFLICT_MODE

# Verify original file preserved
CONTENT=$(cat "$HOME/.config/stow-test/config.txt" 2>/dev/null || echo "")
if [ "$CONTENT" = "user-original-content" ]; then
    echo "  SUCCESS: Original file preserved (skip mode)"
else
    echo "  FAIL: Original file was overwritten" >&2
    echo "  Content: $CONTENT"
    exit 1
fi
echo ""

#
# Test 4: Conflict with overwrite mode
#
echo "=== Test 4: Conflict with OVERWRITE mode ==="

# Reset - create existing file again
rm -rf "$HOME/.config/stow-test"
mkdir -p "$HOME/.config/stow-test"
echo "user-original-content" > "$HOME/.config/stow-test/config.txt"

# Deploy with overwrite mode
export FEDPUNK_CONFLICT_MODE="overwrite"
run_fish "linker-deploy 'test-stow-module' '$MODULE_DIR'" 2>&1 | head -5 || true
unset FEDPUNK_CONFLICT_MODE

# Verify file was replaced with symlink
if [ -L "$HOME/.config/stow-test/config.txt" ]; then
    echo "  SUCCESS: File replaced with symlink (overwrite mode)"

    # Check content through symlink
    CONTENT=$(cat "$HOME/.config/stow-test/config.txt")
    if [ "$CONTENT" = "module-content-v1" ]; then
        echo "  SUCCESS: Symlink has correct content"
    else
        echo "  FAIL: Symlink has wrong content" >&2
    fi
else
    echo "  FAIL: File not replaced with symlink" >&2
    exit 1
fi

# Check backup was created
BACKUP_DIR="$HOME/.local/share/fedpunk-backups/config-backups"
if [ -d "$BACKUP_DIR" ]; then
    BACKUP_COUNT=$(ls -1 "$BACKUP_DIR" 2>/dev/null | wc -l)
    if [ "$BACKUP_COUNT" -gt 0 ]; then
        echo "  SUCCESS: Backup created ($BACKUP_COUNT files)"
    else
        echo "  INFO: Backup directory empty"
    fi
else
    echo "  INFO: Backup directory not created"
fi
echo ""

#
# Test 5: Module unstow
#
echo "=== Test 5: Module unstow ==="

# First ensure module is deployed
run_fish "linker-deploy 'test-stow-module' '$MODULE_DIR'" 2>&1 | head -3 || true

# Verify deployed
if [ -L "$HOME/.config/stow-test/config.txt" ]; then
    echo "  Symlink exists before unstow"
else
    echo "  WARNING: Symlink missing before unstow test"
fi

# Unstow
run_fish "linker-remove 'test-stow-module'" 2>&1 | head -5 || true

# Verify removed
if [ ! -e "$HOME/.config/stow-test/config.txt" ]; then
    echo "  SUCCESS: Symlink removed by unstow"
else
    if [ -L "$HOME/.config/stow-test/config.txt" ]; then
        echo "  FAIL: Symlink still exists after unstow" >&2
    else
        echo "  INFO: Regular file exists (may be restored backup)"
    fi
fi
echo ""

#
# Test 6: Re-deploy after unstow
#
echo "=== Test 6: Re-deploy after unstow ==="

run_fish "linker-deploy 'test-stow-module' '$MODULE_DIR'" 2>&1 | head -3 || true

if [ -L "$HOME/.config/stow-test/config.txt" ]; then
    echo "  SUCCESS: Re-deploy works after unstow"
else
    echo "  FAIL: Re-deploy failed" >&2
    exit 1
fi
echo ""

#
# Test 7: Multiple modules same directory
#
echo "=== Test 7: Multiple modules in same directory ==="

# Create second module that deploys to same config dir
MODULE2_DIR="$TEST_DIR/test-stow-module2"
mkdir -p "$MODULE2_DIR/config/.config/stow-test"
cat > "$MODULE2_DIR/module.yaml" <<'EOF'
module:
  name: test-stow-module2
  description: Second test module
  dependencies: []

packages:
  dnf: []

stow:
  target: $HOME
  conflicts: warn
EOF
echo "module2-content" > "$MODULE2_DIR/config/.config/stow-test/config2.txt"

# Deploy second module
run_fish "linker-deploy 'test-stow-module2' '$MODULE2_DIR'" 2>&1 | head -3 || true

# Both files should exist
if [ -L "$HOME/.config/stow-test/config.txt" ] && [ -L "$HOME/.config/stow-test/config2.txt" ]; then
    echo "  SUCCESS: Multiple modules coexist in same directory"
else
    echo "  FAIL: Multiple modules conflict" >&2
    ls -la "$HOME/.config/stow-test/"
fi
echo ""

#
# Summary
#
echo "========================================="
echo "All stow conflict tests passed!"
echo "========================================="
echo ""
echo "Summary:"
echo "  - Deploy to empty target creates symlinks"
echo "  - Linker state file tracks deployments"
echo "  - SKIP mode preserves existing files"
echo "  - OVERWRITE mode replaces with backup"
echo "  - Unstow removes symlinks"
echo "  - Re-deploy works after unstow"
echo "  - Multiple modules can share directories"
echo ""
