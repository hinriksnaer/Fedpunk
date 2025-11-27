#!/bin/bash
# Expand /dev/mapper/fedora-root to use all available space in the volume group

set -e

VG_NAME="fedora"
LV_NAME="root"
LV_PATH="/dev/mapper/${VG_NAME}-${LV_NAME}"

# Check if LV exists
if [ ! -e "$LV_PATH" ]; then
    echo "  → Skipping LVM expansion: $LV_PATH does not exist"
    exit 0
fi

# Get free space in VG
FREE_SPACE=$(sudo vgs --noheadings -o vg_free --units g "$VG_NAME" 2>/dev/null | tr -d ' ')

# Check if there's free space
if [ "$FREE_SPACE" = "0g" ] || [ "$FREE_SPACE" = "0.00g" ] || [ -z "$FREE_SPACE" ]; then
    echo "  → Skipping LVM expansion: no free space in $VG_NAME"
    exit 0
fi

CURRENT_SIZE=$(sudo lvs --noheadings -o lv_size --units g "$LV_PATH" 2>/dev/null | tr -d ' ')

echo "  → Expanding $LV_PATH"
echo "    Current: $CURRENT_SIZE, Free: $FREE_SPACE"

# Extend LV
sudo lvextend -l +100%FREE "$LV_PATH"

# Detect filesystem type and resize
FS_TYPE=$(sudo blkid -o value -s TYPE "$LV_PATH")

echo "  → Resizing $FS_TYPE filesystem..."
case "$FS_TYPE" in
    ext4)
        sudo resize2fs "$LV_PATH"
        ;;
    xfs)
        sudo xfs_growfs "$LV_PATH"
        ;;
    btrfs)
        sudo btrfs filesystem resize max /
        ;;
    *)
        echo "  ⚠️  Unknown filesystem: $FS_TYPE (manual resize needed)"
        ;;
esac

NEW_SIZE=$(df -h "$LV_PATH" | tail -1 | awk '{print $2}')
echo "  ✓ Root expanded to $NEW_SIZE"
