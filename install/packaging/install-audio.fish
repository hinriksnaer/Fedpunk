#!/usr/bin/env fish

# Audio stack installation for Fedora
# Installs PipeWire, WirePlumber, codecs, and audio utilities

# Source helper functions
set -gx FEDPUNK_INSTALL "$HOME/.local/share/fedpunk/install"
if test -f "$FEDPUNK_INSTALL/helpers/all.fish"
    source "$FEDPUNK_INSTALL/helpers/all.fish"
end

# Get target directory (either /root or /home/USER)
set TARGET_DIR (test (id -u) -eq 0; and echo "/root"; or echo "/home/"(whoami))

cd (dirname (status -f))/../

# Core PipeWire audio stack
info "Installing PipeWire audio server"
set pipewire_core \
  pipewire \
  pipewire-alsa \
  pipewire-jack-audio-connection-kit \
  pipewire-pulseaudio \
  pipewire-utils \
  wireplumber \
  gstreamer1-plugin-pipewire

step "Installing PipeWire core" "sudo dnf install -qy $pipewire_core"

# Audio codecs and plugins
info "Installing audio codecs"
set audio_codecs \
  ffmpeg \
  gstreamer1-plugins-base \
  gstreamer1-plugins-good \
  gstreamer1-plugins-bad-free \
  gstreamer1-plugins-ugly-free \
  gstreamer1-libav \
  lame \
  opus

step "Installing audio codecs" "sudo dnf install -qy $audio_codecs"

# Audio control utilities
info "Installing audio control utilities"
set audio_utils \
  pavucontrol \
  playerctl \
  wpctl \
  alsa-utils \
  pulseaudio-utils

step "Installing audio utilities" "sudo dnf install -qy $audio_utils"

# Bluetooth audio support
info "Installing Bluetooth audio support"
set bluetooth_audio \
  bluez \
  bluez-tools \
  pipewire-plugin-libcamera

step "Installing Bluetooth audio" "sudo dnf install -qy $bluetooth_audio"

# Enable and start PipeWire services
echo ""
info "Enabling PipeWire services"

# Enable PipeWire for current user (systemd user services)
gum spin --spinner dot --title "Enabling PipeWire services..." -- fish -c '
    systemctl --user enable --now pipewire.service >>'"$FEDPUNK_LOG_FILE"' 2>&1; or true
    systemctl --user enable --now pipewire-pulse.service >>'"$FEDPUNK_LOG_FILE"' 2>&1; or true
    systemctl --user enable --now wireplumber.service >>'"$FEDPUNK_LOG_FILE"' 2>&1; or true
' && success "PipeWire services enabled"

# Ensure Bluetooth is enabled if hardware is present
if command -v bluetoothctl >/dev/null 2>&1
    gum spin --spinner dot --title "Enabling Bluetooth service..." -- fish -c '
        sudo systemctl enable --now bluetooth.service >>'"$FEDPUNK_LOG_FILE"' 2>&1
    ' && success "Bluetooth service enabled" || info "Bluetooth service already enabled or not available"
end

echo ""
box "Audio Stack Installed!

Installed components:
  🎵 PipeWire - Modern audio server
  🔌 WirePlumber - PipeWire session manager
  🎛️  pavucontrol - Volume control GUI
  🎮 playerctl - Media player controls
  🔊 ALSA/PulseAudio - Legacy compatibility
  📻 Audio codecs - MP3, AAC, Opus, FLAC support
  🔵 Bluetooth audio - A2DP, HSP/HFP support

Audio controls:
  • GUI: pavucontrol
  • CLI: wpctl status
  • Hyprland: XF86Audio keys

Troubleshooting:
  • Restart: systemctl --user restart pipewire
  • Status: systemctl --user status pipewire
  • Devices: wpctl status" $GUM_SUCCESS
echo ""
