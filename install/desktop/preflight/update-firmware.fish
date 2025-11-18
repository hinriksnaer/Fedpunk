#!/usr/bin/env fish
# Update system firmware using fwupd

# Source helper functions
source "$FEDPUNK_INSTALL/helpers/all.fish"

section "Firmware Updates"

# Skip if user doesn't want firmware updates
if not opt_in "Check for firmware updates?" "no"
    box "Firmware Updates Skipped" $GUM_WARNING
    exit 0
end

subsection "Checking firmware update availability"

# Check if fwupdmgr is available
if not command -v fwupdmgr >/dev/null 2>&1
    info "fwupd not available, installing..."
    gum spin --spinner meter --title "Installing fwupd..." -- fish -c '
        sudo dnf install -qy fwupd >>'"$FEDPUNK_LOG_FILE"' 2>&1
    ' && success "fwupd installed" || begin
        warning "Failed to install fwupd, skipping firmware updates"
        echo ""
        box "Firmware Updates Skipped" $GUM_WARNING
        exit 0
    end
end

info "Checking for firmware updates"

# Refresh firmware metadata
gum spin --spinner line --title "Refreshing firmware metadata..." -- fish -c '
    sudo fwupdmgr refresh --force >>'"$FEDPUNK_LOG_FILE"' 2>&1
' && success "Firmware metadata refreshed" || begin
    warning "Failed to refresh firmware metadata (may not be supported)"
    echo ""
    box "Firmware Updates Skipped" $GUM_WARNING
    exit 0
end

# Check if updates are available by trying to get updates
# fwupdmgr get-updates returns exit code 2 when no updates are available
set -l get_updates_output (fwupdmgr get-updates 2>&1)
set -l get_updates_status $status

if test $get_updates_status -eq 0
    # Updates are available
    info "Firmware updates available"
    echo "$get_updates_output" >> "$FEDPUNK_LOG_FILE"

    # Apply firmware updates
    gum spin --spinner meter --title "Applying firmware updates..." -- fish -c '
        sudo fwupdmgr update -y >>'"$FEDPUNK_LOG_FILE"' 2>&1
    ' && success "Firmware updates applied" || warning "Some firmware updates may have failed"

    info "A reboot may be required to complete firmware updates"
else
    success "All firmware is up to date"
end

echo ""
box "Firmware Updates Complete!" $GUM_SUCCESS
