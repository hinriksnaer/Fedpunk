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
echo "Building Fedpunk v${VERSION}"
echo ""

# Install build dependencies
echo "Installing build dependencies..."
dnf install -y rpm-build rpmdevtools git fish stow yq gum 2>&1 | grep -v "^$"

# Set up RPM build tree
echo ""
echo "Setting up RPM build tree..."
rpmdev-setuptree

# Create source tarball
echo ""
echo "Creating source tarball..."
cd "$REPO_ROOT"
TARBALL_NAME="fedpunk-${VERSION}"

# Clean up any existing tarball
rm -rf "/tmp/${TARBALL_NAME}" "/tmp/${TARBALL_NAME}.tar.gz"

# Create clean copy for tarball (excluding certain directories)
mkdir -p "/tmp/${TARBALL_NAME}"

# Copy files using tar to preserve permissions and exclude patterns
tar --exclude='.git' \
    --exclude='.devcontainer' \
    --exclude='test' \
    --exclude='*.log' \
    --exclude='.active-config' \
    --exclude='profiles/dev' \
    -cf - . | tar -xf - -C "/tmp/${TARBALL_NAME}/"

# Create tarball
cd /tmp
tar czf "${TARBALL_NAME}.tar.gz" "${TARBALL_NAME}/"

# Move to RPM sources
mv "${TARBALL_NAME}.tar.gz" ~/rpmbuild/SOURCES/
echo "Source tarball created: ~/rpmbuild/SOURCES/${TARBALL_NAME}.tar.gz"

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
