#!/usr/bin/env bash
set -euo pipefail

echo "→ Checking SELinux configuration"

# Check if SELinux is enabled
if command -v getenforce >/dev/null 2>&1; then
    selinux_status=$(getenforce)
    echo "SELinux status: $selinux_status"
    
    if [[ "$selinux_status" == "Enforcing" ]]; then
        echo "→ SELinux is enforcing. Setting up contexts for Fedpunk binaries..."
        
        # Set appropriate SELinux contexts for user binaries
        if [[ -d "$HOME/.local/share/fedpunk/bin" ]]; then
            # Allow execution of user binaries
            sudo setsebool -P user_exec_content on || true
            
            # Set proper context for user binaries
            chcon -R -t bin_t "$HOME/.local/share/fedpunk/bin" 2>/dev/null || {
                echo "⚠️  Warning: Could not set SELinux context for Fedpunk binaries."
                echo "   You may need to run: sudo setsebool -P user_exec_content on"
                echo "   Or set contexts manually: chcon -R -t bin_t ~/.local/share/fedpunk/bin"
            }
        fi
    fi
else
    echo "SELinux not found or not installed"
fi