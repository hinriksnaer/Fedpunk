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

if [ -d "/usr/share/fedpunk/profiles/default" ]; then
    echo "  ✓ /usr/share/fedpunk/profiles/default exists"
else
    echo "  ✗ /usr/share/fedpunk/profiles/default missing"
    exit 1
fi

if [ -d "/usr/share/fedpunk/themes" ]; then
    echo "  ✓ /usr/share/fedpunk/themes exists"
else
    echo "  ✗ /usr/share/fedpunk/themes missing"
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

# Test 4: Run fedpunk install (non-interactive, container mode)
echo ""
echo "✓ Test 4: Running fedpunk install"
fedpunk install --profile default --mode container --non-interactive

# Test 5: Verify user space created
echo ""
echo "✓ Test 5: User space creation"
if [ -d "$HOME/.local/share/fedpunk" ]; then
    echo "  ✓ $HOME/.local/share/fedpunk created"
else
    echo "  ✗ $HOME/.local/share/fedpunk missing"
    exit 1
fi

if [ -d "$HOME/.local/share/fedpunk/profiles/dev" ]; then
    echo "  ✓ $HOME/.local/share/fedpunk/profiles/dev created"
else
    echo "  ✗ $HOME/.local/share/fedpunk/profiles/dev missing"
    exit 1
fi

if [ -L "$HOME/.local/share/fedpunk/.active-config" ]; then
    ACTIVE_PROFILE=$(readlink "$HOME/.local/share/fedpunk/.active-config")
    echo "  ✓ .active-config -> $ACTIVE_PROFILE"
else
    echo "  ✗ .active-config symlink missing"
    exit 1
fi

if [ -d "$HOME/.local/share/fedpunk/cache/external" ]; then
    echo "  ✓ $HOME/.local/share/fedpunk/cache/external created"
else
    echo "  ✗ $HOME/.local/share/fedpunk/cache/external missing"
    exit 1
fi

# Test 6: Check Fish config generated
echo ""
echo "✓ Test 6: Fish configuration"
if [ -f "$HOME/.config/fish/conf.d/fedpunk-module-params.fish" ]; then
    echo "  ✓ $HOME/.config/fish/conf.d/fedpunk-module-params.fish generated"
else
    echo "  ✗ $HOME/.config/fish/conf.d/fedpunk-module-params.fish missing"
    exit 1
fi

# Test 7: Start Fish and verify
echo ""
echo "✓ Test 7: Fish shell verification"
fish -c '
    if set -q FEDPUNK_SYSTEM
        echo "  ✓ FEDPUNK_SYSTEM available in Fish: $FEDPUNK_SYSTEM"
    else
        echo "  ✗ FEDPUNK_SYSTEM not set in Fish"
        exit 1
    end

    if set -q FEDPUNK_USER
        echo "  ✓ FEDPUNK_USER available in Fish: $FEDPUNK_USER"
    else
        echo "  ✗ FEDPUNK_USER not set in Fish"
        exit 1
    end
'

echo ""
echo "=== All Tests Passed! ==="
echo ""
echo "Installation Summary:"
echo "  System files: /usr/share/fedpunk/"
echo "  User data:    $HOME/.local/share/fedpunk/"
echo "  Active profile: $(readlink $HOME/.local/share/fedpunk/.active-config | xargs basename)"
echo ""
echo "To use Fedpunk:"
echo "  exec fish"
echo ""
