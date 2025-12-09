#!/usr/bin/env bash
# Run all RPM tests (build + install + verify)
# This is the main entry point for testing

set -euo pipefail

cd /workspace

echo "╔════════════════════════════════════════════════════════╗"
echo "║                                                        ║"
echo "║          Fedpunk COPR Packaging Test Suite            ║"
echo "║                                                        ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# Step 1: Build RPM
echo "▶ Step 1/2: Building RPM package..."
bash test/build-rpm.sh
if [ $? -ne 0 ]; then
    echo ""
    echo "✗ Build failed"
    exit 1
fi

# Step 2: Install and test
echo ""
echo "▶ Step 2/2: Installing and testing..."
bash test/test-rpm-install.sh
if [ $? -ne 0 ]; then
    echo ""
    echo "✗ Installation test failed"
    exit 1
fi

echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║                                                        ║"
echo "║              ✓ All Tests Passed!                      ║"
echo "║                                                        ║"
echo "║  The RPM package is ready for COPR upload             ║"
echo "║                                                        ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""
