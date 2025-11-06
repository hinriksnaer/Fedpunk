#!/usr/bin/env fish

echo "🦊 Installing Firefox and web tools"

# Install Firefox and related packages
set packages \
  firefox \
  firefox-wayland \
  mozilla-ublock-origin \
  mozilla-https-everywhere

sudo dnf install -qy $packages

# Configure Firefox for Wayland
echo "→ Configuring Firefox for Wayland"
mkdir -p ~/.config/environment.d
echo "MOZ_ENABLE_WAYLAND=1" > ~/.config/environment.d/firefox.conf

# Create desktop portal configuration for Firefox
mkdir -p ~/.config/xdg-desktop-portal
cat > ~/.config/xdg-desktop-portal/portals.conf << 'EOF'
[preferred]
default=hyprland;gtk
org.freedesktop.impl.portal.FileChooser=hyprland;gtk
org.freedesktop.impl.portal.OpenURI=hyprland;gtk
org.freedesktop.impl.portal.Screenshot=hyprland
EOF

# Set Firefox as default browser
xdg-settings set default-web-browser firefox.desktop

# Configure Firefox policy for developer-friendly defaults
sudo mkdir -p /etc/firefox/policies
sudo tee /etc/firefox/policies/policies.json >/dev/null << 'EOF'
{
  "policies": {
    "DisableTelemetry": true,
    "DisableFirefoxStudies": true,
    "DisablePocket": true,
    "DisableFirefoxAccounts": false,
    "DisplayBookmarksToolbar": "newtab",
    "DNSOverHTTPS": {
      "Enabled": true,
      "ProviderURL": "https://mozilla.cloudflare-dns.com/dns-query"
    },
    "EnableTrackingProtection": {
      "Value": true,
      "Locked": false,
      "Cryptomining": true,
      "Fingerprinting": true
    },
    "ExtensionSettings": {
      "uBlock0@raymondhill.net": {
        "installation_mode": "force_installed",
        "install_url": "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi"
      }
    },
    "Homepage": {
      "URL": "about:home",
      "Locked": false
    },
    "NewTabPage": true,
    "NoDefaultBookmarks": false,
    "OfferToSaveLogins": true,
    "PasswordManagerEnabled": true,
    "PopupBlocking": {
      "Default": true
    },
    "Preferences": {
      "browser.newtabpage.activity-stream.showSponsoredTopSites": false,
      "browser.newtabpage.activity-stream.showSponsored": false,
      "toolkit.legacyUserProfileCustomizations.stylesheets": true,
      "media.ffmpeg.vaapi.enabled": true,
      "media.navigator.mediadatadecoder_vpx_enabled": true
    },
    "SearchBar": "unified",
    "SearchSuggestEnabled": true
  }
}
EOF

echo "✅ Firefox installation complete!"
echo ""
echo "🔧 Configured features:"
echo "  🌊 Wayland native mode enabled"
echo "  🛡️  uBlock Origin ad blocker"
echo "  🔒 Enhanced tracking protection"
echo "  🚫 Telemetry and studies disabled"
echo "  🏠 Set as default browser"
echo ""
echo "🚀 Firefox is ready for web development and daily use!"