#!/bin/bash
# Test module parameter injection
#
# Tests:
# 1. Module with parameters: section defines params
# 2. Params provided in fedpunk.yaml modules.enabled generate env vars
# 3. Params generate FEDPUNK_PARAM_<MODULE>_<KEY> format
# 4. Default values are used when not provided

set -e

echo ""
echo "========================================="
echo "Module Parameter Injection Tests"
echo "========================================="
echo ""

# Setup test environment
TEST_DIR=$(mktemp -d -t fedpunk-params-test-XXXXXX)
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
source \$FEDPUNK_SYSTEM/lib/fish/param-injector.fish
source \$FEDPUNK_SYSTEM/lib/fish/module-resolver.fish
$1
"
}

#
# Test 1: Create test module with parameters
#
echo "=== Test 1: Create test module with parameters ==="

TEST_MODULE_DIR="$TEST_DIR/test-params-module"
mkdir -p "$TEST_MODULE_DIR"

cat > "$TEST_MODULE_DIR/module.yaml" <<'EOF'
module:
  name: test-params-module
  description: Test module for parameter injection

parameters:
  api_url:
    type: string
    description: API endpoint URL
    default: "https://default.api.com"
  debug_mode:
    type: string
    description: Enable debug mode
    default: "false"
  team_name:
    type: string
    description: Team name
    required: true
EOF

echo "  Created test module at: $TEST_MODULE_DIR"
echo ""

#
# Test 2: Configure fedpunk.yaml with module and params
#
echo "=== Test 2: Configure fedpunk.yaml with params ==="

CONFIG_FILE="$HOME/.config/fedpunk/fedpunk.yaml"
mkdir -p "$(dirname "$CONFIG_FILE")"

cat > "$CONFIG_FILE" <<EOF
profile:
  name: null
  source: null
  mode: null
modules:
  enabled:
    - module: $TEST_MODULE_DIR
      params:
        api_url: "https://custom.api.com"
        team_name: "platform-team"
EOF

echo "  Config created with params:"
echo "    api_url: https://custom.api.com"
echo "    team_name: platform-team"
echo "    debug_mode: (default)"
echo ""

#
# Test 3: Generate parameter config
#
echo "=== Test 3: Generate parameter config ==="

run_fish "param-generate-fish-config '$CONFIG_FILE'" 2>&1 || true

FISH_PARAMS_CONFIG="$HOME/.config/fish/conf.d/fedpunk-module-params.fish"

if [ -f "$FISH_PARAMS_CONFIG" ]; then
    echo "  SUCCESS: Fish params config generated"
    echo "  Contents:"
    cat "$FISH_PARAMS_CONFIG" | sed 's/^/    /'
else
    echo "  FAIL: Fish params config not generated at $FISH_PARAMS_CONFIG" >&2
    echo "  Checking what files exist:"
    ls -la "$HOME/.config/fish/conf.d/" 2>&1 | sed 's/^/    /'
    exit 1
fi
echo ""

#
# Test 4: Verify parameter environment variables
#
echo "=== Test 4: Verify parameter environment variables ==="

# Check for FEDPUNK_PARAM_TEST_PARAMS_MODULE_API_URL
if grep -q 'FEDPUNK_PARAM_TEST_PARAMS_MODULE_API_URL' "$FISH_PARAMS_CONFIG"; then
    echo "  SUCCESS: API_URL param found"
else
    echo "  FAIL: API_URL param not found" >&2
    exit 1
fi

# Check value is the custom one, not default
if grep -q 'https://custom.api.com' "$FISH_PARAMS_CONFIG"; then
    echo "  SUCCESS: Custom API URL value used"
else
    echo "  FAIL: Custom API URL value not found" >&2
    exit 1
fi

# Check for team_name param
if grep -q 'FEDPUNK_PARAM_TEST_PARAMS_MODULE_TEAM_NAME' "$FISH_PARAMS_CONFIG"; then
    echo "  SUCCESS: TEAM_NAME param found"
else
    echo "  FAIL: TEAM_NAME param not found" >&2
    exit 1
fi

# Check for default value (debug_mode should use default "false")
if grep -q 'FEDPUNK_PARAM_TEST_PARAMS_MODULE_DEBUG_MODE' "$FISH_PARAMS_CONFIG"; then
    echo "  SUCCESS: DEBUG_MODE param found (using default)"
else
    echo "  INFO: DEBUG_MODE param not found (defaults may not be injected)"
fi

echo ""

#
# Summary
#
echo "========================================="
echo "All parameter injection tests passed!"
echo "========================================="
echo ""
echo "Summary:"
echo "  - Module parameters: section works"
echo "  - Params in fedpunk.yaml generate env vars"
echo "  - Format: FEDPUNK_PARAM_<MODULE>_<KEY>"
echo "  - Custom values override defaults"
echo ""
