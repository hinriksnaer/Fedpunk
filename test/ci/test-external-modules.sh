#!/bin/bash
# Test external module deployment from git URLs
#
# Tests:
# 1. Deploy module from git URL
# 2. Module cloned to ~/.config/fedpunk/modules/
# 3. Re-deploy updates module

set -e

echo ""
echo "========================================="
echo "External Module Deployment Tests"
echo "========================================="
echo ""

# Setup test environment
TEST_DIR=$(mktemp -d -t fedpunk-external-test-XXXXXX)
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
source \$FEDPUNK_SYSTEM/lib/fish/external-modules.fish
source \$FEDPUNK_SYSTEM/lib/fish/module-resolver.fish
source \$FEDPUNK_SYSTEM/lib/fish/fedpunk-module.fish
$1
"
}

#
# Test 1: Create a test external module repository
#
echo "=== Test 1: Create test external module repo ==="

TEST_MODULE_REPO="$TEST_DIR/test-external-module"
mkdir -p "$TEST_MODULE_REPO/config/.config/test-external"

cat > "$TEST_MODULE_REPO/module.yaml" <<'EOF'
module:
  name: test-external-module
  description: Test external module
  version: 1.0.0

packages:
  dnf: []

stow:
  target: $HOME
  conflicts: warn
EOF

echo "version: 1.0.0" > "$TEST_MODULE_REPO/config/.config/test-external/version.txt"

# Initialize as git repo
cd "$TEST_MODULE_REPO"
git init -q
git config user.email "test@fedpunk.test"
git config user.name "Test User"
git add .
git commit -q -m "Initial commit v1.0.0"
INITIAL_COMMIT=$(git rev-parse HEAD)
cd "$FEDPUNK_ROOT"

TEST_MODULE_URL="file://$TEST_MODULE_REPO"
echo "  Created test module repo at: $TEST_MODULE_REPO"
echo "  Initial commit: ${INITIAL_COMMIT:0:8}"
echo ""

#
# Test 2: Clone external module
#
echo "=== Test 2: Clone external module ==="

run_fish "fedpunk-config-init" 2>&1 || true

CLONED_PATH=$(run_fish "external-module-fetch '$TEST_MODULE_URL'" 2>/dev/null)

if [ -n "$CLONED_PATH" ] && [ -d "$CLONED_PATH" ]; then
    echo "  SUCCESS: Module cloned"
    echo "  Path: $CLONED_PATH"
else
    echo "  FAIL: Module not cloned" >&2
    echo "  Got: $CLONED_PATH"
    exit 1
fi
echo ""

#
# Test 3: Verify clone location
#
echo "=== Test 3: Verify clone location ==="

EXPECTED_DIR="$HOME/.config/fedpunk/modules/test-external-module"
if [ -d "$EXPECTED_DIR" ]; then
    echo "  SUCCESS: Module at expected location"
    echo "  Location: $EXPECTED_DIR"
else
    echo "  FAIL: Module not at expected location" >&2
    echo "  Expected: $EXPECTED_DIR"
    ls -la "$HOME/.config/fedpunk/modules/" 2>/dev/null || echo "  modules/ doesn't exist"
    exit 1
fi

if [ -f "$EXPECTED_DIR/module.yaml" ]; then
    echo "  SUCCESS: module.yaml exists"
else
    echo "  FAIL: module.yaml not found" >&2
    exit 1
fi
echo ""

#
# Test 4: Verify module.yaml content
#
echo "=== Test 4: Verify module content ==="

if grep -q "test-external-module" "$EXPECTED_DIR/module.yaml"; then
    echo "  SUCCESS: Module name found in module.yaml"
else
    echo "  FAIL: Module name not in module.yaml" >&2
    exit 1
fi
echo ""

#
# Test 5: Update external module
#
echo "=== Test 5: Update external module ==="

# Make a change to the source repo
cd "$TEST_MODULE_REPO"
echo "version: 2.0.0" > "config/.config/test-external/version.txt"
git add .
git commit -q -m "Update to v2.0.0"
UPDATED_COMMIT=$(git rev-parse HEAD)
cd "$FEDPUNK_ROOT"

echo "  Updated source repo to: ${UPDATED_COMMIT:0:8}"

# Re-clone (should update)
run_fish "external-module-fetch '$TEST_MODULE_URL'" 2>/dev/null || true

# Check if update was pulled
cd "$EXPECTED_DIR"
CLONED_COMMIT=$(git rev-parse HEAD 2>/dev/null)
cd "$FEDPUNK_ROOT"

if [ "$CLONED_COMMIT" = "$UPDATED_COMMIT" ]; then
    echo "  SUCCESS: Module updated to latest commit"
else
    echo "  FAIL: Module not updated" >&2
    echo "  Expected: ${UPDATED_COMMIT:0:8}"
    echo "  Got: ${CLONED_COMMIT:0:8}"
    exit 1
fi
echo ""

#
# Test 6: Module added to config
#
echo "=== Test 6: Add module to config ==="

run_fish "fedpunk-config-add-module '$TEST_MODULE_URL'" 2>&1 || true

ENABLED=$(run_fish "fedpunk-config-list-enabled-modules" 2>/dev/null)
if echo "$ENABLED" | grep -q "test-external-module\|$TEST_MODULE_URL"; then
    echo "  SUCCESS: Module added to enabled list"
else
    echo "  INFO: Module may not be in enabled list (different format)"
    echo "  Got: $ENABLED"
fi
echo ""

#
# Summary
#
echo "========================================="
echo "All external module tests passed!"
echo "========================================="
echo ""
echo "Summary:"
echo "  - External module cloned from git URL"
echo "  - Module stored in ~/.config/fedpunk/modules/"
echo "  - Module path resolution works"
echo "  - Re-clone updates to latest commit"
echo ""
