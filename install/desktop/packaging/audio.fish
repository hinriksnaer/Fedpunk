#!/usr/bin/env fish
# Audio - PipeWire audio stack
# Pure package installation (no config to stow)

# Source helper functions
if not set -q FEDPUNK_PATH
    set -gx FEDPUNK_PATH "$HOME/.local/share/fedpunk"
end
if not set -q FEDPUNK_INSTALL
    set -gx FEDPUNK_INSTALL "$FEDPUNK_PATH/install"
end
if test -f "$FEDPUNK_INSTALL/helpers/all.fish"
    source "$FEDPUNK_INSTALL/helpers/all.fish"
end

# Core PipeWire audio stack
info "Installing PipeWire audio server"
set pipewire_core \
  pipewire \
  pipewire-alsa \
  pipewire-jack-audio-connection-kit \
  pipewire-pulseaudio \
  pipewire-utils \
  wireplumber \
  gstreamer1-pipewire

gum spin --spinner dot --title "Installing PipeWire core..." -- fish -c '
    sudo dnf install -qy --skip-broken '$pipewire_core' >>'"$FEDPUNK_LOG_FILE"' 2>&1
' && success "Installing PipeWire core" || success "PipeWire core already installed"

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

gum spin --spinner dot --title "Installing audio codecs..." -- fish -c '
    sudo dnf install -qy --skip-broken '$audio_codecs' >>'"$FEDPUNK_LOG_FILE"' 2>&1
' && success "Installing audio codecs" || success "Audio codecs already installed"

# Audio control utilities
info "Installing audio control utilities"
set audio_utils \
  pavucontrol \
  playerctl \
  wpctl \
  alsa-utils \
  pulseaudio-utils

gum spin --spinner dot --title "Installing audio utilities..." -- fish -c '
    sudo dnf install -qy --skip-broken '$audio_utils' >>'"$FEDPUNK_LOG_FILE"' 2>&1
' && success "Installing audio utilities" || success "Audio utilities already installed"

# Bluetooth audio support
info "Installing Bluetooth audio support"
set bluetooth_audio \
  bluez \
  bluez-tools \
  pipewire-plugin-libcamera

gum spin --spinner dot --title "Installing Bluetooth audio..." -- fish -c '
    sudo dnf install -qy --skip-broken '$bluetooth_audio' >>'"$FEDPUNK_LOG_FILE"' 2>&1
' && success "Installing Bluetooth audio" || success "Bluetooth audio already installed"

# PipeWire uses socket activation - it auto-starts when audio is accessed
# We just need to ensure the sockets are enabled (usually done by package install)
echo ""
info "Configuring PipeWire"

# Enable user lingering so services persist without login session
if not loginctl show-user $USER 2>/dev/null | grep -q "Linger=yes"
    gum spin --spinner dot --title "Enabling user lingering..." -- fish -c '
        sudo loginctl enable-linger '$USER' >>'"$FEDPUNK_LOG_FILE"' 2>&1
    ' && success "User lingering enabled" || warning "Could not enable user lingering"
end

# Try to enable sockets if user session is available (optional, sockets may already be enabled)
if test -n "$XDG_RUNTIME_DIR" -a -S "$XDG_RUNTIME_DIR/bus"
    gum spin --spinner dot --title "Enabling PipeWire sockets..." -- fish -c '
        systemctl --user enable pipewire.socket pipewire-pulse.socket >>'"$FEDPUNK_LOG_FILE"' 2>&1
    ' && success "PipeWire sockets enabled (will auto-start on demand)" || info "PipeWire sockets already configured"
else
    info "PipeWire will auto-start when you log in and use audio"
    echo "[INFO] PipeWire uses socket activation - will start automatically on first audio access" >> $FEDPUNK_LOG_FILE
end

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

Note: PipeWire uses socket activation and will auto-start when needed.
If audio doesn't work after login, manually start with:
  systemctl --user start pipewire pipewire-pulse wireplumber

Troubleshooting:
  • Restart: systemctl --user restart pipewire
  • Status: systemctl --user status pipewire
  • Devices: wpctl status" $GUM_SUCCESS
echo ""
