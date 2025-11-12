#!/usr/bin/env fish
# System optimizations for better performance and boot times

# Source helper functions
source "$FEDPUNK_INSTALL/helpers/all.fish"

section "System Optimizations"

# Disable NetworkManager-wait-online service (saves 15-20s boot time)
info "Disabling NetworkManager-wait-online service"
info "This can save 15-20 seconds on boot time"

if systemctl is-enabled NetworkManager-wait-online.service >/dev/null 2>&1
    gum spin --spinner dot --title "Disabling NetworkManager-wait-online..." -- fish -c '
        sudo systemctl disable NetworkManager-wait-online.service >>'"$FEDPUNK_LOG_FILE"' 2>&1
    ' && success "NetworkManager-wait-online disabled" || warning "Failed to disable NetworkManager-wait-online"
else
    success "NetworkManager-wait-online already disabled"
end

# Remove GNOME Software autostart (if present)
echo ""
info "Checking for GNOME Software autostart"

set gnome_software_autostart "/etc/xdg/autostart/org.gnome.Software.desktop"

if test -f "$gnome_software_autostart"
    info "GNOME Software autostart found, removing to reduce background activity"
    gum spin --spinner dot --title "Removing GNOME Software autostart..." -- fish -c '
        sudo rm -f '"$gnome_software_autostart"' >>'"$FEDPUNK_LOG_FILE"' 2>&1
    ' && success "GNOME Software autostart removed" || warning "Failed to remove GNOME Software autostart"
else
    info "GNOME Software autostart not present (already optimized)"
end

# Optional: Set up systemd-resolved for better DNS performance
echo ""
info "Checking DNS configuration"

if systemctl is-active systemd-resolved >/dev/null 2>&1
    success "systemd-resolved is active"
    info "You can configure custom DNS servers in /etc/systemd/resolved.conf"
else
    info "systemd-resolved not active, using default NetworkManager DNS"
end

echo ""
box "System Optimizations Complete!" $GUM_SUCCESS
