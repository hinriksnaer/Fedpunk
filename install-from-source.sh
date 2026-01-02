#!/usr/bin/env bash
#
# Install Fedpunk from source via RPM
#
# This script builds an RPM from the current git checkout and installs it.
# Useful for development and testing local changes.
#
# Usage:
#   ./install-from-source.sh           # Build and install
#   ./install-from-source.sh --build   # Build only (no install)
#   ./install-from-source.sh --clean   # Clean build artifacts
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()  { echo -e "${BLUE}→${NC} $*"; }
success() { echo -e "${GREEN}✓${NC} $*"; }
warn()  { echo -e "${YELLOW}!${NC} $*"; }
error() { echo -e "${RED}✗${NC} $*" >&2; }

# Parse arguments
BUILD_ONLY=false
CLEAN_ONLY=false

for arg in "$@"; do
    case $arg in
        --build)
            BUILD_ONLY=true
            ;;
        --clean)
            CLEAN_ONLY=true
            ;;
        --help|-h)
            echo "Install Fedpunk from source via RPM"
            echo ""
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  --build   Build RPM only (don't install)"
            echo "  --clean   Remove build artifacts"
            echo "  --help    Show this help"
            exit 0
            ;;
    esac
done

# Clean mode
if $CLEAN_ONLY; then
    info "Cleaning build artifacts..."
    rm -rf ~/rpmbuild/SOURCES/fedpunk-*.tar.gz
    rm -rf ~/rpmbuild/SPECS/fedpunk.spec
    rm -rf ~/rpmbuild/RPMS/noarch/fedpunk-*.rpm
    rm -rf ~/rpmbuild/SRPMS/fedpunk-*.src.rpm
    rm -rf ~/rpmbuild/BUILD/fedpunk-*
    rm -rf ~/rpmbuild/BUILDROOT/fedpunk-*
    success "Build artifacts cleaned"
    exit 0
fi

# Verify we're in a git repository
if [[ ! -d .git ]]; then
    error "Not in a git repository. Run from Fedpunk source directory."
    exit 1
fi

# Check for uncommitted changes
if [[ -n "$(git status --porcelain)" ]]; then
    warn "You have uncommitted changes. They will NOT be included in the build."
    warn "Commit your changes first, or they won't be in the RPM."
    echo ""
    read -p "Continue anyway? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Get version from spec file
VERSION=$(grep "^Version:" fedpunk.spec | awk '{print $2}')
COMMIT=$(git rev-parse --short HEAD)

echo ""
echo "┌─────────────────────────────────────────┐"
echo "│  Fedpunk Source Installation            │"
echo "│  Version: $VERSION ($COMMIT)               │"
echo "└─────────────────────────────────────────┘"
echo ""

# Check dependencies
info "Checking build dependencies..."
MISSING_DEPS=()

command -v rpmbuild >/dev/null 2>&1 || MISSING_DEPS+=("rpm-build")
command -v rpmdev-setuptree >/dev/null 2>&1 || MISSING_DEPS+=("rpmdevtools")

if [[ ${#MISSING_DEPS[@]} -gt 0 ]]; then
    error "Missing dependencies: ${MISSING_DEPS[*]}"
    echo ""
    echo "Install with:"
    echo "  sudo dnf install ${MISSING_DEPS[*]}"
    exit 1
fi

success "Build dependencies available"

# Set up RPM build tree
info "Setting up RPM build tree..."
rpmdev-setuptree 2>/dev/null || true

# Clean old fedpunk RPMs to avoid confusion
rm -f ~/rpmbuild/RPMS/noarch/fedpunk-*.rpm 2>/dev/null || true
rm -f ~/rpmbuild/SRPMS/fedpunk-*.rpm 2>/dev/null || true

# Create source tarball from current HEAD
info "Creating source tarball from HEAD..."
TARBALL="$HOME/rpmbuild/SOURCES/fedpunk-${VERSION}.tar.gz"
git archive --format=tar.gz --prefix="fedpunk-${VERSION}/" -o "$TARBALL" HEAD
success "Created $TARBALL"

# Prepare spec file for local build
info "Preparing spec file..."
SPEC_FILE="$HOME/rpmbuild/SPECS/fedpunk.spec"
cp fedpunk.spec "$SPEC_FILE"

# Patch spec for local build (replace COPR macros with standard ones)
sed -i "s|Source0:.*|Source0:        fedpunk-%{version}.tar.gz|" "$SPEC_FILE"
sed -i '/^tar --strip-components=1/c\%autosetup' "$SPEC_FILE"

success "Spec file prepared"

# Build RPM
info "Building RPM package..."
echo ""

if ! rpmbuild -ba "$SPEC_FILE"; then
    error "RPM build failed"
    exit 1
fi

echo ""
success "RPM build complete"

# Find the most recently built RPM
RPM_FILE=$(find ~/rpmbuild/RPMS -name "fedpunk-${VERSION}*.rpm" -type f ! -name "*.src.rpm" -printf '%T@ %p\n' | sort -rn | head -1 | cut -d' ' -f2-)

if [[ -z "$RPM_FILE" ]]; then
    error "Could not find built RPM"
    exit 1
fi

echo ""
echo "Built: $RPM_FILE"
echo ""

# Install if not build-only
if $BUILD_ONLY; then
    info "Build-only mode. To install, run:"
    echo "  sudo dnf reinstall -y $RPM_FILE"
else
    info "Installing RPM..."

    # Use reinstall to force update even if version matches
    if ! sudo dnf reinstall -y "$RPM_FILE" 2>/dev/null; then
        # If reinstall fails (package not installed), try regular install
        if ! sudo dnf install -y "$RPM_FILE" --allowerasing; then
            error "Installation failed"
            exit 1
        fi
    fi

    echo ""
    success "Fedpunk $VERSION ($COMMIT) installed successfully!"
    echo ""
    echo "Try:"
    echo "  fedpunk --version"
    echo "  fedpunk module installed"
    echo "  fedpunk module available"
fi
