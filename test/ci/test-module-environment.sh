#!/bin/bash
# Test module environment variable injection
#
# Tests:
# 1. Module with environment: section generates Fish config
# 2. Module with environment: section generates Bash config
# 3. Environment variables are correctly exported
# 4. User environment in fedpunk.yaml overrides module environment

set -e

echo ""
echo "========================================="
echo "Module Environment Variable Tests"
echo "========================================="
echo ""

# Setup test environment
TEST_DIR=$(mktemp -d -t fedpunk-env-test-XXXXXX)
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
source \$FEDPUNK_SYSTEM/lib/fish/env-injector.fish
source \$FEDPUNK_SYSTEM/lib/fish/module-resolver.fish
$1
"
}

#
# Test 1: Create test module with environment section
#
echo "=== Test 1: Create test module with environment ==="

TEST_MODULE_DIR="$TEST_DIR/test-env-module"
mkdir -p "$TEST_MODULE_DIR"

cat > "$TEST_MODULE_DIR/module.yaml" <<'EOF'
module:
  name: test-env-module
  description: Test module for environment variables

environment:
  TEST_VAR_ONE: "hello"
  TEST_VAR_TWO: "world"
  TEST_PATH_VAR: "/custom/path"
EOF

echo "  Created test module at: $TEST_MODULE_DIR"
echo ""

#
# Test 2: Configure fedpunk.yaml with the test module
#
echo "=== Test 2: Configure fedpunk.yaml ==="

CONFIG_FILE="$HOME/.config/fedpunk/fedpunk.yaml"
mkdir -p "$(dirname "$CONFIG_FILE")"

cat > "$CONFIG_FILE" <<EOF
profile:
  name: null
  source: null
  mode: null
modules:
  enabled:
    - $TEST_MODULE_DIR
EOF

echo "  Config created with test module"
echo ""

#
# Test 3: Generate environment config
#
echo "=== Test 3: Generate environment config ==="

run_fish "env-generate-fish-config '$CONFIG_FILE'" 2>&1 || true

FISH_ENV_CONFIG="$HOME/.config/fish/conf.d/fedpunk-module-env.fish"
BASH_ENV_CONFIG="$HOME/.config/fedpunk/profile.d/fedpunk-env.sh"

if [ -f "$FISH_ENV_CONFIG" ]; then
    echo "  SUCCESS: Fish config generated"
    echo "  Contents:"
    cat "$FISH_ENV_CONFIG" | sed 's/^/    /'
else
    echo "  FAIL: Fish config not generated" >&2
    exit 1
fi
echo ""

if [ -f "$BASH_ENV_CONFIG" ]; then
    echo "  SUCCESS: Bash config generated"
    echo "  Contents:"
    cat "$BASH_ENV_CONFIG" | sed 's/^/    /'
else
    echo "  FAIL: Bash config not generated" >&2
    exit 1
fi
echo ""

#
# Test 4: Verify environment variables in generated config
#
echo "=== Test 4: Verify environment variables ==="

if grep -q 'TEST_VAR_ONE' "$FISH_ENV_CONFIG" && grep -q '"hello"' "$FISH_ENV_CONFIG"; then
    echo "  SUCCESS: TEST_VAR_ONE=hello found in Fish config"
else
    echo "  FAIL: TEST_VAR_ONE not found or incorrect" >&2
    exit 1
fi

if grep -q 'TEST_VAR_TWO' "$FISH_ENV_CONFIG" && grep -q '"world"' "$FISH_ENV_CONFIG"; then
    echo "  SUCCESS: TEST_VAR_TWO=world found in Fish config"
else
    echo "  FAIL: TEST_VAR_TWO not found or incorrect" >&2
    exit 1
fi

if grep -q 'TEST_PATH_VAR' "$BASH_ENV_CONFIG" && grep -q '"/custom/path"' "$BASH_ENV_CONFIG"; then
    echo "  SUCCESS: TEST_PATH_VAR=/custom/path found in Bash config"
else
    echo "  FAIL: TEST_PATH_VAR not found or incorrect" >&2
    exit 1
fi
echo ""

#
# Test 5: User environment overrides module environment
#
echo "=== Test 5: User environment overrides ==="

cat > "$CONFIG_FILE" <<EOF
profile:
  name: null
  source: null
  mode: null
modules:
  enabled:
    - $TEST_MODULE_DIR
environment:
  TEST_VAR_ONE: "overridden"
  USER_CUSTOM_VAR: "user-value"
EOF

run_fish "env-generate-fish-config '$CONFIG_FILE'" 2>&1 || true

if grep -q 'TEST_VAR_ONE' "$FISH_ENV_CONFIG" && grep -q '"overridden"' "$FISH_ENV_CONFIG"; then
    echo "  SUCCESS: TEST_VAR_ONE overridden to 'overridden'"
else
    echo "  FAIL: TEST_VAR_ONE not overridden" >&2
    cat "$FISH_ENV_CONFIG"
    exit 1
fi

if grep -q 'USER_CUSTOM_VAR' "$FISH_ENV_CONFIG" && grep -q '"user-value"' "$FISH_ENV_CONFIG"; then
    echo "  SUCCESS: USER_CUSTOM_VAR=user-value added from user config"
else
    echo "  FAIL: USER_CUSTOM_VAR not found" >&2
    exit 1
fi
echo ""

#
# Summary
#
echo "========================================="
echo "All environment variable tests passed!"
echo "========================================="
echo ""
echo "Summary:"
echo "  - Module environment: section works"
echo "  - Fish config generated correctly"
echo "  - Bash config generated correctly"
echo "  - User environment overrides module"
echo ""
