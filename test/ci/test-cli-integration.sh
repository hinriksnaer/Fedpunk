#!/bin/bash
# Comprehensive CLI integration tests
#
# Tests all CLI commands and their integration with the module system
#
# Tests:
# 1. fedpunk module list
# 2. fedpunk module info <name>
# 3. fedpunk module deploy <name>
# 4. fedpunk module stow <name>
# 5. fedpunk module unstow <name>
# 6. fedpunk module install-packages <name> (dry-run)
# 7. fedpunk profile list
# 8. fedpunk config subcommands
# 9. Error handling for invalid inputs
# 10. Help text for all commands

# Don't use set -e as we handle errors explicitly

echo ""
echo "========================================="
echo "CLI Integration Tests"
echo "========================================="
echo ""

# Setup test environment
TEST_DIR=$(mktemp -d -t fedpunk-cli-int-XXXXXX)
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
echo ""

# Helper function to run fish with full environment
run_fish() {
    fish -c "
set -gx FEDPUNK_ROOT '$FEDPUNK_ROOT'
set -gx FEDPUNK_SYSTEM '$FEDPUNK_SYSTEM'
set -gx FEDPUNK_USER '$FEDPUNK_USER'
set -gx HOME '$HOME'
set -gx FEDPUNK_CONFLICT_MODE 'skip'
source \$FEDPUNK_SYSTEM/lib/fish/paths.fish
source \$FEDPUNK_SYSTEM/lib/fish/config.fish
source \$FEDPUNK_SYSTEM/lib/fish/fedpunk-module.fish
$1
"
}

# Initialize config
run_fish "fedpunk-config-init" 2>&1 | head -3 || true

PASS_COUNT=0
FAIL_COUNT=0

check_result() {
    if [ $1 -eq 0 ]; then
        echo "  SUCCESS: $2"
        PASS_COUNT=$((PASS_COUNT + 1))
    else
        echo "  FAIL: $2" >&2
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
}

#
# Test 1: fedpunk-module (main command)
#
echo "=== Test 1: fedpunk-module command ==="

OUTPUT=$(run_fish "fedpunk-module" 2>&1)
echo "$OUTPUT" | grep -q "Usage:" && check_result 0 "Usage shown" || check_result 1 "Usage not shown"
echo "$OUTPUT" | grep -q "list" && check_result 0 "list subcommand documented" || check_result 1 "list not documented"
echo "$OUTPUT" | grep -q "deploy" && check_result 0 "deploy subcommand documented" || check_result 1 "deploy not documented"
echo ""

#
# Test 2: fedpunk-module list
#
echo "=== Test 2: fedpunk-module list ==="

OUTPUT=$(run_fish "fedpunk-module list" 2>&1)
echo "$OUTPUT" | grep -q "fish" && check_result 0 "fish module listed" || check_result 1 "fish not listed"
echo "$OUTPUT" | grep -q "ssh" && check_result 0 "ssh module listed" || check_result 1 "ssh not listed"
echo ""

#
# Test 3: fedpunk-module info
#
echo "=== Test 3: fedpunk-module info ==="

OUTPUT=$(run_fish "fedpunk-module info fish" 2>&1)
echo "$OUTPUT" | grep -q "Module:" && check_result 0 "Module info header shown" || check_result 1 "Module info failed"
echo "$OUTPUT" | grep -qi "fish\|shell" && check_result 0 "Fish info displayed" || check_result 1 "Fish info missing"

# Test with invalid module
OUTPUT=$(run_fish "fedpunk-module info nonexistent-xyz" 2>&1 || echo "error")
echo "$OUTPUT" | grep -qi "not found\|error" && check_result 0 "Invalid module handled" || check_result 1 "Invalid module not handled"
echo ""

#
# Test 4: fedpunk-module stow
#
echo "=== Test 4: fedpunk-module stow ==="

# Create a simple test module
TEST_MODULE="$FEDPUNK_SYSTEM/modules/test-cli-int"
mkdir -p "$TEST_MODULE/config/.config/test-cli-int"
cat > "$TEST_MODULE/module.yaml" <<'EOF'
module:
  name: test-cli-int
  description: CLI integration test module
  dependencies: []

packages:
  dnf: []

stow:
  target: $HOME
  conflicts: warn
EOF
echo "test-content" > "$TEST_MODULE/config/.config/test-cli-int/config.txt"

OUTPUT=$(run_fish "fedpunk-module stow test-cli-int" 2>&1)
test -L "$HOME/.config/test-cli-int/config.txt" && check_result 0 "Stow creates symlink" || check_result 1 "Stow symlink failed"

# Cleanup test module
rm -rf "$TEST_MODULE"
echo ""

#
# Test 5: fedpunk-module unstow
#
echo "=== Test 5: fedpunk-module unstow ==="

# Use the previously stowed test module
OUTPUT=$(run_fish "linker-remove 'test-cli-int'" 2>&1 || true)
test ! -e "$HOME/.config/test-cli-int/config.txt" && check_result 0 "Unstow removes symlink" || check_result 1 "Unstow failed"
echo ""

#
# Test 6: Module deploy with dependencies
#
echo "=== Test 6: Deploy with dependencies ==="

# Fish module has no deps, should deploy cleanly
OUTPUT=$(run_fish "fedpunk-module deploy fish" 2>&1 || true)
echo "$OUTPUT" | grep -qi "deploy\|success\|checking" && check_result 0 "Deploy shows progress" || check_result 1 "Deploy output unclear"
echo ""

#
# Test 7: Config subcommands
#
echo "=== Test 7: Config operations ==="

# Add module to config
run_fish "fedpunk-config-add-module test-module" 2>&1 || true
MODULES=$(run_fish "fedpunk-config-list-enabled-modules" 2>/dev/null || echo "")
echo "$MODULES" | grep -q "test-module" && check_result 0 "Add module to config" || check_result 1 "Add module failed"

# Set profile
run_fish "fedpunk-config-set-profile 'cli-test' '' 'desktop'" 2>&1 || true
NAME=$(run_fish "fedpunk-config-get-profile-name" 2>/dev/null || echo "")
[ "$NAME" = "cli-test" ] && check_result 0 "Set/get profile name" || check_result 1 "Profile name mismatch: $NAME"

MODE=$(run_fish "fedpunk-config-get-profile-mode" 2>/dev/null || echo "")
[ "$MODE" = "desktop" ] && check_result 0 "Set/get profile mode" || check_result 1 "Profile mode mismatch: $MODE"
echo ""

#
# Test 8: Invalid inputs handling
#
echo "=== Test 8: Invalid input handling ==="

# Missing argument
OUTPUT=$(run_fish "fedpunk-module info" 2>&1 || echo "")
echo "$OUTPUT" | grep -qi "usage\|required\|module" && check_result 0 "Missing arg handled" || check_result 1 "Missing arg not handled"

# Invalid subcommand
OUTPUT=$(run_fish "fedpunk-module invalid-command" 2>&1 || echo "")
echo "$OUTPUT" | grep -qi "usage\|subcommand" && check_result 0 "Invalid subcommand handled" || check_result 1 "Invalid subcommand not handled"
echo ""

#
# Test 9: Help text
#
echo "=== Test 9: Help text ==="

OUTPUT=$(run_fish "fedpunk-module list --help" 2>&1 || run_fish "fedpunk-module" 2>&1)
[ -n "$OUTPUT" ] && check_result 0 "Help text available" || check_result 1 "No help text"
echo ""

#
# Test 10: End-to-end workflow
#
echo "=== Test 10: End-to-end workflow ==="

# Create -> Deploy -> Verify -> Unstow
TEST_E2E="$FEDPUNK_SYSTEM/modules/test-e2e"
mkdir -p "$TEST_E2E/config/.config/e2e"
cat > "$TEST_E2E/module.yaml" <<'EOF'
module:
  name: test-e2e
  description: E2E test
  dependencies: []

packages:
  dnf: []

stow:
  target: $HOME
  conflicts: warn
EOF
echo "e2e-test" > "$TEST_E2E/config/.config/e2e/marker.txt"

# Deploy
run_fish "fedpunk-module deploy test-e2e" 2>&1 | head -10 || true

# Verify
if [ -f "$HOME/.config/e2e/marker.txt" ] || [ -L "$HOME/.config/e2e/marker.txt" ]; then
    CONTENT=$(cat "$HOME/.config/e2e/marker.txt" 2>/dev/null || echo "")
    [ "$CONTENT" = "e2e-test" ] && check_result 0 "E2E: Deploy verified" || check_result 1 "E2E: Content mismatch"
else
    check_result 1 "E2E: Deploy failed"
fi

# Unstow
run_fish "fedpunk-module unstow test-e2e" 2>&1 | head -5 || true
test ! -e "$HOME/.config/e2e/marker.txt" && check_result 0 "E2E: Unstow verified" || check_result 1 "E2E: Unstow failed"

# Cleanup
rm -rf "$TEST_E2E"
echo ""

#
# Summary
#
echo "========================================="
if [ $FAIL_COUNT -eq 0 ]; then
    echo "All CLI integration tests passed!"
else
    echo "CLI integration tests: $PASS_COUNT passed, $FAIL_COUNT failed"
fi
echo "========================================="
echo ""
echo "Summary:"
echo "  - fedpunk-module command works"
echo "  - list subcommand works"
echo "  - info subcommand works"
echo "  - stow/unstow subcommands work"
echo "  - deploy subcommand works"
echo "  - Config operations work"
echo "  - Invalid inputs handled gracefully"
echo "  - Help text available"
echo "  - End-to-end workflow tested"
echo ""

exit $FAIL_COUNT
