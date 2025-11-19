#!/usr/bin/env fish
# ============================================================================
# DESKTOP OPTIMIZE: System optimizations for desktop
# ============================================================================
# Purpose:
#   - Disable NetworkManager-wait-online (saves 15-20s boot time)
#   - Remove GNOME Software autostart
# Runs: Only for desktop/laptop modes
# ============================================================================

# Skip if container mode
if test "$FEDPUNK_MODE" = "container"
    info "Skipping desktop optimizations (container mode)"
    exit 0
end

source "$FEDPUNK_PATH/lib/helpers.fish"

section "Desktop Optimizations"

# Disable NetworkManager-wait-online
subsection "Disabling NetworkManager-wait-online service"
if systemctl is-enabled NetworkManager-wait-online.service >/dev/null 2>&1
    step "Disabling NetworkManager-wait-online" "sudo systemctl disable NetworkManager-wait-online.service"
    info "This saves 15-20 seconds on boot"
else
    success "NetworkManager-wait-online already disabled"
end

# Remove GNOME Software autostart
echo ""
subsection "Removing GNOME Software autostart"
set gnome_software_autostart "/etc/xdg/autostart/org.gnome.Software.desktop"

if test -f "$gnome_software_autostart"
    step "Removing GNOME Software autostart" "sudo rm -f $gnome_software_autostart"
else
    success "GNOME Software autostart not present"
end

echo ""
box "Desktop Optimizations Complete!" $GUM_SUCCESS
