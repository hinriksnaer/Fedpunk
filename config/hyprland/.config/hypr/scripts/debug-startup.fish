#!/usr/bin/env fish

# Hyprland Startup Debug Script
# Run this if Hyprland shows a black screen or fails to start properly

echo "🔍 Hyprland Startup Diagnostics"
echo "================================"

# Check if Hyprland is running
echo -n "Hyprland process: "
if pgrep -x hyprland >/dev/null
    echo "✓ Running"
else
    echo "❌ Not running"
end

# Check graphics drivers
echo -n "Graphics driver: "
if lspci | grep -i nvidia >/dev/null
    echo "NVIDIA detected"
    if lsmod | grep -q nvidia
        echo "  ✓ NVIDIA kernel modules loaded"
    else
        echo "  ❌ NVIDIA kernel modules not loaded"
    end
else
    echo "Non-NVIDIA (Intel/AMD)"
    if lsmod | grep -E "(i915|amdgpu|radeon)" >/dev/null
        echo "  ✓ Graphics modules loaded"
    else
        echo "  ⚠️  No known graphics modules detected"
    end
end

# Check Wayland environment
echo -n "Wayland environment: "
if set -q WAYLAND_DISPLAY
    echo "✓ WAYLAND_DISPLAY=$WAYLAND_DISPLAY"
else
    echo "❌ WAYLAND_DISPLAY not set"
end

# Check display outputs
echo "Display outputs:"
if command -v wlr-randr >/dev/null
    wlr-randr | head -10
else if command -v hyprctl >/dev/null
    hyprctl monitors 2>/dev/null | head -10 || echo "  ❌ hyprctl not responding"
else
    echo "  ⚠️  No display tools available (wlr-randr, hyprctl)"
end

# Check essential processes
echo "Essential processes:"
set processes mako hyprpolkitagent swaybg nm-applet
for proc in $processes
    echo -n "  $proc: "
    if pgrep -x $proc >/dev/null
        echo "✓"
    else
        echo "❌"
    end
end

# Check config files
echo "Config files:"
set configs \
    ~/.config/hypr/hyprland.conf \
    ~/.config/hypr/conf.d/monitors.conf \
    ~/.config/hypr/conf.d/autostart.conf
    
for config in $configs
    echo -n "  $(basename $config): "
    if test -f $config
        echo "✓"
    else
        echo "❌ Missing"
    end
end

# Check wallpaper
echo -n "Wallpaper status: "
if pgrep -x swaybg >/dev/null
    echo "✓ swaybg running"
    if test -f ~/.config/hypr/wallpapers/current
        echo "  ✓ Current wallpaper exists"
    else
        echo "  ⚠️  Current wallpaper missing"
    end
else
    echo "❌ swaybg not running"
end

# Check recent logs
echo ""
echo "Recent Hyprland logs (last 20 lines):"
if test -f ~/.local/share/hyprland/hyprland.log
    tail -20 ~/.local/share/hyprland/hyprland.log
else
    echo "  ❌ No log file found at ~/.local/share/hyprland/hyprland.log"
    echo "  Try: journalctl --user -u hyprland.service -n 20"
end

echo ""
echo "💡 Troubleshooting tips:"
echo "  • Press Super+Shift+Return for emergency terminal"
echo "  • Try: hyprctl reload"
echo "  • Check: journalctl --user -u hyprland.service"
echo "  • Restart: hyprctl dispatch exit"