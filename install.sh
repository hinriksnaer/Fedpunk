#!/bin/bash
# Fedpunk Bootstrap Installer
# Minimal bash wrapper that ensures Fish is installed, then runs the Fish-based installer

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo ""
echo "███████╗███████╗██████╗ ██████╗ ██╗   ██╗███╗   ██╗██╗  ██╗"
echo "██╔════╝██╔════╝██╔══██╗██╔══██╗██║   ██║████╗  ██║██║ ██╔╝"
echo "█████╗  █████╗  ██║  ██║██████╔╝██║   ██║██╔██╗ ██║█████╔╝ "
echo "██╔══╝  ██╔══╝  ██║  ██║██╔═══╝ ██║   ██║██║╚██╗██║██╔═██╗ "
echo "██║     ███████╗██████╔╝██║     ╚██████╔╝██║ ╚████║██║  ██╗"
echo "╚═╝     ╚══════╝╚═════╝ ╚═╝      ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═╝"
echo ""
echo "Bootstrap installer"
echo ""

# Check if Fish is installed
if ! command -v fish &>/dev/null; then
    echo -e "${YELLOW}Fish shell not found. Installing...${NC}"

    # Detect if we're on atomic desktop
    if [[ -f /run/ostree-booted ]]; then
        echo -e "${YELLOW}Atomic desktop detected - layering Fish with rpm-ostree${NC}"
        sudo rpm-ostree install --idempotent --allow-inactive fish

        # Check if reboot is needed
        if rpm-ostree status | grep -q "pending"; then
            echo ""
            echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo -e "${RED}⚠️  REBOOT REQUIRED${NC}"
            echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            echo "Fish has been layered but requires a reboot to activate."
            echo "After rebooting, run this installer again:"
            echo "  ./install.sh $*"
            echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
            exit 0
        fi
    else
        echo -e "${YELLOW}Traditional Fedora detected - installing Fish with DNF${NC}"
        sudo dnf install -y -q fish
    fi

    echo -e "${GREEN}✓ Fish installed successfully${NC}"
    echo ""
else
    echo -e "${GREEN}✓ Fish shell found${NC}"
    echo ""
fi

# Run the Fish-based installer
echo "Launching Fish-based installer..."
echo ""

# Get the directory where this script lives
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Execute the Fish installer with all arguments passed through
exec fish "${SCRIPT_DIR}/install.fish" "$@"
