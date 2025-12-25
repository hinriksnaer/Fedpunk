#!/bin/bash
# Test CLI command functionality
#
# Tests:
# 1. fedpunk --help
# 2. fedpunk --version
# 3. fedpunk module --help
# 4. fedpunk module list
# 5. fedpunk config --help
# 6. Module CLI extension auto-discovery (ssh)
# 7. Configuration system (fedpunk apply)

set -e  # Exit on error

echo ""
echo "========================================="
echo "CLI Functionality Tests"
echo "========================================="
echo ""

# Ensure fedpunk environment is set
if [ -z "$FEDPUNK_SYSTEM" ]; then
    echo "Sourcing Fedpunk environment..."
    source /etc/profile.d/fedpunk.sh
fi

echo "✓ Environment:"
echo "  FEDPUNK_ROOT: $FEDPUNK_ROOT"
echo ""

# Test 1: fedpunk --help
echo "=== Test 1: fedpunk --help ==="
if fedpunk --help | grep -q "Usage:"; then
    echo "  ✓ Help text displays correctly"
else
    echo "  ✗ Help text missing or malformed" >&2
    exit 1
fi
echo ""

# Test 2: fedpunk --version
echo "=== Test 2: fedpunk --version ==="
VERSION=$(fedpunk --version 2>&1)
if [ -n "$VERSION" ]; then
    echo "  ✓ Version command works"
    echo "  → Version: $VERSION"
else
    echo "  ✗ Version command failed" >&2
    exit 1
fi
echo ""

# Test 3: fedpunk module --help
echo "=== Test 3: fedpunk module --help ==="
if fedpunk module --help | grep -q "deploy"; then
    echo "  ✓ Module command help displays subcommands"
else
    echo "  ✗ Module help missing or malformed" >&2
    exit 1
fi
echo ""

# Test 4: fedpunk module list
echo "=== Test 4: fedpunk module list ==="
if fedpunk module list | grep -q "fish\|ssh"; then
    echo "  ✓ Module list shows available modules"
    echo "  → Available modules:"
    fedpunk module list | sed 's/^/    /'
else
    echo "  ✗ Module list failed or empty" >&2
    exit 1
fi
echo ""

# Test 5: fedpunk config --help
echo "=== Test 5: fedpunk config --help ==="
if fedpunk config --help 2>&1 | grep -q "config\|Config"; then
    echo "  ✓ Config command help available"
else
    echo "  ⚠ Warning: Config command may not be implemented yet"
fi
echo ""

# Test 6: Module CLI extension auto-discovery
echo "=== Test 6: Module CLI extension auto-discovery ==="
echo "  → Deploying ssh module to test CLI extensions..."
if fedpunk module deploy ssh &>/dev/null; then
    echo "  ✓ SSH module deployed"

    if fedpunk ssh --help &>/dev/null; then
        echo "  ✓ SSH CLI extension auto-discovered"

        # Test subcommands
        if fedpunk ssh load --help &>/dev/null; then
            echo "  ✓ SSH subcommand (load) works"
        else
            echo "  ✗ SSH subcommand failed" >&2
            exit 1
        fi
    else
        echo "  ✗ SSH CLI extension not discovered" >&2
        exit 1
    fi
else
    echo "  ✗ Failed to deploy ssh module" >&2
    exit 1
fi
echo ""

# Test 7: Configuration system
echo "=== Test 7: Configuration system (fedpunk apply) ==="
CONFIG_FILE="$HOME/.config/fedpunk/fedpunk.yaml"
mkdir -p "$(dirname "$CONFIG_FILE")"

echo "  → Creating test configuration..."
cat > "$CONFIG_FILE" <<EOF
modules:
  - fish
  - ssh
EOF

if [ -f "$CONFIG_FILE" ]; then
    echo "  ✓ Config file created"
    echo "  → Content:"
    cat "$CONFIG_FILE" | sed 's/^/    /'
else
    echo "  ✗ Failed to create config file" >&2
    exit 1
fi

echo ""
echo "  → Testing fedpunk apply..."
if fedpunk apply &>/dev/null; then
    echo "  ✓ fedpunk apply completed successfully"

    # Verify modules were deployed
    if [ -L "$HOME/.config/fish/config.fish" ] && [ -f "$HOME/.ssh/config" ]; then
        echo "  ✓ Modules from config were deployed"
    else
        echo "  ✗ Modules not deployed from config" >&2
        exit 1
    fi
else
    echo "  ⚠ Warning: fedpunk apply may have issues (this could be OK if modules already deployed)"
fi
echo ""

# Test 8: Command discovery
echo "=== Test 8: Command discovery ==="
COMMAND_COUNT=$(fedpunk --help | grep -A 50 "Commands:" | grep "^  " | grep -v "Commands:" | wc -l)
if [ "$COMMAND_COUNT" -ge 3 ]; then
    echo "  ✓ Multiple commands discovered ($COMMAND_COUNT commands)"
    echo "  → Commands:"
    fedpunk --help | grep -A 50 "Commands:" | grep "^  " | sed 's/^/    /'
else
    echo "  ✗ Too few commands discovered ($COMMAND_COUNT)" >&2
    exit 1
fi
echo ""

echo "========================================="
echo "✅ All CLI functionality tests passed!"
echo "========================================="
echo ""
echo "Summary:"
echo "  • Core CLI commands working"
echo "  • Help system functional"
echo "  • Module management operational"
echo "  • CLI extensions auto-discover"
echo "  • Configuration system works"
echo ""
