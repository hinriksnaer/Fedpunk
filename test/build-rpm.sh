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

# Install build dependencies (including rpkg for template processing)
echo "Installing build dependencies..."
dnf install -y rpm-build rpmdevtools rpkg git fish stow yq gum jq 2>&1 | grep -v "^$"

# Set up RPM build tree
echo ""
echo "Setting up RPM build tree..."
rpmdev-setuptree

# Build SRPM and RPM using rpkg (handles {{{ }}} template syntax)
echo ""
echo "Building RPM package with rpkg..."
cd "$REPO_ROOT"

# rpkg will automatically:
# 1. Process {{{ git_dir_pack }}} to create tarball from git
# 2. Process {{{ git_dir_setup_macro }}} in %prep
# 3. Build the SRPM and RPM
rpkg local

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
