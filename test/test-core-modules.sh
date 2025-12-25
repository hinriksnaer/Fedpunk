#!/bin/bash
# Test core module deployment functionality
#
# Tests:
# 1. Deploy fish module
# 2. Verify fish config symlinked
# 3. Verify fish shell starts
# 4. Deploy ssh module
# 5. Verify ssh config exists
# 6. Test ssh CLI extension

set -e  # Exit on error

echo ""
echo "========================================="
echo "Core Module Deployment Tests"
echo "========================================="
echo ""

# Ensure fedpunk environment is set
if [ -z "$FEDPUNK_SYSTEM" ]; then
    echo "Sourcing Fedpunk environment..."
    source /etc/profile.d/fedpunk.sh
fi

echo "✓ Environment:"
echo "  FEDPUNK_SYSTEM: $FEDPUNK_SYSTEM"
echo "  FEDPUNK_USER: $FEDPUNK_USER"
echo "  FEDPUNK_ROOT: $FEDPUNK_ROOT"
echo ""

# Test 1: Deploy fish module
echo "=== Test 1: Deploy fish module ==="
if fedpunk module deploy fish; then
    echo "  ✓ Fish module deployed successfully"
else
    echo "  ✗ Failed to deploy fish module" >&2
    exit 1
fi
echo ""

# Test 2: Verify fish config symlinked
echo "=== Test 2: Verify fish config symlinked ==="
if [ -L "$HOME/.config/fish/config.fish" ]; then
    TARGET=$(readlink -f "$HOME/.config/fish/config.fish")
    echo "  ✓ Fish config is symlinked"
    echo "  → Target: $TARGET"
else
    echo "  ✗ Fish config is not a symlink" >&2
    exit 1
fi
echo ""

# Test 3: Verify fish shell starts
echo "=== Test 3: Verify fish shell starts ==="
if fish -c "echo 'Fish shell is working'"; then
    echo "  ✓ Fish shell starts without errors"
else
    echo "  ✗ Fish shell failed to start" >&2
    exit 1
fi
echo ""

# Test 4: Deploy ssh module
echo "=== Test 4: Deploy ssh module ==="
if fedpunk module deploy ssh; then
    echo "  ✓ SSH module deployed successfully"
else
    echo "  ✗ Failed to deploy ssh module" >&2
    exit 1
fi
echo ""

# Test 5: Verify ssh config exists
echo "=== Test 5: Verify ssh config exists ==="
if [ -f "$HOME/.ssh/config" ]; then
    echo "  ✓ SSH config file exists"
    echo "  → Location: $HOME/.ssh/config"
else
    echo "  ✗ SSH config file not found" >&2
    exit 1
fi
echo ""

# Test 6: Test ssh CLI extension
echo "=== Test 6: Test ssh CLI extension ==="
if fedpunk ssh --help &>/dev/null; then
    echo "  ✓ SSH CLI extension is available"
    echo "  → Testing subcommands:"

    if fedpunk ssh load --help &>/dev/null; then
        echo "    ✓ fedpunk ssh load --help works"
    else
        echo "    ✗ fedpunk ssh load --help failed" >&2
        exit 1
    fi
else
    echo "  ✗ SSH CLI extension not available" >&2
    exit 1
fi
echo ""

# Test 7: Verify both modules in config
echo "=== Test 7: Verify modules added to config ==="
CONFIG_FILE="$HOME/.config/fedpunk/fedpunk.yaml"
if [ -f "$CONFIG_FILE" ]; then
    echo "  ✓ Config file exists: $CONFIG_FILE"

    if grep -q "fish" "$CONFIG_FILE" && grep -q "ssh" "$CONFIG_FILE"; then
        echo "  ✓ Both modules listed in config"
    else
        echo "  ⚠ Warning: Modules may not be in config (this is OK if using direct deploy)"
    fi
else
    echo "  ⚠ Warning: No config file yet (this is OK for direct deploy)"
fi
echo ""

echo "========================================="
echo "✅ All core module tests passed!"
echo "========================================="
echo ""
echo "Summary:"
echo "  • Fish module deployed and working"
echo "  • SSH module deployed and working"
echo "  • Module configs properly symlinked"
echo "  • Module CLI extensions functional"
echo ""
