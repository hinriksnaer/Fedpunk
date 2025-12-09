#!/usr/bin/env bash
# Build RPM package for Fedpunk
# Run this inside a Fedora container

set -euo pipefail

# Get repo root directory (resolve once at start)
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "=== Fedpunk RPM Build Script ==="
echo ""

# Get version from spec file
VERSION=$(grep "^Version:" "$REPO_ROOT/fedpunk.spec" | awk '{print $2}')
# Get current commit hash for reference
COMMIT=$(cd "$REPO_ROOT" && git rev-parse HEAD 2>/dev/null || echo "HEAD")
SHORTCOMMIT=${COMMIT:0:7}

echo "Building Fedpunk v${VERSION} (${SHORTCOMMIT})"
echo ""

# Install build dependencies
echo "Installing build dependencies..."
dnf install -y rpm-build rpmdevtools git fish stow yq gum jq 2>&1 | grep -v "^$"

# Set up RPM build tree
echo ""
echo "Setting up RPM build tree..."
rpmdev-setuptree

# Create source tarball
echo ""
echo "Creating source tarball..."
cd "$REPO_ROOT"

# Tarball name should match what spec expects: fedpunk-{version}.tar.gz
TARBALL_NAME="fedpunk-${VERSION}.tar.gz"
# Directory inside tarball: fedpunk-{version}/
DIR_NAME="fedpunk-${VERSION}"

# Clean up any existing tarball
rm -rf "/tmp/${DIR_NAME}" "/tmp/${TARBALL_NAME}"

# Create clean copy for tarball (excluding certain directories)
mkdir -p "/tmp/${DIR_NAME}"

# Copy files using tar to preserve permissions and exclude patterns
tar --exclude='.git' \
    --exclude='.devcontainer' \
    --exclude='test' \
    --exclude='*.log' \
    --exclude='.active-config' \
    --exclude='profiles/dev' \
    -cf - . | tar -xf - -C "/tmp/${DIR_NAME}/"

# Create tarball
cd /tmp
tar czf "${TARBALL_NAME}" "${DIR_NAME}/"

# Move to RPM sources
mv "${TARBALL_NAME}" ~/rpmbuild/SOURCES/
echo "Source tarball created: ~/rpmbuild/SOURCES/${TARBALL_NAME}"

# Build RPM
echo ""
echo "Building RPM package..."
cd "$REPO_ROOT"
rpmbuild -ba fedpunk.spec

# Find the built RPM
RPM_FILE=$(find ~/rpmbuild/RPMS -name "fedpunk-*.rpm" -type f | head -n1)
SRPM_FILE=$(find ~/rpmbuild/SRPMS -name "fedpunk-*.src.rpm" -type f | head -n1)

echo ""
echo "=== Build Complete! ==="
echo ""
echo "Binary RPM: ${RPM_FILE}"
echo "Source RPM: ${SRPM_FILE}"
echo ""
echo "To install: dnf install -y ${RPM_FILE}"
echo ""
