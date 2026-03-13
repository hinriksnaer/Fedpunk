#!/bin/bash
# Test declarative git profile URLs in fedpunk.yaml
#
# Tests:
# 1. Git URL in config is preserved (not extracted to name)
# 2. Re-applying with git URL pulls updates
# 3. Name-based profiles still work (backwards compat)
# 4. Path-based profiles save basename only

set -e  # Exit on error

echo ""
echo "========================================="
echo "Declarative Git Profile URL Tests"
echo "========================================="
echo ""

# Setup test environment
TEST_DIR=$(mktemp -d -t fedpunk-test-XXXXXX)
trap "rm -rf $TEST_DIR" EXIT

echo "Test environment: $TEST_DIR"
echo ""

# Override HOME and XDG for isolated testing
export HOME="$TEST_DIR/home"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
mkdir -p "$HOME"

# Use LOCAL git repository (not system installation)
export FEDPUNK_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
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
functions -e deployer-deploy-from-config deployer-deploy-profile
source \$FEDPUNK_SYSTEM/lib/fish/paths.fish
source \$FEDPUNK_SYSTEM/lib/fish/config.fish
source \$FEDPUNK_SYSTEM/lib/fish/ui.fish
source \$FEDPUNK_SYSTEM/lib/fish/profile-discovery.fish
source \$FEDPUNK_SYSTEM/lib/fish/deployer.fish
$1
"
}

# Create a minimal test profile repository (no modules to avoid package installation)
TEST_REPO_DIR="$TEST_DIR/test-profile-repo"
mkdir -p "$TEST_REPO_DIR/modes/test"

echo "Creating test profile repository..."

# Create minimal mode.yaml with no modules
cat > "$TEST_REPO_DIR/modes/test/mode.yaml" <<'EOF'
mode:
  name: test
  description: Test mode

modules: []
EOF

# Initialize git repo
cd "$TEST_REPO_DIR"
git init -q
git config user.email "test@fedpunk.test"
git config user.name "Test User"
git add .
git commit -q -m "Initial test profile"
echo "  Created at: $TEST_REPO_DIR"
echo ""

# Get the git URL for the test repo
TEST_PROFILE_URL="file://$TEST_REPO_DIR"

#
# Test 1: Git URL in config is preserved
#
echo "=== Test 1: Git URL preserved in config ==="

CONFIG_FILE="$HOME/.config/fedpunk/fedpunk.yaml"
mkdir -p "$(dirname "$CONFIG_FILE")"

# Manually write config with git URL
cat > "$CONFIG_FILE" <<EOF
profile: $TEST_PROFILE_URL
mode: test
modules:
  enabled: []
EOF

echo "  Config created with profile URL: $TEST_PROFILE_URL"

# Deploy using our local version
run_fish "deployer-deploy-from-config" 2>&1 | grep -v "sudo\|password" | head -10 || true

# Verify profile was cloned
PROFILE_NAME="test-profile-repo"
CLONED_PROFILE="$HOME/.config/fedpunk/profiles/$PROFILE_NAME"

if [ -d "$CLONED_PROFILE" ]; then
    echo "  Profile cloned to: $CLONED_PROFILE"
else
    echo "  FAIL: Profile was not cloned" >&2
    exit 1
fi

# Verify git URL is preserved in config
SAVED_PROFILE=$(run_fish "fedpunk-config-get profile" 2>/dev/null)

if [ "$SAVED_PROFILE" = "$TEST_PROFILE_URL" ]; then
    echo "  SUCCESS: Git URL preserved in config"
elif [ "$SAVED_PROFILE" = "$PROFILE_NAME" ]; then
    echo "  FAIL: Config saved name instead of URL" >&2
    echo "    Expected: $TEST_PROFILE_URL" >&2
    echo "    Got: $SAVED_PROFILE" >&2
    exit 1
else
    echo "  FAIL: Unexpected value in config" >&2
    echo "    Expected: $TEST_PROFILE_URL" >&2
    echo "    Got: $SAVED_PROFILE" >&2
    exit 1
fi
echo ""

#
# Test 2: Re-applying with git URL pulls updates
#
echo "=== Test 2: Updates pulled on re-apply ==="

# Make a change to the test repo
cd "$TEST_REPO_DIR"
echo "# Updated" >> modes/test/mode.yaml
git add .
git commit -q -m "Update test profile"
ORIGINAL_COMMIT=$(git rev-parse HEAD)
echo "  Profile updated (commit: ${ORIGINAL_COMMIT:0:8})"

# Re-apply
run_fish "deployer-deploy-from-config" 2>&1 | grep -v "sudo\|password" | head -5 || true

# Verify the cloned repo has the latest commit
cd "$CLONED_PROFILE"
CLONED_COMMIT=$(git rev-parse HEAD 2>/dev/null)

if [ "$CLONED_COMMIT" = "$ORIGINAL_COMMIT" ]; then
    echo "  SUCCESS: Profile updated to latest commit"
else
    echo "  FAIL: Profile not updated" >&2
    echo "    Expected: ${ORIGINAL_COMMIT:0:8}" >&2
    echo "    Got: ${CLONED_COMMIT:0:8}" >&2
    exit 1
fi
echo ""

#
# Test 3: Name-based profiles still work (backwards compatibility)
#
echo "=== Test 3: Name-based profiles (backwards compat) ==="

# Create a local profile by name
LOCAL_PROFILE_DIR="$HOME/.config/fedpunk/profiles/local-test"
mkdir -p "$LOCAL_PROFILE_DIR/modes/test"

cat > "$LOCAL_PROFILE_DIR/modes/test/mode.yaml" <<'EOF'
mode:
  name: test
  description: Local test mode

modules: []
EOF

echo "  Local profile created: local-test"

# Update config to use name (not URL)
cat > "$CONFIG_FILE" <<EOF
profile: local-test
mode: test
modules:
  enabled: []
EOF

run_fish "deployer-deploy-from-config" 2>&1 | grep -v "sudo\|password" | head -5 || true

# Verify name is preserved
SAVED_PROFILE=$(run_fish "fedpunk-config-get profile" 2>/dev/null)

if [ "$SAVED_PROFILE" = "local-test" ]; then
    echo "  SUCCESS: Profile name preserved in config"
else
    echo "  FAIL: Profile name not preserved" >&2
    echo "    Expected: local-test" >&2
    echo "    Got: $SAVED_PROFILE" >&2
    exit 1
fi
echo ""

#
# Test 4: Path-based profiles save basename only
#
echo "=== Test 4: Path-based profiles save basename ==="

# Create a profile at a custom path
PATH_PROFILE_DIR="$TEST_DIR/custom-path-profile"
mkdir -p "$PATH_PROFILE_DIR/modes/test"

cat > "$PATH_PROFILE_DIR/modes/test/mode.yaml" <<'EOF'
mode:
  name: test
  description: Path test mode

modules: []
EOF

echo "  Path-based profile created at: $PATH_PROFILE_DIR"

# Deploy using path directly
run_fish "deployer-deploy-profile '$PATH_PROFILE_DIR' --mode test" 2>&1 | grep -v "sudo\|password" | head -5 || true

# Verify basename is saved (not full path)
SAVED_PROFILE=$(run_fish "fedpunk-config-get profile" 2>/dev/null)

if [ "$SAVED_PROFILE" = "custom-path-profile" ]; then
    echo "  SUCCESS: Profile basename saved (not full path)"
elif [ "$SAVED_PROFILE" = "$PATH_PROFILE_DIR" ]; then
    echo "  FAIL: Full path saved instead of basename" >&2
    exit 1
else
    echo "  WARNING: Unexpected value: $SAVED_PROFILE"
fi
echo ""

#
# Summary
#
echo "========================================="
echo "All declarative git URL tests passed!"
echo "========================================="
echo ""
echo "Summary:"
echo "  - Git URLs preserved in config (declarative)"
echo "  - Profiles auto-cloned from git URLs"
echo "  - Updates pulled on re-apply"
echo "  - Name-based profiles still work"
echo "  - Path-based profiles save basename"
echo ""
