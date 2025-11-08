#!/usr/bin/env fish
# Check and configure SELinux for Fedpunk

echo "→ Checking SELinux configuration"

# Check if SELinux is enabled
if command -v getenforce >/dev/null 2>&1
    set selinux_status (getenforce)
    echo "SELinux status: $selinux_status"

    if test "$selinux_status" = "Enforcing"
        echo "→ SELinux is enforcing. Setting up contexts for Fedpunk binaries..."

        # Set appropriate SELinux contexts for user binaries
        if test -d "$HOME/.local/share/fedpunk/bin"
            # Allow execution of user binaries
            sudo setsebool -P user_exec_content on 2>/dev/null; or true

            # Set proper context for user binaries
            if not chcon -R -t bin_t "$HOME/.local/share/fedpunk/bin" 2>/dev/null
                echo "⚠️  Warning: Could not set SELinux context for Fedpunk binaries."
                echo "   You may need to run: sudo setsebool -P user_exec_content on"
                echo "   Or set contexts manually: chcon -R -t bin_t ~/.local/share/fedpunk/bin"
            end
        end
    end
else
    echo "SELinux not found or not installed"
end
