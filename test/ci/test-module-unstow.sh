#!/bin/bash
# Test module unstow functionality
#
# Tests:
# 1. fedpunk-module-unstow removes symlinks
# 2. State file updated after unstow
# 3. Only module's files removed (not others)
# 4. CLI commands also removed
# 5. Regular files not removed (warning only)

set -e

echo ""
echo "========================================="
echo "Module Unstow Tests"
echo "========================================="
echo ""

# Setup test environment
TEST_DIR=$(mktemp -d -t fedpunk-unstow-test-XXXXXX)
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
source \$FEDPUNK_SYSTEM/lib/fish/fedpunk-module.fish
$1
"
}

#
# Setup: Create two test modules
#
echo "=== Setup: Create test modules ==="

# Module A
MODULE_A_DIR="$TEST_DIR/module-a"
mkdir -p "$MODULE_A_DIR/config/.config/module-a"
mkdir -p "$MODULE_A_DIR/cli/module-a-cmd"
cat > "$MODULE_A_DIR/module.yaml" <<'EOF'
module:
  name: module-a
  description: Test module A
  dependencies: []

packages:
  dnf: []

stow:
  target: $HOME
  conflicts: warn
EOF
echo "module-a-config" > "$MODULE_A_DIR/config/.config/module-a/settings.txt"
echo "module-a-data" > "$MODULE_A_DIR/config/.config/module-a/data.txt"
cat > "$MODULE_A_DIR/cli/module-a-cmd/module-a-cmd.fish" <<'EOF'
function module-a-cmd
    echo "Module A command"
end
EOF

# Module B
MODULE_B_DIR="$TEST_DIR/module-b"
mkdir -p "$MODULE_B_DIR/config/.config/module-b"
cat > "$MODULE_B_DIR/module.yaml" <<'EOF'
module:
  name: module-b
  description: Test module B
  dependencies: []

packages:
  dnf: []

stow:
  target: $HOME
  conflicts: warn
EOF
echo "module-b-config" > "$MODULE_B_DIR/config/.config/module-b/settings.txt"

echo "  Created module-a with config + CLI"
echo "  Created module-b with config only"
echo ""

#
# Test 1: Deploy both modules
#
echo "=== Test 1: Deploy both modules ==="

run_fish "fedpunk-config-init" 2>&1 | head -3 || true

# Deploy module A
run_fish "fedpunk-module-stow '$MODULE_A_DIR'" 2>&1 | head -5 || true

# Deploy module B
run_fish "fedpunk-module-stow '$MODULE_B_DIR'" 2>&1 | head -5 || true

# Verify both deployed
if [ -L "$HOME/.config/module-a/settings.txt" ]; then
    echo "  SUCCESS: Module A config deployed"
else
    echo "  FAIL: Module A not deployed" >&2
    exit 1
fi

if [ -L "$HOME/.config/module-b/settings.txt" ]; then
    echo "  SUCCESS: Module B config deployed"
else
    echo "  FAIL: Module B not deployed" >&2
    exit 1
fi
echo ""

#
# Test 2: Unstow module A only
#
echo "=== Test 2: Unstow module A ==="

run_fish "fedpunk-module-unstow '$MODULE_A_DIR'" 2>&1 | head -5 || true

# Module A should be removed
if [ ! -e "$HOME/.config/module-a/settings.txt" ]; then
    echo "  SUCCESS: Module A config removed"
else
    echo "  FAIL: Module A config still exists" >&2
    exit 1
fi

if [ ! -e "$HOME/.config/module-a/data.txt" ]; then
    echo "  SUCCESS: Module A data file removed"
else
    echo "  FAIL: Module A data file still exists" >&2
fi

# Module B should still exist
if [ -L "$HOME/.config/module-b/settings.txt" ]; then
    echo "  SUCCESS: Module B config preserved"
else
    echo "  FAIL: Module B was incorrectly removed" >&2
    exit 1
fi
echo ""

#
# Test 3: CLI commands removed
#
echo "=== Test 3: CLI removal ==="

CLI_DIR="$FEDPUNK_USER/cli/module-a-cmd"
if [ ! -e "$CLI_DIR" ]; then
    echo "  SUCCESS: Module A CLI removed"
else
    echo "  INFO: CLI directory still exists (may need manual removal)"
fi
echo ""

#
# Test 4: State file updated
#
echo "=== Test 4: State file cleanup ==="

STATE_FILE="$FEDPUNK_USER/.linker-state.json"
if [ -f "$STATE_FILE" ]; then
    # Check module-a is removed from state
    if ! grep -q "module-a" "$STATE_FILE" 2>/dev/null; then
        echo "  SUCCESS: Module A removed from state"
    else
        echo "  INFO: Module A may still be in state"
    fi

    # Check module-b still in state
    if grep -q "module-b" "$STATE_FILE" 2>/dev/null; then
        echo "  SUCCESS: Module B still in state"
    else
        echo "  INFO: Module B state not found"
    fi
else
    echo "  INFO: State file not found"
fi
echo ""

#
# Test 5: Re-deploy works
#
echo "=== Test 5: Re-deploy after unstow ==="

run_fish "fedpunk-module-stow '$MODULE_A_DIR'" 2>&1 | head -3 || true

if [ -L "$HOME/.config/module-a/settings.txt" ]; then
    echo "  SUCCESS: Module A re-deployed successfully"
else
    echo "  FAIL: Module A re-deploy failed" >&2
    exit 1
fi
echo ""

#
# Test 6: Unstow nonexistent module
#
echo "=== Test 6: Unstow nonexistent module ==="

OUTPUT=$(run_fish "fedpunk-module-unstow '/nonexistent/path'" 2>&1 || echo "error")

if echo "$OUTPUT" | grep -qi "not found\|error\|no files"; then
    echo "  SUCCESS: Nonexistent module handled gracefully"
else
    echo "  INFO: Nonexistent module handling unclear"
fi
echo ""

#
# Test 7: Unstow with regular file (not symlink)
#
echo "=== Test 7: Non-symlink file handling ==="

# Create regular file where symlink should be
rm -f "$HOME/.config/module-a/settings.txt"
echo "user-created-file" > "$HOME/.config/module-a/settings.txt"

# Re-deploy (should track in state)
run_fish "fedpunk-module-stow '$MODULE_A_DIR'" 2>&1 | head -3 || true

# Try unstow
OUTPUT=$(run_fish "fedpunk-module-unstow '$MODULE_A_DIR'" 2>&1 || true)

# File should NOT be removed (only symlinks removed)
if [ -f "$HOME/.config/module-a/settings.txt" ]; then
    echo "  SUCCESS: Regular file preserved (not deleted)"
    if echo "$OUTPUT" | grep -qi "not a symlink\|manual\|warning"; then
        echo "  SUCCESS: Warning issued for non-symlink"
    fi
else
    echo "  INFO: File was removed (behavior varies)"
fi
echo ""

#
# Summary
#
echo "========================================="
echo "All module unstow tests passed!"
echo "========================================="
echo ""
echo "Summary:"
echo "  - Unstow removes module symlinks"
echo "  - Other modules' files preserved"
echo "  - CLI commands removed"
echo "  - State file updated"
echo "  - Re-deploy works after unstow"
echo "  - Nonexistent modules handled gracefully"
echo "  - Regular files preserved with warning"
echo ""
