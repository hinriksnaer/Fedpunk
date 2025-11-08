#!/usr/bin/env fish

# Audio stack installation for Fedora
# Installs PipeWire, WirePlumber, codecs, and audio utilities

echo "🔊 Installing Audio Stack"
echo "========================="

# Get target directory (either /root or /home/USER)
set TARGET_DIR (test (id -u) -eq 0; and echo "/root"; or echo "/home/"(whoami))

cd (dirname (status -f))/../

# Core PipeWire audio stack
echo "→ Installing PipeWire audio server"
set pipewire_core \
  pipewire \
  pipewire-alsa \
  pipewire-jack-audio-connection-kit \
  pipewire-pulseaudio \
  pipewire-utils \
  wireplumber \
  gstreamer1-plugin-pipewire

sudo dnf install -qy $pipewire_core

# Audio codecs and plugins
echo "→ Installing audio codecs"
set audio_codecs \
  ffmpeg \
  gstreamer1-plugins-base \
  gstreamer1-plugins-good \
  gstreamer1-plugins-bad-free \
  gstreamer1-plugins-ugly-free \
  gstreamer1-libav \
  lame \
  opus

sudo dnf install -qy $audio_codecs

# Audio control utilities
echo "→ Installing audio control utilities"
set audio_utils \
  pavucontrol \
  playerctl \
  wpctl \
  alsa-utils \
  pulseaudio-utils

sudo dnf install -qy $audio_utils

# Bluetooth audio support
echo "→ Installing Bluetooth audio support"
set bluetooth_audio \
  bluez \
  bluez-tools \
  pipewire-plugin-libcamera

sudo dnf install -qy $bluetooth_audio

# Enable and start PipeWire services
echo "→ Enabling PipeWire services"

# Enable PipeWire for current user (systemd user services)
systemctl --user enable --now pipewire.service 2>/dev/null || true
systemctl --user enable --now pipewire-pulse.service 2>/dev/null || true
systemctl --user enable --now wireplumber.service 2>/dev/null || true

# Ensure Bluetooth is enabled if hardware is present
if command -v bluetoothctl >/dev/null 2>&1
    echo "→ Enabling Bluetooth service"
    sudo systemctl enable --now bluetooth.service 2>/dev/null || true
end

# Check PipeWire status
echo ""
echo "📊 Audio System Status:"
echo ""

if systemctl --user is-active --quiet pipewire.service
    echo "  ✅ PipeWire: running"
else
    echo "  ⚠️  PipeWire: not running (will start on next login)"
end

if systemctl --user is-active --quiet wireplumber.service
    echo "  ✅ WirePlumber: running"
else
    echo "  ⚠️  WirePlumber: not running (will start on next login)"
end

if systemctl --user is-active --quiet pipewire-pulse.service
    echo "  ✅ PulseAudio compatibility: enabled"
else
    echo "  ⚠️  PulseAudio compatibility: not running (will start on next login)"
end

if sudo systemctl is-active --quiet bluetooth.service
    echo "  ✅ Bluetooth: enabled"
else
    echo "  ℹ️  Bluetooth: not enabled (no hardware or disabled)"
end

echo ""
echo "✅ Audio stack installed!"
echo ""
echo "📦 What's installed:"
echo "  🎵 PipeWire - Modern audio server"
echo "  🔌 WirePlumber - PipeWire session manager"
echo "  🎛️  pavucontrol - Volume control GUI"
echo "  🎮 playerctl - Media player controls"
echo "  🔊 ALSA/PulseAudio - Legacy compatibility"
echo "  📻 Audio codecs - MP3, AAC, Opus, FLAC support"
echo "  🔵 Bluetooth audio - A2DP, HSP/HFP support"
echo ""
echo "💡 Audio controls:"
echo "   • GUI: pavucontrol"
echo "   • CLI: wpctl status"
echo "   • Hyprland: XF86Audio keys (volume/mute/play/pause)"
echo ""
echo "🔧 Troubleshooting:"
echo "   • Restart audio: systemctl --user restart pipewire pipewire-pulse wireplumber"
echo "   • Check status: systemctl --user status pipewire"
echo "   • List devices: wpctl status"
echo ""
