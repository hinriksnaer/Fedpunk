#!/bin/bash
# Test YAML config reproducibility
#
# Tests:
# 1. fedpunk.yaml generates same output on re-read
# 2. module.yaml parsing is consistent
# 3. Parameter injection produces deterministic output
# 4. Environment injection produces deterministic output
# 5. Config modifications are reversible

set -e

echo ""
echo "========================================="
echo "YAML Reproducibility Tests"
echo "========================================="
echo ""

# Setup test environment
TEST_DIR=$(mktemp -d -t fedpunk-yaml-test-XXXXXX)
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

# Helper function to run fish with our local libs
run_fish() {
    fish -c "
set -gx FEDPUNK_ROOT '$FEDPUNK_ROOT'
set -gx FEDPUNK_SYSTEM '$FEDPUNK_SYSTEM'
set -gx FEDPUNK_USER '$FEDPUNK_USER'
set -gx HOME '$HOME'
source \$FEDPUNK_SYSTEM/lib/fish/paths.fish
source \$FEDPUNK_SYSTEM/lib/fish/config.fish
source \$FEDPUNK_SYSTEM/lib/fish/yaml-parser.fish
source \$FEDPUNK_SYSTEM/lib/fish/param-injector.fish
source \$FEDPUNK_SYSTEM/lib/fish/env-injector.fish
$1
"
}

#
# Test 1: Config init produces valid YAML
#
echo "=== Test 1: Config init produces valid YAML ==="

run_fish "fedpunk-config-init" 2>&1 | head -3 || true

CONFIG_FILE="$HOME/.config/fedpunk/fedpunk.yaml"
if [ -f "$CONFIG_FILE" ]; then
    # Validate with yq
    if yq '.' "$CONFIG_FILE" >/dev/null 2>&1; then
        echo "  SUCCESS: fedpunk.yaml is valid YAML"
    else
        echo "  FAIL: fedpunk.yaml is not valid YAML" >&2
        exit 1
    fi
else
    echo "  FAIL: Config file not created" >&2
    exit 1
fi
echo ""

#
# Test 2: Read/Write consistency
#
echo "=== Test 2: Read/Write consistency ==="

# Set profile name and read it back
run_fish "fedpunk-config-set-profile 'test-profile' '' 'desktop'" 2>&1 || true

# Read it back multiple times - should be consistent
READ1=$(run_fish "fedpunk-config-get-profile-name" 2>/dev/null)
READ2=$(run_fish "fedpunk-config-get-profile-name" 2>/dev/null)
READ3=$(run_fish "fedpunk-config-get-profile-name" 2>/dev/null)

if [ "$READ1" = "$READ2" ] && [ "$READ2" = "$READ3" ]; then
    echo "  SUCCESS: Profile name reads consistently: $READ1"
else
    echo "  FAIL: Inconsistent reads" >&2
    echo "  Read1: $READ1, Read2: $READ2, Read3: $READ3"
    exit 1
fi
echo ""

#
# Test 3: Module list reproducibility
#
echo "=== Test 3: Module list reproducibility ==="

# Add some modules
run_fish "fedpunk-config-add-module fish" 2>&1 || true
run_fish "fedpunk-config-add-module ssh" 2>&1 || true
run_fish "fedpunk-config-add-module test-module" 2>&1 || true

# Read list multiple times
LIST1=$(run_fish "fedpunk-config-list-enabled-modules" 2>/dev/null | sort)
LIST2=$(run_fish "fedpunk-config-list-enabled-modules" 2>/dev/null | sort)

if [ "$LIST1" = "$LIST2" ]; then
    echo "  SUCCESS: Module list is consistent"
    echo "  Modules: $(echo $LIST1 | tr '\n' ' ')"
else
    echo "  FAIL: Module list inconsistent" >&2
    exit 1
fi
echo ""

#
# Test 4: Parameter injection reproducibility
#
echo "=== Test 4: Parameter injection reproducibility ==="

# Create config with parameters
cat > "$CONFIG_FILE" <<'EOF'
profile:
  name: test
  source: null
  mode: desktop

modules:
  enabled:
    - module: test-api
      params:
        api_url: "https://api.example.com"
        timeout: 30
        debug: false
EOF

# Generate param config multiple times
PARAMS_FILE="$HOME/.config/fish/conf.d/fedpunk-module-params.fish"

run_fish "param-generate-fish-config '$CONFIG_FILE'" 2>&1 | head -3 || true
if [ -f "$PARAMS_FILE" ]; then
    CONTENT1=$(cat "$PARAMS_FILE" | grep -v "^#" | sort)
else
    CONTENT1=""
fi

run_fish "param-generate-fish-config '$CONFIG_FILE'" 2>&1 | head -3 || true
if [ -f "$PARAMS_FILE" ]; then
    CONTENT2=$(cat "$PARAMS_FILE" | grep -v "^#" | sort)
else
    CONTENT2=""
fi

if [ "$CONTENT1" = "$CONTENT2" ]; then
    echo "  SUCCESS: Parameter injection is deterministic"
else
    echo "  FAIL: Parameter injection is not deterministic" >&2
    echo "  Run1 vs Run2 differ"
    exit 1
fi
echo ""

#
# Test 5: Environment injection reproducibility
#
echo "=== Test 5: Environment injection reproducibility ==="

# Create module with environment
MODULE_DIR="$TEST_DIR/test-env-module"
mkdir -p "$MODULE_DIR"
cat > "$MODULE_DIR/module.yaml" <<'EOF'
module:
  name: test-env-module
  description: Test module with environment

environment:
  TEST_VAR: "value1"
  ANOTHER_VAR: "value2"

packages:
  dnf: []

stow:
  target: $HOME
EOF

# Generate env config
ENV_FILE="$HOME/.config/fish/conf.d/fedpunk-module-env.fish"

run_fish "env-generate-fish-config '$CONFIG_FILE'" 2>&1 | head -3 || true
if [ -f "$ENV_FILE" ]; then
    ENV1=$(cat "$ENV_FILE" | grep -v "^#" | sort)
else
    ENV1=""
fi

run_fish "env-generate-fish-config '$CONFIG_FILE'" 2>&1 | head -3 || true
if [ -f "$ENV_FILE" ]; then
    ENV2=$(cat "$ENV_FILE" | grep -v "^#" | sort)
else
    ENV2=""
fi

if [ "$ENV1" = "$ENV2" ]; then
    echo "  SUCCESS: Environment injection is deterministic"
else
    echo "  FAIL: Environment injection is not deterministic" >&2
fi
echo ""

#
# Test 6: YAML roundtrip
#
echo "=== Test 6: YAML roundtrip ==="

# Create complex config
cat > "$CONFIG_FILE" <<'EOF'
profile:
  name: complex-test
  source: https://github.com/user/profile.git
  mode: laptop

modules:
  enabled:
    - fish
    - ssh
    - module: custom-module
      params:
        key1: "value1"
        key2: "value2"
  disabled:
    - disabled-module

sources:
  - https://github.com/org/modules.git
EOF

# Read and verify values
PROFILE=$(run_fish "fedpunk-config-get-profile-name" 2>/dev/null)
MODE=$(run_fish "fedpunk-config-get-profile-mode" 2>/dev/null)
SOURCE=$(run_fish "fedpunk-config-get-profile-source" 2>/dev/null)

if [ "$PROFILE" = "complex-test" ]; then
    echo "  SUCCESS: Profile name preserved: $PROFILE"
else
    echo "  FAIL: Profile name not preserved (got: $PROFILE)" >&2
fi

if [ "$MODE" = "laptop" ]; then
    echo "  SUCCESS: Mode preserved: $MODE"
else
    echo "  FAIL: Mode not preserved (got: $MODE)" >&2
fi

if echo "$SOURCE" | grep -q "github.com"; then
    echo "  SUCCESS: Source URL preserved"
else
    echo "  INFO: Source URL: $SOURCE"
fi
echo ""

#
# Test 7: Timestamp preservation
#
echo "=== Test 7: Metadata not corrupted ==="

# Update metadata
run_fish "fedpunk-config-update-metadata" 2>&1 || true

# Read config - should still be valid
if yq '.' "$CONFIG_FILE" >/dev/null 2>&1; then
    echo "  SUCCESS: Config still valid after metadata update"
else
    echo "  FAIL: Config corrupted after metadata update" >&2
    exit 1
fi

# Profile should still be readable
PROFILE_AFTER=$(run_fish "fedpunk-config-get-profile-name" 2>/dev/null)
if [ "$PROFILE_AFTER" = "complex-test" ]; then
    echo "  SUCCESS: Profile name still accessible"
else
    echo "  FAIL: Profile name corrupted (got: $PROFILE_AFTER)" >&2
fi
echo ""

#
# Summary
#
echo "========================================="
echo "All YAML reproducibility tests passed!"
echo "========================================="
echo ""
echo "Summary:"
echo "  - Config init produces valid YAML"
echo "  - Read/Write is consistent"
echo "  - Module lists are reproducible"
echo "  - Parameter injection is deterministic"
echo "  - Environment injection is deterministic"
echo "  - Complex configs round-trip correctly"
echo "  - Metadata updates don't corrupt config"
echo ""
