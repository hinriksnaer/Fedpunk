#!/usr/bin/env fish
# Package manager abstraction for traditional and atomic Fedora

# Detect if running on atomic desktop
function is-atomic-desktop
    test -f /run/ostree-booted
end

# Install system packages (works on both traditional and atomic)
function install-system-packages
    set -l packages $argv

    if test (count $packages) -eq 0
        return 0
    end

    if is-atomic-desktop
        echo "  📦 Layering packages (rpm-ostree): $packages"
        sudo rpm-ostree install --idempotent --allow-inactive $packages

        if rpm-ostree status | grep -q "pending"
            set -g FEDPUNK_REBOOT_REQUIRED true
            echo "  ⚠️  Reboot required to activate changes"
        end
    else
        echo "  📦 Installing packages (dnf): $packages"
        sudo dnf install -y $packages
    end
end

# Show reboot warning at the end if needed
function show-reboot-warning
    if set -q FEDPUNK_REBOOT_REQUIRED
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "⚠️  REBOOT REQUIRED"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "System packages layered. Run: systemctl reboot"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    end
end
