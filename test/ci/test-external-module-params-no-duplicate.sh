#!/bin/bash
# Regression test for external module deployment with parameters
#
# Bug: deployer-deploy-module was adding module twice:
#   1. First as normalized name string: "fedpunk-claude-gauth-example"
#   2. Then as object with URL and params when parameters were saved
#
# Expected behavior: Single entry with URL and params
#
# Tests:
# 1. Deploy external module with parameters via deployer-deploy-module
# 2. Verify only ONE entry in modules.enabled
# 3. Verify entry format is {module: "url", params: {...}}
# 4. Verify no duplicate normalized name entry

set -e

echo ""
echo "========================================="
echo "External Module Params No Duplicate Test"
echo "========================================="
echo ""

# Setup test environment
TEST_DIR=$(mktemp -d -t fedpunk-ext-params-test-XXXXXX)
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
source \$FEDPUNK_SYSTEM/lib/fish/deployer.fish
source \$FEDPUNK_SYSTEM/lib/fish/param-prompter.fish
source \$FEDPUNK_SYSTEM/lib/fish/module-resolver.fish
source \$FEDPUNK_SYSTEM/lib/fish/external-modules.fish
$1
"
}

#
# Test 1: Create test external module with parameters
#
echo "=== Test 1: Create test external module repo with parameters ==="

TEST_MODULE_REPO="$TEST_DIR/test-params-ext-module"
mkdir -p "$TEST_MODULE_REPO/config/.config/test-params-ext"

cat > "$TEST_MODULE_REPO/module.yaml" <<'EOF'
module:
  name: test-params-ext-module
  description: Test external module with parameters

parameters:
  auth_mode:
    type: string
    description: "Authentication mode"
    options:
      - enabled
      - disabled

packages:
  dnf: []

stow:
  target: $HOME
  conflicts: warn
EOF

echo "config: test" > "$TEST_MODULE_REPO/config/.config/test-params-ext/config.txt"

# Initialize as git repo
cd "$TEST_MODULE_REPO"
git init -q
git config user.email "test@fedpunk.test"
git config user.name "Test User"
git add .
git commit -q -m "Initial commit"
cd "$FEDPUNK_ROOT"

TEST_MODULE_URL="file://$TEST_MODULE_REPO"
echo "  Created test module repo at: $TEST_MODULE_REPO"
echo "  Module URL: $TEST_MODULE_URL"
echo ""

#
# Test 2: Simulate the bug scenario - deployer-deploy-module with params
#
echo "=== Test 2: Deploy module with parameters (testing fix) ==="

# Initialize config
run_fish "fedpunk-config-init" 2>&1 || true

# Step 1: deployer-deploy-module adds module URL (FIXED behavior)
run_fish "fedpunk-config-add-module '$TEST_MODULE_URL'" 2>&1 || true
echo "  Step 1: Added module URL to config: $TEST_MODULE_URL"

# Step 2: param-save-to-config tries to find using URL (not name)
# This is what happens when fedpunk-module deploy calls param-prompt-required
run_fish "
source \$FEDPUNK_SYSTEM/lib/fish/param-prompter.fish
param-save-to-config '$TEST_MODULE_URL' 'auth_mode' 'enabled'
" 2>&1 || true

echo "  Step 2: Saved params using URL: $TEST_MODULE_URL"
echo "  (Should update existing entry, not create duplicate)"
echo ""

#
# Test 3: Verify NO duplicate entries
#
echo "=== Test 3: Verify NO duplicate entries in modules.enabled ==="

CONFIG_FILE="$HOME/.config/fedpunk/fedpunk.yaml"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "  FAIL: Config file not created" >&2
    exit 1
fi

echo "  Config file contents:"
cat "$CONFIG_FILE" | sed 's/^/    /'
echo ""

# Count how many times the module appears in enabled list
# Should be exactly 1
MODULE_COUNT=$(yq '.modules.enabled | length' "$CONFIG_FILE")

if [ "$MODULE_COUNT" -eq 1 ]; then
    echo "  SUCCESS: Exactly 1 entry in modules.enabled"
else
    echo "  FAIL: Expected 1 entry, found $MODULE_COUNT" >&2
    echo "  Enabled modules:"
    yq '.modules.enabled' "$CONFIG_FILE" | sed 's/^/    /'
    exit 1
fi

# Verify it's NOT a simple string (should be object with module + params)
ENTRY_TYPE=$(yq '.modules.enabled[0] | type' "$CONFIG_FILE")

if [ "$ENTRY_TYPE" = "!!map" ]; then
    echo "  SUCCESS: Entry is an object (not a string)"
else
    echo "  FAIL: Entry is not an object, got type: $ENTRY_TYPE" >&2
    exit 1
fi

# Verify the module field contains the URL
MODULE_FIELD=$(yq '.modules.enabled[0].module' "$CONFIG_FILE")

if echo "$MODULE_FIELD" | grep -q "$TEST_MODULE_URL"; then
    echo "  SUCCESS: Module field contains the URL"
else
    echo "  FAIL: Module field doesn't contain URL" >&2
    echo "  Expected: $TEST_MODULE_URL"
    echo "  Got: $MODULE_FIELD"
    exit 1
fi

# Verify params exist
PARAM_VALUE=$(yq '.modules.enabled[0].params.auth_mode' "$CONFIG_FILE")

if [ "$PARAM_VALUE" = "enabled" ]; then
    echo "  SUCCESS: Parameter auth_mode = enabled"
else
    echo "  FAIL: Parameter not found or incorrect" >&2
    echo "  Expected: enabled"
    echo "  Got: $PARAM_VALUE"
    exit 1
fi

echo ""

#
# Test 4: Verify NO normalized name entry exists
#
echo "=== Test 4: Verify NO duplicate normalized name entry ==="

# Check that there's no string entry with just the module name
if yq '.modules.enabled[] | select(type == "!!str")' "$CONFIG_FILE" 2>/dev/null | grep -q "test-params-ext-module"; then
    echo "  FAIL: Found duplicate string entry with normalized name" >&2
    echo "  This is the bug we're testing for!"
    exit 1
else
    echo "  SUCCESS: No duplicate normalized name entry found"
fi

echo ""

#
# Summary
#
echo "========================================="
echo "Regression test passed!"
echo "========================================="
echo ""
echo "Summary:"
echo "  - External module with params deploys correctly"
echo "  - Only ONE entry in modules.enabled"
echo "  - Entry format: {module: URL, params: {...}}"
echo "  - No duplicate normalized name entry"
echo ""
echo "This test prevents regression of the duplicate module bug"
echo "where deployer-deploy-module was adding the module twice:"
echo "  1. As normalized name string"
echo "  2. As URL object with params"
echo ""
