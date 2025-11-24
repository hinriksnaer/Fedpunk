#!/usr/bin/env fish
# Fedpunk VM Management Script
# Handles common VM operations: start, stop, snapshot, revert, destroy

# Colors
set -g RED '\033[0;31m'
set -g GREEN '\033[0;32m'
set -g YELLOW '\033[1;33m'
set -g BLUE '\033[0;34m'
set -g NC '\033[0m'

set COMMAND (count $argv > /dev/null && echo $argv[1] || echo "")
set VM_NAME (count $argv > 1 && echo $argv[2] || echo "fedpunk-test")

function show_help
    echo "Fedpunk VM Management"
    echo ""
    echo "Usage: "(status filename)" <command> [vm-name] [args...]"
    echo ""
    echo "Commands:"
    echo "  start <vm>                  Start the VM"
    echo "  stop <vm>                   Stop the VM (graceful)"
    echo "  kill <vm>                   Force stop the VM"
    echo "  open <vm>                   Open GUI viewer (virt-viewer)"
    echo "  console <vm>                Connect to serial console"
    echo "  snapshot-save <vm> <name>   Save a snapshot"
    echo "  snapshot-load <vm> <name>   Load/restore a snapshot"
    echo "  snapshot-list <vm>          List all snapshots"
    echo "  destroy <vm>                Delete VM and all data"
    echo "  eject-iso <vm>              Eject installation media"
    echo "  status [vm]                 Show VM status"
    echo ""
    echo "Legacy aliases (still supported):"
    echo "  snapshot, revert, list-snapshots"
    echo ""
    echo "Examples:"
    echo "  "(status filename)" start fedpunk-test"
    echo "  "(status filename)" open fedpunk-test"
    echo "  "(status filename)" snapshot-save fedpunk-test fresh-install"
    echo "  "(status filename)" snapshot-load fedpunk-test fresh-install"
    echo ""
end

function check_vm_exists
    if not virsh list --all | grep -q "$VM_NAME"
        echo -e "$RED""Error: VM '$VM_NAME' does not exist""$NC"
        exit 1
    end
end

switch "$COMMAND"
    case start
        check_vm_exists
        echo -e "$YELLOW→$NC Starting VM: $VM_NAME"
        virsh start "$VM_NAME"
        echo -e "$GREEN✓$NC VM started"
        echo "Connect with: virsh console $VM_NAME"

    case stop
        check_vm_exists
        echo -e "$YELLOW→$NC Stopping VM: $VM_NAME"
        virsh shutdown "$VM_NAME"
        echo -e "$GREEN✓$NC Shutdown signal sent"

    case kill
        check_vm_exists
        echo -e "$YELLOW→$NC Force stopping VM: $VM_NAME"
        virsh destroy "$VM_NAME"
        echo -e "$GREEN✓$NC VM stopped"

    case open gui
        check_vm_exists
        echo -e "$YELLOW→$NC Opening GUI viewer for: $VM_NAME"
        if not command -v virt-viewer &> /dev/null
            echo -e "$RED""Error: virt-viewer not installed""$NC"
            echo "Install with: sudo dnf install virt-viewer"
            exit 1
        end
        virt-viewer "$VM_NAME" &
        echo -e "$GREEN✓$NC GUI viewer launched"

    case console
        check_vm_exists
        echo "Connecting to $VM_NAME console..."
        echo "Press Ctrl+] to exit"
        echo ""
        virsh console "$VM_NAME"

    case snapshot-save snapshot
        set SNAPSHOT_NAME (count $argv > 2 && echo $argv[3] || echo "")
        if test -z "$SNAPSHOT_NAME"
            echo -e "$RED""Error: Snapshot name required""$NC"
            echo "Usage: manage-vm.fish snapshot-save <vm> <snapshot-name>"
            exit 1
        end
        check_vm_exists
        echo -e "$YELLOW→$NC Creating snapshot: $SNAPSHOT_NAME"
        virsh snapshot-create-as "$VM_NAME" "$SNAPSHOT_NAME" \
            "Snapshot created "(date '+%Y-%m-%d %H:%M:%S')
        echo -e "$GREEN✓$NC Snapshot created"

    case snapshot-list list-snapshots
        check_vm_exists
        echo "Snapshots for $VM_NAME:"
        virsh snapshot-list "$VM_NAME"

    case snapshot-load revert
        set SNAPSHOT_NAME (count $argv > 2 && echo $argv[3] || echo "")
        if test -z "$SNAPSHOT_NAME"
            echo -e "$RED""Error: Snapshot name required""$NC"
            echo "Usage: manage-vm.fish snapshot-load <vm> <snapshot-name>"
            exit 1
        end
        check_vm_exists
        echo -e "$YELLOW→$NC Reverting to snapshot: $SNAPSHOT_NAME"
        virsh snapshot-revert "$VM_NAME" "$SNAPSHOT_NAME"
        echo -e "$GREEN✓$NC Reverted to snapshot"

    case eject-iso
        check_vm_exists
        echo -e "$YELLOW→$NC Ejecting installation media from $VM_NAME"

        # Find the cdrom device
        set CDROM_DEV (virsh dumpxml "$VM_NAME" | grep -A 2 "device='cdrom'" | grep "target dev" | sed -n "s/.*dev='\([^']*\)'.*/\1/p")

        if test -z "$CDROM_DEV"
            echo -e "$RED""Error: No CD-ROM device found""$NC"
            exit 1
        end

        virsh change-media "$VM_NAME" "$CDROM_DEV" --eject --config
        echo -e "$GREEN✓$NC Installation media ejected"

    case destroy
        check_vm_exists
        echo -e "$RED""WARNING: This will permanently delete the VM and all its data!""$NC"
        read -P "Are you sure? Type 'yes' to confirm: " confirm
        if test "$confirm" != "yes"
            echo "Cancelled"
            exit 0
        end

        echo -e "$YELLOW→$NC Destroying VM: $VM_NAME"

        # Stop if running
        if virsh list --state-running | grep -q "$VM_NAME"
            virsh destroy "$VM_NAME"
        end

        # Remove with storage
        virsh undefine "$VM_NAME" --remove-all-storage --snapshots-metadata
        echo -e "$GREEN✓$NC VM destroyed"

    case status
        if test "$VM_NAME" = "fedpunk-test" -a (count $argv) -lt 2
            # Show all VMs if no specific VM specified
            echo "All VMs:"
            virsh list --all
        else
            check_vm_exists
            echo "Status for $VM_NAME:"
            virsh dominfo "$VM_NAME"
        end

    case help --help -h ''
        show_help

    case '*'
        echo -e "$RED""Error: Unknown command '$COMMAND'""$NC"
        echo ""
        show_help
        exit 1
end
