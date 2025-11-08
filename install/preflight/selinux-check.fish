#!/usr/bin/env fish
# Check and configure SELinux for Fedpunk

# Source helper functions
source "$FEDPUNK_INSTALL/helpers/all.fish"

# Check if SELinux is enabled
if command -v getenforce >/dev/null 2>&1
    set selinux_status (getenforce)
    info "SELinux status: $selinux_status"

    if test "$selinux_status" = "Enforcing"
        # Set appropriate SELinux contexts for user binaries
        if test -d "$HOME/.local/share/fedpunk/bin"
            # Allow execution of user binaries
            run_quiet "Enabling user_exec_content" sudo setsebool -P user_exec_content on

            # Set proper context for user binaries
            if not chcon -R -t bin_t "$HOME/.local/share/fedpunk/bin" 2>>$FEDPUNK_LOG_FILE
                warning "Could not set SELinux context for Fedpunk binaries."
                info "You may need to run: sudo setsebool -P user_exec_content on"
            else
                success "SELinux contexts configured"
            end
        end
    end
else
    info "SELinux not found or not installed"
end
