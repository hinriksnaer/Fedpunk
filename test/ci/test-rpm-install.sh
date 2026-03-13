#!/usr/bin/env bash
# Test Fedpunk RPM installation
# Run this after build-rpm.sh

set -euo pipefail

echo "=== Fedpunk RPM Installation Test ==="
echo ""

# Find the RPM
RPM_FILE=$(find ~/rpmbuild/RPMS -name "fedpunk-*.rpm" -type f | head -n1)

if [ -z "$RPM_FILE" ]; then
    echo "ERROR: No RPM file found. Run build-rpm.sh first."
    exit 1
fi

echo "Installing RPM: $RPM_FILE"
dnf install -y "$RPM_FILE"

echo ""
echo "=== Verifying Installation ==="
echo ""

# Test 1: Check system files
echo "✓ Test 1: System files"
if [ -d "/usr/share/fedpunk" ]; then
    echo "  ✓ /usr/share/fedpunk exists"
else
    echo "  ✗ /usr/share/fedpunk missing"
    exit 1
fi

if [ -d "/usr/share/fedpunk/lib/fish" ]; then
    echo "  ✓ /usr/share/fedpunk/lib/fish exists"
else
    echo "  ✗ /usr/share/fedpunk/lib/fish missing"
    exit 1
fi

if [ -d "/usr/share/fedpunk/modules" ]; then
    echo "  ✓ /usr/share/fedpunk/modules exists"
else
    echo "  ✗ /usr/share/fedpunk/modules missing"
    exit 1
fi

if [ -d "/usr/share/fedpunk/cli" ]; then
    echo "  ✓ /usr/share/fedpunk/cli exists"
else
    echo "  ✗ /usr/share/fedpunk/cli missing"
    exit 1
fi

if [ -f "/usr/share/fedpunk/VERSION" ]; then
    VERSION=$(cat /usr/share/fedpunk/VERSION)
    echo "  ✓ /usr/share/fedpunk/VERSION exists ($VERSION)"
else
    echo "  ✗ /usr/share/fedpunk/VERSION missing"
    exit 1
fi

# Test 2: Check environment setup
echo ""
echo "✓ Test 2: Environment setup"
if [ -f "/etc/profile.d/fedpunk.sh" ]; then
    echo "  ✓ /etc/profile.d/fedpunk.sh exists"
else
    echo "  ✗ /etc/profile.d/fedpunk.sh missing"
    exit 1
fi

source /etc/profile.d/fedpunk.sh

if [ "$FEDPUNK_SYSTEM" = "/usr/share/fedpunk" ]; then
    echo "  ✓ FEDPUNK_SYSTEM=$FEDPUNK_SYSTEM"
else
    echo "  ✗ FEDPUNK_SYSTEM incorrect: $FEDPUNK_SYSTEM"
    exit 1
fi

if [ "$FEDPUNK_USER" = "$HOME/.local/share/fedpunk" ]; then
    echo "  ✓ FEDPUNK_USER=$FEDPUNK_USER"
else
    echo "  ✗ FEDPUNK_USER incorrect: $FEDPUNK_USER"
    exit 1
fi

# Test 3: Check wrapper command
echo ""
echo "✓ Test 3: Wrapper command"
if [ -x "/usr/bin/fedpunk" ]; then
    echo "  ✓ /usr/bin/fedpunk exists and is executable"
else
    echo "  ✗ /usr/bin/fedpunk missing or not executable"
    exit 1
fi

# Test 4: Test fedpunk CLI command
echo ""
echo "✓ Test 4: Testing fedpunk CLI"
if fedpunk --help | grep -q "Usage:"; then
    echo "  ✓ fedpunk --help works"
else
    echo "  ✗ fedpunk --help failed"
    exit 1
fi

if fedpunk --version >/dev/null 2>&1; then
    VERSION=$(fedpunk --version)
    echo "  ✓ fedpunk --version works ($VERSION)"
else
    echo "  ✗ fedpunk --version failed"
    exit 1
fi

if fedpunk module list >/dev/null 2>&1; then
    echo "  ✓ fedpunk module list works"
else
    echo "  ✗ fedpunk module list failed"
    exit 1
fi

# Test 5: Verify config directory can be created
echo ""
echo "✓ Test 5: Config directory"
mkdir -p "$HOME/.config/fedpunk"
if [ -d "$HOME/.config/fedpunk" ]; then
    echo "  ✓ $HOME/.config/fedpunk can be created"
else
    echo "  ✗ Failed to create config directory"
    exit 1
fi

# Create minimal config file for testing
cat > "$HOME/.config/fedpunk/fedpunk.yaml" <<EOF
modules: []
EOF

if [ -f "$HOME/.config/fedpunk/fedpunk.yaml" ]; then
    echo "  ✓ Config file can be created"
else
    echo "  ✗ Failed to create config file"
    exit 1
fi

# Test 6: Verify core libraries are loadable
echo ""
echo "✓ Test 6: Core library verification"
fish -c "
    source /usr/share/fedpunk/lib/fish/paths.fish
    source /usr/share/fedpunk/lib/fish/ui.fish
    source /usr/share/fedpunk/lib/fish/yaml-parser.fish

    if set -q FEDPUNK_SYSTEM
        echo '  ✓ FEDPUNK_SYSTEM set: \$FEDPUNK_SYSTEM'
    else
        echo '  ✗ FEDPUNK_SYSTEM not set'
        exit 1
    end

    if set -q FEDPUNK_USER
        echo '  ✓ FEDPUNK_USER set: \$FEDPUNK_USER'
    else
        echo '  ✗ FEDPUNK_USER not set'
        exit 1
    end
"

if [ $? -ne 0 ]; then
    echo "  ✗ Core library verification failed"
    exit 1
fi

echo ""
echo "=== All Core Tests Passed! ==="
echo ""
echo "Installation Summary:"
echo "  System files: /usr/share/fedpunk/"
echo "  User data:    $HOME/.local/share/fedpunk/"
echo "  Core libs:    Verified"
echo "  Module system: Functional"
echo ""
echo "Fedpunk core is ready for use!"
echo ""
