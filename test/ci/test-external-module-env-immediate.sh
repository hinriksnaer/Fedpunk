#!/bin/bash
# Test external module environment variables are available immediately in all shells
#
# Tests:
# 1. External module with environment variables deploys successfully
# 2. Environment variables are generated in Fish config (~/.config/fish/conf.d/)
# 3. Environment variables are generated in Bash config (~/.config/fedpunk/profile.d/)
# 4. Environment variables are available in current shell session after sourcing
# 5. Environment variables AUTO-LOAD in new Fish shells (conf.d auto-loading)
# 6. Environment variables AUTO-LOAD in new Bash shells (via /etc/profile.d/fedpunk.sh)
# 7. Environment variables AUTO-LOAD in new Zsh shells (via /etc/profile.d/fedpunk.sh)
# 8. Environment variables AUTO-LOAD in new Sh shells (via /etc/profile.d/fedpunk.sh)

set -e

echo ""
echo "========================================="
echo "External Module Env Auto-Load Test"
echo "========================================="
echo "All shells auto-load via /etc/profile.d or conf.d"
echo ""

# Setup test environment
TEST_DIR=$(mktemp -d -t fedpunk-ext-env-test-XXXXXX)
trap "rm -rf $TEST_DIR" EXIT

echo "Test environment: $TEST_DIR"
echo ""

# Override HOME and XDG for isolated testing
export HOME="$TEST_DIR/home"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
mkdir -p "$HOME"
mkdir -p "$HOME/.config/fish/conf.d"

# Create simulated /etc/profile.d directory for testing
ETC_PROFILE_D="$TEST_DIR/etc/profile.d"
mkdir -p "$ETC_PROFILE_D"

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
$1
"
}

#
# Test 1: Create test external module with environment variables
#
echo "=== Test 1: Create test external module with env vars ==="

TEST_MODULE_REPO="$TEST_DIR/test-env-ext-module"
mkdir -p "$TEST_MODULE_REPO/config/.config/test-env-ext"

cat > "$TEST_MODULE_REPO/module.yaml" <<'EOF'
module:
  name: test-env-ext-module
  description: Test external module with environment variables

environment:
  TEST_API_URL: "https://api.example.com"
  TEST_DEBUG_MODE: "true"
  TEST_REGION: "us-east-1"

packages:
  dnf: []

stow:
  target: $HOME
  conflicts: warn
EOF

echo "config: test" > "$TEST_MODULE_REPO/config/.config/test-env-ext/config.txt"

# Initialize as git repo
cd "$TEST_MODULE_REPO"
git init -q
git config user.email "test@fedpunk.test"
git config user.name "Test User"
git add .
git commit -q -m "Initial commit"
cd "$FEDPUNK_ROOT"

TEST_MODULE_URL="file://$TEST_MODULE_REPO"
echo "  Created test module repo with env vars:"
echo "    TEST_API_URL: https://api.example.com"
echo "    TEST_DEBUG_MODE: true"
echo "    TEST_REGION: us-east-1"
echo ""

#
# Test 2: Deploy module and generate env config
#
echo "=== Test 2: Deploy module and generate env config ==="

# Initialize config
run_fish "
source \$FEDPUNK_SYSTEM/lib/fish/config.fish
fedpunk-config-init
" 2>&1 || true

# Use the local path instead of file:// URL
# (file:// URLs are not recognized by module-ref-is-url)
MODULE_PATH="$TEST_MODULE_REPO"

# Add module to config using local path
run_fish "
source \$FEDPUNK_SYSTEM/lib/fish/config.fish
fedpunk-config-add-module '$MODULE_PATH'
" 2>&1 || true

# Generate environment config
run_fish "
source \$FEDPUNK_SYSTEM/lib/fish/config.fish
source \$FEDPUNK_SYSTEM/lib/fish/env-injector.fish
source \$FEDPUNK_SYSTEM/lib/fish/module-resolver.fish
env-generate-fish-config
" 2>&1 | grep -v "^Generated" || true

echo "  Environment configs generated"

# Create simulated /etc/profile.d/fedpunk.sh that auto-sources user env
cat > "$ETC_PROFILE_D/fedpunk.sh" <<'PROFILE_EOF'
# Fedpunk environment variables
# Auto-loaded by all shells on login

export FEDPUNK_SYSTEM=/usr/share/fedpunk
export FEDPUNK_USER=$HOME/.local/share/fedpunk
export FEDPUNK_ROOT=$FEDPUNK_SYSTEM

# Auto-load user module environment variables
if [ -f "$HOME/.config/fedpunk/profile.d/fedpunk-env.sh" ]; then
    . "$HOME/.config/fedpunk/profile.d/fedpunk-env.sh"
fi
PROFILE_EOF

echo "  Created simulated /etc/profile.d/fedpunk.sh"
echo ""

#
# Test 3: Verify Fish config file exists and has correct content
#
echo "=== Test 3: Verify Fish config file ==="

FISH_ENV_CONFIG="$HOME/.config/fish/conf.d/fedpunk-module-env.fish"

if [ ! -f "$FISH_ENV_CONFIG" ]; then
    echo "  FAIL: Fish env config not generated at $FISH_ENV_CONFIG" >&2
    exit 1
fi

echo "  SUCCESS: Fish env config exists"
echo "  Contents:"
cat "$FISH_ENV_CONFIG" | sed 's/^/    /'
echo ""

# Verify all three env vars are present
for var in TEST_API_URL TEST_DEBUG_MODE TEST_REGION; do
    if grep -q "set -gx $var" "$FISH_ENV_CONFIG"; then
        echo "  SUCCESS: $var found in Fish config"
    else
        echo "  FAIL: $var not found in Fish config" >&2
        exit 1
    fi
done

echo ""

#
# Test 4: Verify Bash config file exists and has correct content
#
echo "=== Test 4: Verify Bash config file ==="

BASH_ENV_CONFIG="$HOME/.config/fedpunk/profile.d/fedpunk-env.sh"

if [ ! -f "$BASH_ENV_CONFIG" ]; then
    echo "  FAIL: Bash env config not generated at $BASH_ENV_CONFIG" >&2
    exit 1
fi

echo "  SUCCESS: Bash env config exists"
echo "  Contents:"
cat "$BASH_ENV_CONFIG" | sed 's/^/    /'
echo ""

# Verify all three env vars are present
for var in TEST_API_URL TEST_DEBUG_MODE TEST_REGION; do
    if grep -q "export $var=" "$BASH_ENV_CONFIG"; then
        echo "  SUCCESS: $var found in Bash config"
    else
        echo "  FAIL: $var not found in Bash config" >&2
        exit 1
    fi
done

echo ""

#
# Test 5: Verify env vars are available in Fish session after sourcing
#
echo "=== Test 5: Verify env vars available in Fish after sourcing ==="

# Test in a Fish session that sources the config
TEST_API_URL_VALUE=$(run_fish "
source '$FISH_ENV_CONFIG'
echo \$TEST_API_URL
")

if [ "$TEST_API_URL_VALUE" = "https://api.example.com" ]; then
    echo "  SUCCESS: TEST_API_URL available in Fish session"
    echo "    Value: $TEST_API_URL_VALUE"
else
    echo "  FAIL: TEST_API_URL not available or wrong value" >&2
    echo "    Expected: https://api.example.com"
    echo "    Got: $TEST_API_URL_VALUE"
    exit 1
fi

TEST_DEBUG_MODE_VALUE=$(run_fish "
source '$FISH_ENV_CONFIG'
echo \$TEST_DEBUG_MODE
")

if [ "$TEST_DEBUG_MODE_VALUE" = "true" ]; then
    echo "  SUCCESS: TEST_DEBUG_MODE available in Fish session"
    echo "    Value: $TEST_DEBUG_MODE_VALUE"
else
    echo "  FAIL: TEST_DEBUG_MODE not available or wrong value" >&2
    exit 1
fi

echo ""

#
# Test 6: Verify env vars available in new Fish shell (Fish-specific mechanism)
#
echo "=== Test 6: Verify env vars in new Fish shell (auto-loaded) ==="
echo "  Note: Fish uses conf.d auto-loading, other shells use /etc/profile.d"
echo ""

# Spawn a new Fish shell and check if env is available
# The config is in conf.d so it should auto-load (Fish feature)
NEW_SHELL_VALUE=$(fish -c "
set -gx HOME '$HOME'
set -gx XDG_CONFIG_HOME '$HOME/.config'
echo \$TEST_API_URL
")

if [ "$NEW_SHELL_VALUE" = "https://api.example.com" ]; then
    echo "  SUCCESS: TEST_API_URL auto-loaded in new Fish shell"
    echo "    Value: $NEW_SHELL_VALUE"
    echo "    (Fish automatically loads ~/.config/fish/conf.d/* files)"
else
    echo "  FAIL: TEST_API_URL not auto-loaded in Fish" >&2
    echo "    Expected Fish to auto-load conf.d files"
    exit 1
fi

echo ""

#
# Test 7: Verify Bash auto-loads via /etc/profile.d/fedpunk.sh
#
echo "=== Test 7: Verify Bash auto-loads env vars ==="
echo "  Simulating /etc/profile.d/fedpunk.sh sourcing"
echo ""

# Source the profile.d file (simulates login shell behavior)
BASH_AUTO_VALUE=$(bash -c "
export HOME='$HOME'
. '$ETC_PROFILE_D/fedpunk.sh'
echo \$TEST_API_URL
")

if [ "$BASH_AUTO_VALUE" = "https://api.example.com" ]; then
    echo "  SUCCESS: TEST_API_URL auto-loaded in Bash"
    echo "    Value: $BASH_AUTO_VALUE"
    echo "    (via /etc/profile.d/fedpunk.sh)"
else
    echo "  FAIL: TEST_API_URL not auto-loaded in Bash" >&2
    echo "    Expected: https://api.example.com"
    echo "    Got: $BASH_AUTO_VALUE"
    exit 1
fi

BASH_DEBUG_VALUE=$(bash -c "
export HOME='$HOME'
. '$ETC_PROFILE_D/fedpunk.sh'
echo \$TEST_DEBUG_MODE
")

if [ "$BASH_DEBUG_VALUE" = "true" ]; then
    echo "  SUCCESS: TEST_DEBUG_MODE auto-loaded in Bash"
    echo "    Value: $BASH_DEBUG_VALUE"
else
    echo "  FAIL: TEST_DEBUG_MODE not auto-loaded in Bash" >&2
    exit 1
fi

echo ""

#
# Test 8: Verify Zsh auto-loads via /etc/profile.d/fedpunk.sh
#
echo "=== Test 8: Verify Zsh auto-loads env vars ==="

if command -v zsh >/dev/null 2>&1; then
    ZSH_AUTO_VALUE=$(zsh -c "
    export HOME='$HOME'
    . '$ETC_PROFILE_D/fedpunk.sh'
    echo \$TEST_API_URL
    ")

    if [ "$ZSH_AUTO_VALUE" = "https://api.example.com" ]; then
        echo "  SUCCESS: TEST_API_URL auto-loaded in Zsh"
        echo "    Value: $ZSH_AUTO_VALUE"
    else
        echo "  FAIL: TEST_API_URL not auto-loaded in Zsh" >&2
        exit 1
    fi
else
    echo "  SKIP: Zsh not installed"
fi

echo ""

#
# Test 9: Verify Sh auto-loads via /etc/profile.d/fedpunk.sh
#
echo "=== Test 9: Verify Sh auto-loads env vars ==="

SH_AUTO_VALUE=$(sh -c "
export HOME='$HOME'
. '$ETC_PROFILE_D/fedpunk.sh'
echo \$TEST_API_URL
")

if [ "$SH_AUTO_VALUE" = "https://api.example.com" ]; then
    echo "  SUCCESS: TEST_API_URL auto-loaded in Sh"
    echo "    Value: $SH_AUTO_VALUE"
else
    echo "  FAIL: TEST_API_URL not auto-loaded in Sh" >&2
    exit 1
fi

echo ""

#
# Summary
#
echo "========================================="
echo "All external module env tests passed!"
echo "========================================="
echo ""
echo "Summary:"
echo "  ✓ External module environment variables defined in module.yaml"
echo "  ✓ Fish config generated: ~/.config/fish/conf.d/fedpunk-module-env.fish"
echo "  ✓ Bash config generated: ~/.config/fedpunk/profile.d/fedpunk-env.sh"
echo "  ✓ Environment variables available in Fish after sourcing"
echo "  ✓ Environment variables AUTO-LOAD in new Fish shells (conf.d auto-loading)"
echo "  ✓ Environment variables AUTO-LOAD in Bash (via /etc/profile.d/fedpunk.sh)"
echo "  ✓ Environment variables AUTO-LOAD in Zsh (via /etc/profile.d/fedpunk.sh)"
echo "  ✓ Environment variables AUTO-LOAD in Sh (via /etc/profile.d/fedpunk.sh)"
echo ""
echo "Auto-loading mechanisms:"
echo "  • Fish: Loads ~/.config/fish/conf.d/fedpunk-module-env.fish automatically"
echo "  • Bash/Zsh/Sh: /etc/profile.d/fedpunk.sh sources ~/.config/fedpunk/profile.d/fedpunk-env.sh"
echo "  • All shells: No manual configuration required!"
echo ""
