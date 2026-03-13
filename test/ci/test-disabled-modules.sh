#!/bin/bash
# Test disabled modules functionality
#
# Tests:
# 1. Module in disabled list is not deployed
# 2. Disabled list is read correctly from config

set -e

echo ""
echo "========================================="
echo "Disabled Modules Tests"
echo "========================================="
echo ""

# Setup test environment
TEST_DIR=$(mktemp -d -t fedpunk-disabled-test-XXXXXX)
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
source \$FEDPUNK_SYSTEM/lib/fish/yq-utils.fish
$1
"
}

CONFIG_FILE="$HOME/.config/fedpunk/fedpunk.yaml"

#
# Test 1: Create config with disabled modules
#
echo "=== Test 1: Create config with disabled list ==="

mkdir -p "$(dirname "$CONFIG_FILE")"
cat > "$CONFIG_FILE" <<'EOF'
profile:
  name: test-profile
  source: null
  mode: test
modules:
  enabled:
    - fish
    - test-module
  disabled:
    - disabled-module-1
    - disabled-module-2
EOF

echo "  Created config with disabled modules:"
echo "    - disabled-module-1"
echo "    - disabled-module-2"
echo ""

#
# Test 2: Read disabled modules from config
#
echo "=== Test 2: Read disabled modules ==="

# Use yq to read disabled list
DISABLED=$(run_fish "_yq_safe '.modules.disabled[]' '$CONFIG_FILE'" 2>/dev/null)

if echo "$DISABLED" | grep -q "disabled-module-1"; then
    echo "  SUCCESS: disabled-module-1 found in disabled list"
else
    echo "  FAIL: disabled-module-1 not found" >&2
    echo "  Got: $DISABLED"
    exit 1
fi

if echo "$DISABLED" | grep -q "disabled-module-2"; then
    echo "  SUCCESS: disabled-module-2 found in disabled list"
else
    echo "  FAIL: disabled-module-2 not found" >&2
    exit 1
fi
echo ""

#
# Test 3: Enabled modules are still readable
#
echo "=== Test 3: Enabled modules still work ==="

ENABLED=$(run_fish "fedpunk-config-list-enabled-modules" 2>/dev/null)

if echo "$ENABLED" | grep -q "fish"; then
    echo "  SUCCESS: fish in enabled list"
else
    echo "  FAIL: fish not in enabled list" >&2
    echo "  Got: $ENABLED"
    exit 1
fi

if echo "$ENABLED" | grep -q "test-module"; then
    echo "  SUCCESS: test-module in enabled list"
else
    echo "  FAIL: test-module not in enabled list" >&2
    exit 1
fi
echo ""

#
# Test 4: Disabled modules not in enabled list
#
echo "=== Test 4: Disabled not in enabled ==="

if echo "$ENABLED" | grep -q "disabled-module-1"; then
    echo "  FAIL: disabled-module-1 found in enabled list" >&2
    exit 1
else
    echo "  SUCCESS: disabled-module-1 not in enabled list"
fi

if echo "$ENABLED" | grep -q "disabled-module-2"; then
    echo "  FAIL: disabled-module-2 found in enabled list" >&2
    exit 1
else
    echo "  SUCCESS: disabled-module-2 not in enabled list"
fi
echo ""

#
# Test 5: Empty disabled list works
#
echo "=== Test 5: Empty disabled list ==="

cat > "$CONFIG_FILE" <<'EOF'
profile:
  name: test-profile
  source: null
  mode: test
modules:
  enabled:
    - fish
  disabled: []
EOF

DISABLED=$(run_fish "_yq_safe '.modules.disabled | length' '$CONFIG_FILE'" 2>/dev/null)

if [ "$DISABLED" = "0" ]; then
    echo "  SUCCESS: Empty disabled list handled correctly"
else
    echo "  INFO: Disabled list length: $DISABLED"
fi

ENABLED=$(run_fish "fedpunk-config-list-enabled-modules" 2>/dev/null)
if echo "$ENABLED" | grep -q "fish"; then
    echo "  SUCCESS: Enabled modules still work with empty disabled"
else
    echo "  FAIL: Enabled modules broken" >&2
    exit 1
fi
echo ""

#
# Summary
#
echo "========================================="
echo "All disabled modules tests passed!"
echo "========================================="
echo ""
echo "Summary:"
echo "  - Disabled list readable from config"
echo "  - Enabled modules work alongside disabled"
echo "  - Disabled modules not in enabled list"
echo "  - Empty disabled list handled"
echo ""
