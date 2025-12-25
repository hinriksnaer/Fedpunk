#!/usr/bin/env bash
# Run all RPM tests (build + install + verify)
# This is the main entry point for testing
#
# Usage:
#   bash test/run-all-tests.sh         # Run both COPR and legacy modes (default)
#   bash test/run-all-tests.sh copr    # Run COPR mode only (recommended)
#   bash test/run-all-tests.sh legacy  # Run legacy mode only
#   bash test/run-all-tests.sh both    # Run both modes explicitly

set -euo pipefail

cd /workspace

MODE="${1:-copr}"  # Default to COPR mode

echo "╔════════════════════════════════════════════════════════╗"
echo "║                                                        ║"
echo "║          Fedpunk RPM Test Suite                       ║"
echo "║          Mode: ${MODE^^}                                   ║"
echo "║                                                        ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""

# Run COPR mode tests (replicates COPR's actual build process)
if [ "$MODE" = "copr" ] || [ "$MODE" = "both" ]; then
    echo "▶ Step 1: Building RPM (COPR mode with rpkg)..."
    bash test/build-rpm-copr-mode.sh
    if [ $? -ne 0 ]; then
        echo ""
        echo "✗ COPR-mode build failed"
        exit 1
    fi

    echo ""
    echo "▶ Step 2: Testing COPR-built RPM installation..."
    bash test/test-rpm-install.sh
    if [ $? -ne 0 ]; then
        echo ""
        echo "✗ COPR-mode installation test failed"
        exit 1
    fi

    echo ""
    echo "▶ Step 3: Testing core module deployment..."
    bash test/test-core-modules.sh
    if [ $? -ne 0 ]; then
        echo ""
        echo "✗ Core module tests failed"
        exit 1
    fi

    echo ""
    echo "▶ Step 4: Testing CLI functionality..."
    bash test/test-cli-commands.sh
    if [ $? -ne 0 ]; then
        echo ""
        echo "✗ CLI functionality tests failed"
        exit 1
    fi

    echo ""
    echo "✅ COPR Mode Tests Passed!"
    echo ""
fi

# Run legacy mode tests (for compatibility)
if [ "$MODE" = "legacy" ] || [ "$MODE" = "both" ]; then
    if [ "$MODE" = "both" ]; then
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
    fi

    echo "▶ Step 1: Building RPM (legacy mode with template replacement)..."
    bash test/build-rpm.sh
    if [ $? -ne 0 ]; then
        echo ""
        echo "✗ Legacy build failed"
        exit 1
    fi

    echo ""
    echo "▶ Step 2: Testing legacy-built RPM installation..."
    bash test/test-rpm-install.sh
    if [ $? -ne 0 ]; then
        echo ""
        echo "✗ Legacy installation test failed"
        exit 1
    fi

    echo ""
    echo "▶ Step 3: Testing core module deployment..."
    bash test/test-core-modules.sh
    if [ $? -ne 0 ]; then
        echo ""
        echo "✗ Core module tests failed"
        exit 1
    fi

    echo ""
    echo "▶ Step 4: Testing CLI functionality..."
    bash test/test-cli-commands.sh
    if [ $? -ne 0 ]; then
        echo ""
        echo "✗ CLI functionality tests failed"
        exit 1
    fi

    echo ""
    echo "✅ Legacy Mode Tests Passed!"
    echo ""
fi

echo ""
echo "╔════════════════════════════════════════════════════════╗"
echo "║                                                        ║"
echo "║              ✓ All Tests Passed!                      ║"
echo "║                                                        ║"
if [ "$MODE" = "copr" ]; then
    echo "║  COPR mode validated - package ready for COPR         ║"
elif [ "$MODE" = "legacy" ]; then
    echo "║  Legacy mode validated - package builds correctly     ║"
else
    echo "║  Both modes validated - fully tested!                 ║"
fi
echo "║                                                        ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""
