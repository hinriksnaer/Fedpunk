#!/bin/bash
# Test config file preservation
#
# Tests:
# 1. Existing fedpunk.yaml not overwritten by init
# 2. Existing directories preserved
# 3. User config values preserved across operations

set -e

echo ""
echo "========================================="
echo "Config Preservation Tests"
echo "========================================="
echo ""

# Setup test environment
TEST_DIR=$(mktemp -d -t fedpunk-config-test-XXXXXX)
trap "rm -rf $TEST_DIR" EXIT

echo "Test environment: $TEST_DIR"
echo ""

# Override HOME and XDG for isolated testing
export HOME="$TEST_DIR/home"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
mkdir -p "$HOME"

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
$1
"
}

CONFIG_FILE="$HOME/.config/fedpunk/fedpunk.yaml"

#
# Test 1: Create existing config with custom content
#
echo "=== Test 1: Create existing config ==="

mkdir -p "$(dirname "$CONFIG_FILE")"
cat > "$CONFIG_FILE" <<'EOF'
# User's existing config - should NOT be overwritten
profile:
  name: my-custom-profile
  source: https://github.com/user/my-profile.git
  mode: desktop
modules:
  enabled:
    - fish
    - custom-module
custom_field: "this should be preserved"
EOF

echo "  Created config with custom content"
echo "  Custom field: custom_field: this should be preserved"
echo ""

#
# Test 2: Call fedpunk-config-init and verify no overwrite
#
echo "=== Test 2: Verify init doesn't overwrite ==="

run_fish "fedpunk-config-init" 2>&1 || true

if grep -q "my-custom-profile" "$CONFIG_FILE"; then
    echo "  SUCCESS: Profile name preserved"
else
    echo "  FAIL: Profile name was overwritten" >&2
    cat "$CONFIG_FILE"
    exit 1
fi

if grep -q "custom_field" "$CONFIG_FILE"; then
    echo "  SUCCESS: Custom field preserved"
else
    echo "  FAIL: Custom field was overwritten" >&2
    cat "$CONFIG_FILE"
    exit 1
fi

if grep -q "custom-module" "$CONFIG_FILE"; then
    echo "  SUCCESS: Custom module preserved"
else
    echo "  FAIL: Custom module was overwritten" >&2
    exit 1
fi
echo ""

#
# Test 3: Multiple init calls don't corrupt config
#
echo "=== Test 3: Multiple init calls ==="

run_fish "fedpunk-config-init" 2>&1 || true
run_fish "fedpunk-config-init" 2>&1 || true
run_fish "fedpunk-config-init" 2>&1 || true

if grep -q "my-custom-profile" "$CONFIG_FILE"; then
    echo "  SUCCESS: Config still intact after multiple inits"
else
    echo "  FAIL: Config corrupted after multiple inits" >&2
    exit 1
fi
echo ""

#
# Test 4: Directories created if missing but config preserved
#
echo "=== Test 4: Directory creation ==="

# Remove profiles dir but keep config
rm -rf "$HOME/.config/fedpunk/profiles"
rm -rf "$HOME/.config/fedpunk/sources"
rm -rf "$HOME/.config/fedpunk/modules"

run_fish "fedpunk-config-init" 2>&1 || true

if [ -d "$HOME/.config/fedpunk/profiles" ]; then
    echo "  SUCCESS: profiles/ directory recreated"
else
    echo "  FAIL: profiles/ directory not created" >&2
    exit 1
fi

if [ -d "$HOME/.config/fedpunk/sources" ]; then
    echo "  SUCCESS: sources/ directory recreated"
else
    echo "  FAIL: sources/ directory not created" >&2
    exit 1
fi

if [ -d "$HOME/.config/fedpunk/modules" ]; then
    echo "  SUCCESS: modules/ directory recreated"
else
    echo "  FAIL: modules/ directory not created" >&2
    exit 1
fi

# Verify config still preserved
if grep -q "my-custom-profile" "$CONFIG_FILE"; then
    echo "  SUCCESS: Config still preserved"
else
    echo "  FAIL: Config was overwritten during dir creation" >&2
    exit 1
fi
echo ""

#
# Test 5: Config getters work with existing config
#
echo "=== Test 5: Config getters ==="

PROFILE_NAME=$(run_fish "fedpunk-config-get-profile-name" 2>/dev/null)
if [ "$PROFILE_NAME" = "my-custom-profile" ]; then
    echo "  SUCCESS: Profile name getter works: $PROFILE_NAME"
else
    echo "  FAIL: Profile name getter returned: '$PROFILE_NAME'" >&2
    echo "  Expected: my-custom-profile"
    exit 1
fi

PROFILE_SOURCE=$(run_fish "fedpunk-config-get-profile-source" 2>/dev/null)
if [ "$PROFILE_SOURCE" = "https://github.com/user/my-profile.git" ]; then
    echo "  SUCCESS: Profile source getter works"
else
    echo "  FAIL: Profile source getter returned: '$PROFILE_SOURCE'" >&2
    exit 1
fi

PROFILE_MODE=$(run_fish "fedpunk-config-get-profile-mode" 2>/dev/null)
if [ "$PROFILE_MODE" = "desktop" ]; then
    echo "  SUCCESS: Profile mode getter works: $PROFILE_MODE"
else
    echo "  FAIL: Profile mode getter returned: '$PROFILE_MODE'" >&2
    exit 1
fi
echo ""

#
# Summary
#
echo "========================================="
echo "All config preservation tests passed!"
echo "========================================="
echo ""
echo "Summary:"
echo "  - Existing config not overwritten by init"
echo "  - Custom fields preserved"
echo "  - Multiple init calls safe"
echo "  - Directories recreated without corrupting config"
echo "  - Config getters work correctly"
echo ""
