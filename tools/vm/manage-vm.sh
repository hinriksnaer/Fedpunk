#!/bin/bash
# Fedpunk VM Management Script
# Handles common VM operations: start, stop, snapshot, revert, destroy

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

COMMAND="${1:-}"
VM_NAME="${2:-fedpunk-test}"

show_help() {
    echo "Fedpunk VM Management"
    echo ""
    echo "Usage: $0 <command> [vm-name] [args...]"
    echo ""
    echo "Commands:"
    echo "  start <vm>              Start the VM"
    echo "  stop <vm>               Stop the VM (graceful)"
    echo "  kill <vm>               Force stop the VM"
    echo "  console <vm>            Connect to VM console"
    echo "  snapshot <vm> <name>    Create a snapshot"
    echo "  list-snapshots <vm>     List all snapshots"
    echo "  revert <vm> <snapshot>  Revert to a snapshot"
    echo "  destroy <vm>            Delete VM and all data"
    echo "  eject-iso <vm>          Eject installation media"
    echo "  status [vm]             Show VM status"
    echo ""
    echo "Examples:"
    echo "  $0 start fedpunk-test"
    echo "  $0 snapshot fedpunk-test fresh-install"
    echo "  $0 revert fedpunk-test fresh-install"
    echo ""
}

check_vm_exists() {
    if ! virsh list --all | grep -q "$VM_NAME"; then
        echo -e "${RED}Error: VM '$VM_NAME' does not exist${NC}"
        exit 1
    fi
}

case "$COMMAND" in
    start)
        check_vm_exists
        echo -e "${YELLOW}→${NC} Starting VM: $VM_NAME"
        virsh start "$VM_NAME"
        echo -e "${GREEN}✓${NC} VM started"
        echo "Connect with: virsh console $VM_NAME"
        ;;

    stop)
        check_vm_exists
        echo -e "${YELLOW}→${NC} Stopping VM: $VM_NAME"
        virsh shutdown "$VM_NAME"
        echo -e "${GREEN}✓${NC} Shutdown signal sent"
        ;;

    kill)
        check_vm_exists
        echo -e "${YELLOW}→${NC} Force stopping VM: $VM_NAME"
        virsh destroy "$VM_NAME"
        echo -e "${GREEN}✓${NC} VM stopped"
        ;;

    console)
        check_vm_exists
        echo "Connecting to $VM_NAME console..."
        echo "Press Ctrl+] to exit"
        echo ""
        virsh console "$VM_NAME"
        ;;

    snapshot)
        SNAPSHOT_NAME="${3:-}"
        if [ -z "$SNAPSHOT_NAME" ]; then
            echo -e "${RED}Error: Snapshot name required${NC}"
            echo "Usage: $0 snapshot <vm> <snapshot-name>"
            exit 1
        fi
        check_vm_exists
        echo -e "${YELLOW}→${NC} Creating snapshot: $SNAPSHOT_NAME"
        virsh snapshot-create-as "$VM_NAME" "$SNAPSHOT_NAME" \
            "Snapshot created $(date '+%Y-%m-%d %H:%M:%S')"
        echo -e "${GREEN}✓${NC} Snapshot created"
        ;;

    list-snapshots)
        check_vm_exists
        echo "Snapshots for $VM_NAME:"
        virsh snapshot-list "$VM_NAME"
        ;;

    revert)
        SNAPSHOT_NAME="${3:-}"
        if [ -z "$SNAPSHOT_NAME" ]; then
            echo -e "${RED}Error: Snapshot name required${NC}"
            echo "Usage: $0 revert <vm> <snapshot-name>"
            exit 1
        fi
        check_vm_exists
        echo -e "${YELLOW}→${NC} Reverting to snapshot: $SNAPSHOT_NAME"
        virsh snapshot-revert "$VM_NAME" "$SNAPSHOT_NAME"
        echo -e "${GREEN}✓${NC} Reverted to snapshot"
        ;;

    eject-iso)
        check_vm_exists
        echo -e "${YELLOW}→${NC} Ejecting installation media from $VM_NAME"

        # Find the cdrom device
        CDROM_DEV=$(virsh dumpxml "$VM_NAME" | grep -A 2 "device='cdrom'" | grep "target dev" | sed -n "s/.*dev='\([^']*\)'.*/\1/p")

        if [ -z "$CDROM_DEV" ]; then
            echo -e "${RED}Error: No CD-ROM device found${NC}"
            exit 1
        fi

        virsh change-media "$VM_NAME" "$CDROM_DEV" --eject --config
        echo -e "${GREEN}✓${NC} Installation media ejected"
        ;;

    destroy)
        check_vm_exists
        echo -e "${RED}WARNING: This will permanently delete the VM and all its data!${NC}"
        read -p "Are you sure? Type 'yes' to confirm: " confirm
        if [ "$confirm" != "yes" ]; then
            echo "Cancelled"
            exit 0
        fi

        echo -e "${YELLOW}→${NC} Destroying VM: $VM_NAME"

        # Stop if running
        if virsh list --state-running | grep -q "$VM_NAME"; then
            virsh destroy "$VM_NAME"
        fi

        # Remove with storage
        virsh undefine "$VM_NAME" --remove-all-storage --snapshots-metadata
        echo -e "${GREEN}✓${NC} VM destroyed"
        ;;

    status)
        if [ "$VM_NAME" == "fedpunk-test" ] && [ $# -lt 2 ]; then
            # Show all VMs if no specific VM specified
            echo "All VMs:"
            virsh list --all
        else
            check_vm_exists
            echo "Status for $VM_NAME:"
            virsh dominfo "$VM_NAME"
        fi
        ;;

    help|--help|-h|"")
        show_help
        ;;

    *)
        echo -e "${RED}Error: Unknown command '$COMMAND'${NC}"
        echo ""
        show_help
        exit 1
        ;;
esac
