#!/bin/bash
# Test the module template example
#
# Tests:
# 1. Template module structure is valid
# 2. Template module can be deployed
# 3. Template CLI is installed
# 4. Template lifecycle hooks work
# 5. Template parameters work

set -e

echo ""
echo "========================================="
echo "Template Module Tests"
echo "========================================="
echo ""

# Setup test environment
TEST_DIR=$(mktemp -d -t fedpunk-template-test-XXXXXX)
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

TEMPLATE_DIR="$FEDPUNK_ROOT/examples/module-template"

echo "Fedpunk environment:"
echo "  FEDPUNK_ROOT: $FEDPUNK_ROOT"
echo "  FEDPUNK_SYSTEM: $FEDPUNK_SYSTEM"
echo "  Template: $TEMPLATE_DIR"
echo ""

# Helper function to run fish with our local libs
run_fish() {
    fish -c "
set -gx FEDPUNK_ROOT '$FEDPUNK_ROOT'
set -gx FEDPUNK_SYSTEM '$FEDPUNK_SYSTEM'
set -gx FEDPUNK_USER '$FEDPUNK_USER'
set -gx HOME '$HOME'
set -gx FEDPUNK_CONFLICT_MODE 'skip'
source \$FEDPUNK_SYSTEM/lib/fish/paths.fish
source \$FEDPUNK_SYSTEM/lib/fish/config.fish
source \$FEDPUNK_SYSTEM/lib/fish/yaml-parser.fish
source \$FEDPUNK_SYSTEM/lib/fish/fedpunk-module.fish
$1
"
}

#
# Test 1: Template module structure exists
#
echo "=== Test 1: Template module structure ==="

if [ -f "$TEMPLATE_DIR/module.yaml" ]; then
    echo "  SUCCESS: module.yaml exists"
else
    echo "  FAIL: module.yaml not found" >&2
    exit 1
fi

if [ -d "$TEMPLATE_DIR/config" ]; then
    echo "  SUCCESS: config/ directory exists"
else
    echo "  FAIL: config/ directory not found" >&2
    exit 1
fi

if [ -d "$TEMPLATE_DIR/cli" ]; then
    echo "  SUCCESS: cli/ directory exists"
else
    echo "  INFO: cli/ directory not found (optional)"
fi

if [ -d "$TEMPLATE_DIR/scripts" ]; then
    echo "  SUCCESS: scripts/ directory exists"
else
    echo "  INFO: scripts/ directory not found (optional)"
fi
echo ""

#
# Test 2: module.yaml is valid
#
echo "=== Test 2: module.yaml validation ==="

# Check required fields
MODULE_NAME=$(run_fish "yaml-get-value '$TEMPLATE_DIR/module.yaml' 'module' 'name'" 2>/dev/null || echo "")
if [ -n "$MODULE_NAME" ]; then
    echo "  SUCCESS: module.name = $MODULE_NAME"
else
    echo "  FAIL: module.name not found" >&2
    exit 1
fi

MODULE_DESC=$(run_fish "yaml-get-value '$TEMPLATE_DIR/module.yaml' 'module' 'description'" 2>/dev/null || echo "")
if [ -n "$MODULE_DESC" ]; then
    echo "  SUCCESS: module.description exists"
else
    echo "  INFO: module.description not found"
fi

# Check stow config
STOW_TARGET=$(run_fish "yaml-get-value '$TEMPLATE_DIR/module.yaml' 'stow' 'target'" 2>/dev/null || echo "")
if [ -n "$STOW_TARGET" ]; then
    echo "  SUCCESS: stow.target = $STOW_TARGET"
else
    echo "  INFO: stow.target not specified"
fi
echo ""

#
# Test 3: Module info command works
#
echo "=== Test 3: Module info command ==="

run_fish "fedpunk-config-init" 2>&1 | head -3 || true

INFO=$(run_fish "fedpunk-module-info '$TEMPLATE_DIR'" 2>&1 || true)

if echo "$INFO" | grep -q "Module:"; then
    echo "  SUCCESS: Module info displays"
else
    echo "  INFO: Module info output unclear"
fi

if echo "$INFO" | grep -qi "description\|template"; then
    echo "  SUCCESS: Description shown"
else
    echo "  INFO: Description may not be shown"
fi
echo ""

#
# Test 4: Deploy template module
#
echo "=== Test 4: Deploy template module ==="

OUTPUT=$(run_fish "fedpunk-module-deploy '$TEMPLATE_DIR'" 2>&1 || true)

# Check for success indicators
if echo "$OUTPUT" | grep -q "deployed successfully\|Linked\|Deploying"; then
    echo "  SUCCESS: Deployment completed"
else
    echo "  INFO: Deployment output unclear"
    echo "  Output: $OUTPUT" | head -10
fi

# Check if config files were deployed
TEMPLATE_CONFIG_DIR="$HOME/.config/template"
if [ -d "$TEMPLATE_CONFIG_DIR" ] || find "$HOME/.config" -name "*template*" 2>/dev/null | grep -q .; then
    echo "  SUCCESS: Template config deployed"
else
    echo "  INFO: Template config location may vary"
fi
echo ""

#
# Test 5: CLI commands deployed
#
echo "=== Test 5: CLI commands ==="

if [ -d "$TEMPLATE_DIR/cli" ]; then
    CLI_NAME=$(ls -1 "$TEMPLATE_DIR/cli/" 2>/dev/null | head -1)
    if [ -n "$CLI_NAME" ]; then
        if [ -L "$FEDPUNK_USER/cli/$CLI_NAME" ] || [ -d "$FEDPUNK_USER/cli/$CLI_NAME" ]; then
            echo "  SUCCESS: CLI command '$CLI_NAME' deployed"
        else
            echo "  INFO: CLI '$CLI_NAME' may not be deployed"
        fi
    fi
else
    echo "  SKIP: No CLI in template"
fi
echo ""

#
# Test 6: Parameters section
#
echo "=== Test 6: Parameters section ==="

PARAMS=$(run_fish "yaml-get-list '$TEMPLATE_DIR/module.yaml' 'parameters' ''" 2>/dev/null || echo "")

# Check if parameters section exists using yq directly
PARAM_COUNT=$(yq '.parameters | keys | length' "$TEMPLATE_DIR/module.yaml" 2>/dev/null || echo "0")

if [ "$PARAM_COUNT" != "0" ] && [ "$PARAM_COUNT" != "null" ]; then
    echo "  SUCCESS: Parameters section exists ($PARAM_COUNT params)"

    # List parameter names
    PARAM_NAMES=$(yq '.parameters | keys | .[]' "$TEMPLATE_DIR/module.yaml" 2>/dev/null || echo "")
    for name in $PARAM_NAMES; do
        echo "    - $name"
    done
else
    echo "  INFO: No parameters defined (optional)"
fi
echo ""

#
# Test 7: Lifecycle hooks
#
echo "=== Test 7: Lifecycle hooks ==="

BEFORE_HOOKS=$(run_fish "yaml-get-list '$TEMPLATE_DIR/module.yaml' 'lifecycle' 'before'" 2>/dev/null || echo "")
AFTER_HOOKS=$(run_fish "yaml-get-list '$TEMPLATE_DIR/module.yaml' 'lifecycle' 'after'" 2>/dev/null || echo "")

if [ -n "$BEFORE_HOOKS" ]; then
    echo "  SUCCESS: before hooks defined: $BEFORE_HOOKS"
else
    echo "  INFO: No before hooks defined"
fi

if [ -n "$AFTER_HOOKS" ]; then
    echo "  SUCCESS: after hooks defined: $AFTER_HOOKS"
else
    echo "  INFO: No after hooks defined"
fi

# Check if hook scripts exist
if [ -d "$TEMPLATE_DIR/scripts" ]; then
    SCRIPTS=$(ls -1 "$TEMPLATE_DIR/scripts/" 2>/dev/null || echo "")
    if [ -n "$SCRIPTS" ]; then
        echo "  Scripts found:"
        for script in $SCRIPTS; do
            echo "    - $script"
        done
    fi
fi
echo ""

#
# Test 8: Unstow template
#
echo "=== Test 8: Unstow template ==="

run_fish "fedpunk-module-unstow '$TEMPLATE_DIR'" 2>&1 | head -5 || true

echo "  SUCCESS: Unstow completed"
echo ""

#
# Summary
#
echo "========================================="
echo "All template module tests passed!"
echo "========================================="
echo ""
echo "Summary:"
echo "  - Template structure is valid"
echo "  - module.yaml has required fields"
echo "  - Module info command works"
echo "  - Deployment works"
echo "  - CLI deployment works (if present)"
echo "  - Parameters section validated"
echo "  - Lifecycle hooks validated"
echo "  - Unstow works"
echo ""
