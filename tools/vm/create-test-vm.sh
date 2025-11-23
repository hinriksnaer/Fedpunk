#!/bin/bash
# Fedpunk Test VM Creator
# Creates a KVM virtual machine for testing fedpunk installations

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default configuration
VM_NAME="${1:-fedpunk-test}"
VM_MEMORY="${VM_MEMORY:-4096}" # MB
VM_CPUS="${VM_CPUS:-2}"
VM_DISK_SIZE="${VM_DISK_SIZE:-20}" # GB
VM_DIR="${VM_DIR:-$HOME/VMs}"
ISO_DIR="${ISO_DIR:-$VM_DIR/iso}"
FEDORA_VERSION="${FEDORA_VERSION:-43}"

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Fedpunk Test VM Creator${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check if VM already exists
if virsh list --all | grep -q "$VM_NAME"; then
    echo -e "${RED}Error: VM '$VM_NAME' already exists${NC}"
    echo "Remove it first with: virsh undefine $VM_NAME --remove-all-storage"
    exit 1
fi

# Check for virtualization support
echo -e "${YELLOW}→${NC} Checking virtualization support..."
if ! grep -qE 'vmx|svm' /proc/cpuinfo; then
    echo -e "${RED}Error: CPU virtualization not available${NC}"
    echo "Enable VT-x/AMD-V in your BIOS"
    exit 1
fi

if ! [ -c /dev/kvm ]; then
    echo -e "${RED}Error: /dev/kvm not found${NC}"
    echo "KVM kernel module may not be loaded"
    exit 1
fi
echo -e "${GREEN}✓${NC} Virtualization enabled"

# Create directories
echo -e "${YELLOW}→${NC} Setting up directories..."
mkdir -p "$VM_DIR/images"
mkdir -p "$ISO_DIR"
echo -e "${GREEN}✓${NC} Directories ready"

# Check for Fedora ISO
ISO_FILE="$ISO_DIR/Fedora-Server-netinst-x86_64-$FEDORA_VERSION-1.6.iso"
if [ ! -f "$ISO_FILE" ]; then
    # Try to find any Fedora ISO
    FOUND_ISO=$(find "$ISO_DIR" -name "Fedora-Server-*-$FEDORA_VERSION-*.iso" | head -1)
    if [ -n "$FOUND_ISO" ]; then
        ISO_FILE="$FOUND_ISO"
        echo -e "${GREEN}✓${NC} Found ISO: $(basename "$ISO_FILE")"
    else
        echo -e "${YELLOW}⚠${NC}  Fedora $FEDORA_VERSION ISO not found"
        echo ""
        echo "Download it from:"
        echo "  https://fedoraproject.org/server/download"
        echo ""
        echo "Save to: $ISO_DIR/"
        echo ""
        read -p "Press Enter when ISO is downloaded, or Ctrl+C to cancel..."

        # Check again
        FOUND_ISO=$(find "$ISO_DIR" -name "Fedora-Server-*-$FEDORA_VERSION-*.iso" | head -1)
        if [ -z "$FOUND_ISO" ]; then
            echo -e "${RED}Error: ISO still not found${NC}"
            exit 1
        fi
        ISO_FILE="$FOUND_ISO"
    fi
fi

# Create VM
echo ""
echo -e "${YELLOW}→${NC} Creating VM: $VM_NAME"
echo "  Memory: ${VM_MEMORY}MB"
echo "  CPUs: $VM_CPUS"
echo "  Disk: ${VM_DISK_SIZE}GB"
echo ""

DISK_PATH="$VM_DIR/images/$VM_NAME.qcow2"

# Create disk image
qemu-img create -f qcow2 "$DISK_PATH" "${VM_DISK_SIZE}G" >/dev/null
echo -e "${GREEN}✓${NC} Disk image created"

# Create VM with virt-install
virt-install \
    --name "$VM_NAME" \
    --memory "$VM_MEMORY" \
    --vcpus "$VM_CPUS" \
    --disk path="$DISK_PATH",format=qcow2,bus=virtio \
    --cdrom "$ISO_FILE" \
    --os-variant fedora-unknown \
    --network user,model=virtio \
    --graphics vnc,listen=127.0.0.1 \
    --console pty,target_type=serial \
    --virt-type kvm \
    --boot uefi \
    --noautoconsole

echo ""
echo -e "${GREEN}✓${NC} VM created successfully!"
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Next Steps${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "1. Connect to VM console:"
echo "   ${GREEN}virsh console $VM_NAME${NC}"
echo ""
echo "   Or use graphical console:"
echo "   ${GREEN}virt-viewer $VM_NAME${NC}"
echo ""
echo "2. Complete Fedora installation"
echo ""
echo "3. After installation completes and VM reboots:"
echo "   ${GREEN}./tools/vm/manage-vm.sh snapshot $VM_NAME fresh-install${NC}"
echo ""
echo "4. Test fedpunk installation"
echo ""
echo -e "${YELLOW}Tip:${NC} Use Ctrl+] to exit console"
echo ""
