#!/usr/bin/env fish

# Get target directory (either /root or /home/USER)
set TARGET_DIR (test (id -u) -eq 0; and echo "/root"; or echo "/home/"(whoami))

cd (dirname (status -f))/../

echo "→ Installing Walker launcher and Elephant service from copr"

# Enable copr repository
echo "→ Enabling copr repository: washkinazy/wayland-wm-extras"
sudo dnf copr enable -y washkinazy/wayland-wm-extras

# Install walker and elephant from copr
echo "→ Installing walker and elephant from copr"
sudo dnf install -qy walker elephant

# Verify installation
if not command -v walker >/dev/null 2>&1
    echo "❌ Walker installation failed"
    exit 1
end

if not command -v elephant >/dev/null 2>&1
    echo "❌ Elephant installation failed"
    exit 1
end

echo "✅ Walker installed: "(which walker)
echo "✅ Elephant installed: "(which elephant)

echo "→ Stowing Walker configuration"
stow -R walker

echo "→ Enabling and starting Elephant systemd service"
elephant service enable

# Ensure the service is started
systemctl --user start elephant

# Verify the service is running
if systemctl --user is-active --quiet elephant
    echo "✅ Elephant service is running"
else
    echo "⚠️  Elephant service failed to start, attempting restart..."
    systemctl --user restart elephant
    sleep 1
    if systemctl --user is-active --quiet elephant
        echo "✅ Elephant service is now running"
    else
        echo "❌ Failed to start Elephant service"
        echo "   Check status with: systemctl --user status elephant"
        exit 1
    end
end

echo ""
echo "✅ Walker and Elephant installation complete!"
echo ""
echo "🎉 Services configured:"
echo "  ✓ Elephant service enabled and started"
echo "  ✓ Elephant will auto-start on login"
echo ""
echo "🚀 Usage:"
echo "  - Launch Walker: walker"
echo "  - Or press Super+R in Hyprland"
echo ""
echo "📝 Configuration:"
echo "  - Walker config: ~/.config/walker/config.toml"
echo "  - Walker theme: ~/.config/walker/style.css"
echo ""
echo "🔧 Service management:"
echo "  - Check status: systemctl --user status elephant"
echo "  - Restart: systemctl --user restart elephant"
echo "  - Disable: elephant service disable"
