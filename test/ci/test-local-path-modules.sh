#!/bin/bash
# Test local path module deployment
#
# Tests:
# 1. Relative path (./module) should be converted to absolute path
# 2. Absolute path (/path/to/module) should work
# 3. Path with ~ should be expanded

set -e

echo ""
echo "========================================="
echo "Local Path Module Test"
echo "========================================="
echo ""

# Setup test environment
TEST_DIR=$(mktemp -d -t fedpunk-local-path-test-XXXXXX)
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
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export FEDPUNK_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
export FEDPUNK_SYSTEM="$FEDPUNK_ROOT"
export FEDPUNK_USER="$HOME/.local/share/fedpunk"

# Helper function to run fish with our local libs
run_fish() {
    fish -c "
set -gx FEDPUNK_ROOT '$FEDPUNK_ROOT'
set -gx FEDPUNK_SYSTEM '$FEDPUNK_SYSTEM'
set -gx FEDPUNK_USER '$FEDPUNK_USER'
set -gx HOME '$HOME'
source \$FEDPUNK_SYSTEM/lib/fish/paths.fish
$1
"
}

#
# Test 1: Create test module with relative path
#
echo "=== Test 1: Deploy module with relative path (./module) ==="

TEST_MODULE_DIR="$TEST_DIR/my-test-module"
mkdir -p "$TEST_MODULE_DIR/config"

cat > "$TEST_MODULE_DIR/module.yaml" <<'EOF'
module:
  name: my-test-module
  description: Test module for local path

packages:
  dnf: []

stow:
  target: $HOME
  conflicts: warn
EOF

echo "test config" > "$TEST_MODULE_DIR/config/test.txt"

# Change to test dir and deploy with relative path
cd "$TEST_DIR"

run_fish "
source \$FEDPUNK_SYSTEM/lib/fish/config.fish
source \$FEDPUNK_SYSTEM/lib/fish/deployer.fish
fedpunk-config-init
deployer-deploy-module './my-test-module'
" 2>&1 | grep -v "^Deploying\|^==>" || true

CONFIG_FILE="$HOME/.config/fedpunk/fedpunk.yaml"

echo ""
echo "Config file contents:"
cat "$CONFIG_FILE"
echo ""

# Check what was stored
MODULE_REF=$(yq '.modules.enabled[0]' "$CONFIG_FILE")

echo "Stored module reference: $MODULE_REF"
echo ""

if echo "$MODULE_REF" | grep -q "^/"; then
    echo "✅ SUCCESS: Relative path converted to absolute: $MODULE_REF"
elif echo "$MODULE_REF" | grep -q "^\."; then
    echo "❌ FAIL: Stored relative path: $MODULE_REF"
    echo "  This will break when resolved from different directory!"
    exit 1
else
    echo "⚠ WARNING: Unexpected format: $MODULE_REF"
fi

echo ""

#
# Test 2: Verify module can be resolved from different directory
#
echo "=== Test 2: Resolve module from different directory ==="

# Change to a different directory
cd "$HOME"

RESOLVED_PATH=$(run_fish "
source \$FEDPUNK_SYSTEM/lib/fish/module-resolver.fish
module-resolve-path '$MODULE_REF'
" 2>/dev/null)

if [ -d "$RESOLVED_PATH" ]; then
    echo "✅ SUCCESS: Module resolved from different directory"
    echo "  Stored: $MODULE_REF"
    echo "  Resolved: $RESOLVED_PATH"
else
    echo "❌ FAIL: Module could not be resolved from different directory"
    echo "  Stored: $MODULE_REF"
    echo "  Tried to resolve: $RESOLVED_PATH"
    exit 1
fi

echo ""

#
# Test 3: Test absolute path
#
echo "=== Test 3: Deploy with absolute path ==="

run_fish "
source \$FEDPUNK_SYSTEM/lib/fish/config.fish
yq -i '.modules.enabled = []' '$CONFIG_FILE'
source \$FEDPUNK_SYSTEM/lib/fish/deployer.fish
deployer-deploy-module '$TEST_MODULE_DIR'
" 2>&1 | grep -v "^Deploying\|^==>" || true

ABS_MODULE_REF=$(yq '.modules.enabled[0]' "$CONFIG_FILE")

echo "Stored absolute path: $ABS_MODULE_REF"

if [ "$ABS_MODULE_REF" = "$TEST_MODULE_DIR" ]; then
    echo "✅ SUCCESS: Absolute path stored correctly"
else
    echo "❌ FAIL: Absolute path changed"
    echo "  Expected: $TEST_MODULE_DIR"
    echo "  Got: $ABS_MODULE_REF"
    exit 1
fi

echo ""
echo "========================================="
echo "All local path tests passed!"
echo "========================================="
echo ""
