#!/usr/bin/env fish
# Fedpunk VM Creation Script
# Creates a test VM for fedpunk installation testing

# Colors
set -g RED '\033[0;31m'
set -g GREEN '\033[0;32m'
set -g YELLOW '\033[1;33m'
set -g BLUE '\033[0;34m'
set -g NC '\033[0m'

# Default configuration
set VM_NAME (count $argv > 0 && echo $argv[1] || echo "fedpunk-test")
set VM_MEMORY (set -q VM_MEMORY && echo $VM_MEMORY || echo "8192") # MB (8GB for smooth desktop performance)
set VM_CPUS (set -q VM_CPUS && echo $VM_CPUS || echo "4") # 4 cores for better responsiveness
set VM_DISK_SIZE (set -q VM_DISK_SIZE && echo $VM_DISK_SIZE || echo "40") # GB (more space for desktop apps)
set VM_DIR (set -q VM_DIR && echo $VM_DIR || echo "$HOME/VMs")
set ISO_DIR (set -q ISO_DIR && echo $ISO_DIR || echo "$VM_DIR/iso")
set FEDORA_VERSION (set -q FEDORA_VERSION && echo $FEDORA_VERSION || echo "43")

# Paths
set DISK_PATH "$VM_DIR/$VM_NAME.qcow2"
set ISO_FILE "$ISO_DIR/Fedora-Server-netinst-x86_64-$FEDORA_VERSION.iso"

# Check for virtualization support
if not grep -qE '(vmx|svm)' /proc/cpuinfo
    echo -e "$RED""Error: Hardware virtualization not supported or not enabled in BIOS""$NC"
    echo "Please enable VT-x (Intel) or AMD-V (AMD) in your BIOS settings"
    exit 1
end

echo ""
echo -e "$BLUE""━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━""$NC"
echo -e "$BLUE""  Fedpunk VM Creator""$NC"
echo -e "$BLUE""━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━""$NC"
echo ""
echo "VM Configuration:"
echo "  Name:   $VM_NAME"
echo "  Memory: "(math "$VM_MEMORY / 1024")"GB"
echo "  CPUs:   $VM_CPUS"
echo "  Disk:   "$VM_DISK_SIZE"GB"
echo "  ISO:    Fedora $FEDORA_VERSION Server"
echo ""

# Check if libvirtd is running
if not systemctl is-active --quiet libvirtd
    echo -e "$YELLOW→$NC Starting libvirtd service..."
    sudo systemctl start libvirtd
    or begin
        echo -e "$RED""Error: Failed to start libvirtd""$NC"
        echo "Please install libvirt: sudo dnf install @virtualization"
        exit 1
    end
end

# Create directories
echo -e "$YELLOW→$NC Creating directories..."
mkdir -p "$VM_DIR" "$ISO_DIR"
echo -e "$GREEN✓$NC Directories created"

# Check if VM already exists
if virsh list --all | grep -q "$VM_NAME"
    echo -e "$RED""Error: VM '$VM_NAME' already exists""$NC"
    echo "Please destroy it first or choose a different name"
    exit 1
end

# Download ISO if needed
if not test -f "$ISO_FILE"
    echo ""
    echo -e "$YELLOW→$NC Fedora $FEDORA_VERSION ISO not found""$NC"
    echo "Download from: https://fedoraproject.org/server/download"
    echo "Save to: $ISO_FILE"
    echo ""
    echo "Quick download:"
    echo "  cd $ISO_DIR"
    echo "  curl -LO https://download.fedoraproject.org/pub/fedora/linux/releases/$FEDORA_VERSION/Server/x86_64/iso/Fedora-Server-netinst-x86_64-$FEDORA_VERSION-*.iso"
    echo ""
    read -P "Press Enter after downloading the ISO, or Ctrl+C to cancel: "

    # Check again
    if not test -f "$ISO_FILE"
        echo -e "$RED""Error: ISO file still not found at $ISO_FILE""$NC"
        exit 1
    end
end

echo -e "$GREEN✓$NC ISO file found: $ISO_FILE"
echo ""

# Create disk image
echo -e "$YELLOW→$NC Creating disk image..."
qemu-img create -f qcow2 "$DISK_PATH" "$VM_DISK_SIZE""G" >/dev/null
echo -e "$GREEN✓$NC Disk image created"

# Create VM with virt-install
virt-install \
    --name "$VM_NAME" \
    --memory "$VM_MEMORY" \
    --vcpus "$VM_CPUS" \
    --cpu host-passthrough \
    --disk path="$DISK_PATH",format=qcow2,bus=virtio,cache=writeback \
    --cdrom "$ISO_FILE" \
    --os-variant fedora-unknown \
    --network user,model=virtio \
    --graphics spice,listen=127.0.0.1,gl.enable=yes \
    --video qxl \
    --channel spicevmc \
    --console pty,target_type=serial \
    --virt-type kvm \
    --boot uefi \
    --noautoconsole

echo ""
echo -e "$GREEN✓$NC VM created successfully!"
echo ""
echo "Next steps:"
echo "  1. Connect to console: virsh console $VM_NAME"
echo "  2. Or use GUI:         virt-viewer $VM_NAME"
echo "  3. Complete Fedora installation"
echo "  4. After install, eject ISO: tools/vm/manage-vm.fish eject-iso $VM_NAME"
echo "  5. Restart VM:               tools/vm/manage-vm.fish start $VM_NAME"
echo "  6. Create baseline snapshot: tools/vm/manage-vm.fish snapshot-save $VM_NAME fresh-install"
echo ""
echo "See tools/vm/README.md for detailed testing workflow"
echo ""
