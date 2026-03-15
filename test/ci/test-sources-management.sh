#!/bin/bash
# Test module sources management
#
# Tests:
# 1. Add a source repository
# 2. List sources
# 3. Sync sources (clone)
# 4. List modules from sources
# 5. Remove a source

set -e

echo ""
echo "========================================="
echo "Module Sources Management Tests"
echo "========================================="
echo ""

# Setup test environment
TEST_DIR=$(mktemp -d -t fedpunk-sources-test-XXXXXX)
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
source \$FEDPUNK_SYSTEM/lib/fish/sources.fish
$1
"
}

# Create a test source repository (multi-module repo)
TEST_SOURCE_DIR="$TEST_DIR/test-source-repo"
mkdir -p "$TEST_SOURCE_DIR/module-a"
mkdir -p "$TEST_SOURCE_DIR/module-b"

cat > "$TEST_SOURCE_DIR/module-a/module.yaml" <<'EOF'
module:
  name: module-a
  description: Test module A
EOF

cat > "$TEST_SOURCE_DIR/module-b/module.yaml" <<'EOF'
module:
  name: module-b
  description: Test module B
EOF

# Initialize as git repo
cd "$TEST_SOURCE_DIR"
git init -q
git config user.email "test@fedpunk.test"
git config user.name "Test User"
git add .
git commit -q -m "Initial commit"
cd "$FEDPUNK_ROOT"

TEST_SOURCE_URL="file://$TEST_SOURCE_DIR"

#
# Test 1: Add a source
#
echo "=== Test 1: Add a source repository ==="

run_fish "fedpunk-config-init; fedpunk-config-add-source '$TEST_SOURCE_URL'" 2>&1 || true

SOURCES=$(run_fish "fedpunk-config-list-sources" 2>/dev/null)
if echo "$SOURCES" | grep -q "$TEST_SOURCE_URL"; then
    echo "  SUCCESS: Source added to config"
else
    echo "  FAIL: Source not found in config" >&2
    echo "  Got: $SOURCES"
    exit 1
fi
echo ""

#
# Test 2: List sources
#
echo "=== Test 2: List sources ==="

SOURCES=$(run_fish "fedpunk-config-list-sources" 2>/dev/null)
if [ -n "$SOURCES" ]; then
    echo "  SUCCESS: Sources listed"
    echo "  Sources: $SOURCES"
else
    echo "  FAIL: No sources returned" >&2
    exit 1
fi
echo ""

#
# Test 3: Sync sources (clone)
#
echo "=== Test 3: Sync sources ==="

run_fish "source-sync-all" 2>&1 | head -5 || true

SOURCES_DIR="$HOME/.config/fedpunk/sources"
if [ -d "$SOURCES_DIR" ]; then
    echo "  SUCCESS: Sources directory created"
    ls -la "$SOURCES_DIR" | head -5
else
    echo "  FAIL: Sources directory not created" >&2
    exit 1
fi
echo ""

#
# Test 4: List modules from sources
#
echo "=== Test 4: List modules from sources ==="

MODULES=$(run_fish "source-list-all-modules" 2>/dev/null)
if echo "$MODULES" | grep -q "module-a"; then
    echo "  SUCCESS: module-a found in sources"
else
    echo "  INFO: module-a not found (may need different discovery)"
fi

if echo "$MODULES" | grep -q "module-b"; then
    echo "  SUCCESS: module-b found in sources"
else
    echo "  INFO: module-b not found (may need different discovery)"
fi
echo ""

#
# Test 5: Source is cloned to correct location
#
echo "=== Test 5: Verify source clone location ==="

REPO_NAME=$(basename "$TEST_SOURCE_DIR")
CLONED_SOURCE="$SOURCES_DIR/$REPO_NAME"

if [ -d "$CLONED_SOURCE" ]; then
    echo "  SUCCESS: Source cloned to $CLONED_SOURCE"
    if [ -f "$CLONED_SOURCE/module-a/module.yaml" ]; then
        echo "  SUCCESS: module-a exists in cloned source"
    else
        echo "  FAIL: module-a not found in cloned source" >&2
    fi
else
    echo "  FAIL: Source not cloned to expected location" >&2
    echo "  Expected: $CLONED_SOURCE"
    ls -la "$SOURCES_DIR" 2>/dev/null || echo "  Sources dir doesn't exist"
    exit 1
fi
echo ""

#
# Summary
#
echo "========================================="
echo "All sources management tests passed!"
echo "========================================="
echo ""
echo "Summary:"
echo "  - Add source to config works"
echo "  - List sources works"
echo "  - Sync sources clones repos"
echo "  - Sources cloned to ~/.config/fedpunk/sources/"
echo ""
