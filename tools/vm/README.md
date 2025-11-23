# Fedpunk VM Testing Tools

Tools for creating and managing virtual machines to test fedpunk installations.

## Prerequisites

- **KVM/QEMU** - Hardware virtualization enabled in BIOS
- **libvirt** - Virtual machine management
- **virt-install** - VM creation tool

Install on Fedora:
```bash
sudo dnf install @virtualization
sudo systemctl enable --now libvirtd
sudo usermod -aG libvirt $USER
# Log out and back in for group changes to take effect
```

## Quick Start

### 1. Create a Test VM

```bash
cd tools/vm
./create-test-vm.sh
```

This creates a VM with:
- **Name:** fedpunk-test
- **Memory:** 4GB
- **CPUs:** 2
- **Disk:** 20GB
- **OS:** Fedora 43 Server

**Customize settings:**
```bash
VM_MEMORY=8192 VM_CPUS=4 VM_DISK_SIZE=30 ./create-test-vm.sh my-test-vm
```

### 2. Install Fedora

Connect to the VM console:
```bash
virsh console fedpunk-test
# OR use graphical console
virt-viewer fedpunk-test &
```

Complete the Fedora installation:
1. Select language
2. Configure installation destination (auto-detect 20GB disk)
3. Set root password or create user
4. Begin installation
5. Wait for completion and reboot

**Exit console:** Press `Ctrl + ]`

### 3. Create Baseline Snapshot

After Fedora installation completes:

```bash
# Eject installation media
./manage-vm.sh eject-iso fedpunk-test

# Reboot to fresh install
./manage-vm.sh kill fedpunk-test
./manage-vm.sh start fedpunk-test

# Create snapshot of clean install
./manage-vm.sh snapshot fedpunk-test fresh-install
```

### 4. Test Fedpunk Installation

Transfer fedpunk to the VM:
```bash
# Get VM IP (if using bridged networking)
virsh domifaddr fedpunk-test

# Or use virsh console to work inside VM
virsh console fedpunk-test
```

Inside the VM:
```bash
# Clone or copy fedpunk
git clone <your-fedpunk-repo>
cd fedpunk

# Run installer
./install.sh
```

### 5. Revert and Test Again

If something breaks or you want to test from scratch:

```bash
./manage-vm.sh revert fedpunk-test fresh-install
```

This instantly restores the VM to the clean Fedora state!

## VM Management Commands

### Basic Operations

```bash
# Start VM
./manage-vm.sh start fedpunk-test

# Stop VM (graceful shutdown)
./manage-vm.sh stop fedpunk-test

# Force stop
./manage-vm.sh kill fedpunk-test

# Connect to console
./manage-vm.sh console fedpunk-test

# Check status
./manage-vm.sh status fedpunk-test
```

### Snapshot Management

```bash
# Create snapshot
./manage-vm.sh snapshot fedpunk-test <snapshot-name>

# List snapshots
./manage-vm.sh list-snapshots fedpunk-test

# Revert to snapshot
./manage-vm.sh revert fedpunk-test <snapshot-name>
```

### Common Snapshots

Recommended snapshot workflow:

1. **fresh-install** - Clean Fedora installation
2. **fedpunk-installed** - After successful fedpunk installation
3. **profile-applied** - After selecting and applying a profile

Example:
```bash
# Baseline
./manage-vm.sh snapshot fedpunk-test fresh-install

# After fedpunk installs
./manage-vm.sh snapshot fedpunk-test fedpunk-installed

# Test profile
./manage-vm.sh snapshot fedpunk-test before-profile-test

# Revert if something breaks
./manage-vm.sh revert fedpunk-test fedpunk-installed
```

### Cleanup

```bash
# Delete VM and all data
./manage-vm.sh destroy fedpunk-test
```

## Testing Workflow

### Manual Installation Testing

1. Create fresh VM
2. Install Fedora
3. Snapshot: `fresh-install`
4. Install fedpunk
5. Snapshot: `fedpunk-base`
6. Test profiles/modules
7. Revert to `fedpunk-base` for clean testing

### Repository/Kickstart Testing

1. Create VM with custom repo configured
2. Use Fedora installer with "Installation Source" pointing to fedpunk repo
3. Test automated installation
4. Snapshot at various stages

## Troubleshooting

### VM won't start - "no bootable device"

The Fedora installation wasn't completed. Re-attach ISO:
```bash
./manage-vm.sh kill fedpunk-test
virsh change-media fedpunk-test sda --insert ~/VMs/iso/Fedora-*.iso --config
./manage-vm.sh start fedpunk-test
```

### VM boots into installer after installation

Installation media wasn't ejected:
```bash
./manage-vm.sh eject-iso fedpunk-test
```

### KVM not available

Enable virtualization in BIOS (VT-x for Intel, AMD-V for AMD).

Check if enabled:
```bash
lscpu | grep -i virtualization
ls -l /dev/kvm
```

### Console is blank

Wait a few seconds for boot, or press Enter. Try graphical console:
```bash
virt-viewer fedpunk-test &
```

## Environment Variables

Customize VM creation:

```bash
VM_NAME=my-vm           # VM name (default: fedpunk-test)
VM_MEMORY=8192          # Memory in MB (default: 4096)
VM_CPUS=4               # CPU cores (default: 2)
VM_DISK_SIZE=30         # Disk size in GB (default: 20)
VM_DIR=~/VMs            # VM storage directory
ISO_DIR=~/VMs/iso       # ISO storage directory
FEDORA_VERSION=43       # Fedora version (default: 43)
```

Example:
```bash
VM_MEMORY=8192 VM_CPUS=4 ./create-test-vm.sh powerful-test
```

## Tips

- **Use snapshots liberally** - They're cheap and fast
- **Name snapshots descriptively** - `before-hyprland-test` is better than `snapshot1`
- **Test destructive operations** in VMs before running on real hardware
- **Keep fresh-install snapshot** - Always have a clean baseline
- **Script your tests** - Automate repetitive testing scenarios

## Next Steps

After setting up your test VM:

1. Test fedpunk installation process
2. Test different profiles (minimal, dev, etc.)
3. Test module installation and removal
4. Verify all lifecycle hooks work
5. Test on atomic desktop variants (Silverblue/Kinoite)

For custom repository and Installation Source testing, see: `docs/repository.md`
