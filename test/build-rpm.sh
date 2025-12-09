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

# For CI builds: Create tarball manually and use a modified spec
# For COPR builds: rpkg handles everything via templates
echo ""
echo "Creating source tarball..."
cd "$REPO_ROOT"

# Create tarball with proper directory structure for %autosetup
TARBALL="$HOME/rpmbuild/SOURCES/fedpunk-${VERSION}.tar.gz"
git archive --format=tar.gz --prefix=fedpunk-${VERSION}/ -o "$TARBALL" HEAD

echo "Source tarball created: $TARBALL"
echo ""

# Create a modified spec file that doesn't use rpkg templates
SPEC_WORK="$HOME/rpmbuild/SPECS/fedpunk.spec"
cp "$REPO_ROOT/fedpunk.spec" "$SPEC_WORK"

# Replace rpkg templates with static values for CI builds
# Source0: {{{ git_dir_pack }}} -> fedpunk-%{version}.tar.gz
# %prep: {{{ git_dir_setup_macro }}} -> %autosetup
sed -i 's/{{{ git_dir_pack }}}/fedpunk-%{version}.tar.gz/' "$SPEC_WORK"
sed -i 's/{{{ git_dir_setup_macro }}}/%autosetup/' "$SPEC_WORK"

echo "Building RPM packages..."
rpmbuild -ba "$SPEC_WORK"

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
