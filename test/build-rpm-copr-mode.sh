#!/usr/bin/env bash
# Validate spec file with rpkg (COPR validation)
# This verifies rpkg can process the spec file templates

set -euo pipefail

# Detect repo root (should be /workspace in CI)
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo "=== Fedpunk COPR Spec File Validation ==="
echo "Validating that rpkg can process spec file templates"
echo ""

# Get version from spec file
VERSION=$(grep "^Version:" "$REPO_ROOT/fedpunk.spec" | awk '{print $2}')
# Get current commit hash for reference
COMMIT=$(cd "$REPO_ROOT" && git rev-parse HEAD 2>/dev/null || echo "HEAD")
SHORTCOMMIT=${COMMIT:0:7}

echo "Validating Fedpunk v${VERSION} (${SHORTCOMMIT})"
echo ""

# Install only what's needed for SRPM validation
echo "Installing rpkg and dependencies..."
dnf install -y rpkg rpmdevtools git 2>&1 | grep -v "^$"

# Set up RPM build tree
echo ""
echo "Setting up RPM build tree..."
rpmdev-setuptree

# Navigate to repo root
cd "$REPO_ROOT"

# Verify git repository
echo ""
echo "Current directory: $(pwd)"
echo "Git status:"
git log -1 --oneline

# Build SRPM using rpkg (this is what COPR does)
echo ""
echo "Building SRPM with rpkg..."
echo "This validates rpkg can process: {{{ git_dir_pack }}} and {{{ git_dir_setup_macro }}}"
echo ""

rpkg srpm --outdir="$HOME/rpmbuild/SRPMS/"

# Find the SRPM
SRPM_FILE=$(find ~/rpmbuild/SRPMS -name "fedpunk-*.src.rpm" -type f | head -n1)

if [ -z "$SRPM_FILE" ]; then
    echo ""
    echo "❌ SRPM creation failed"
    echo "rpkg could not process spec file templates"
    exit 1
fi

echo ""
echo "=== Validation Successful! ==="
echo ""
echo "✅ rpkg successfully created SRPM: $SRPM_FILE"
echo "✅ Spec file templates are valid"
echo "✅ COPR build will work"
echo ""
echo "Note: This validates spec file only. Full RPM build happens in legacy mode."
echo ""
