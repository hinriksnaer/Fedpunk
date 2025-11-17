#!/usr/bin/env fish
# Setup Proton Pass password manager
# Downloads and installs the latest RPM from Proton's official site

set -l script_name (status basename)

# Colors for output
set -l green (tput setaf 2)
set -l yellow (tput setaf 3)
set -l red (tput setaf 1)
set -l reset (tput sgr0)

function info
    echo "$green✓$reset $argv"
end

function warn
    echo "$yellow⚠$reset $argv"
end

function error
    echo "$red✗$reset $argv"
end

echo ""
echo "Setting up Proton Pass password manager..."
echo ""

# Check if already installed
if command -v proton-pass >/dev/null 2>&1
    info "Proton Pass is already installed"
    proton-pass --version 2>/dev/null
    exit 0
end

# Download page URL
set download_url "https://proton.me/pass/download/linux"

info "Proton Pass needs to be downloaded from the official website"
echo ""
echo "Please follow these steps:"
echo "  1. Visit: $download_url"
echo "  2. Download the RPM package for Fedora"
echo "  3. Install with: sudo rpm -i ~/Downloads/ProtonPass_*.rpm"
echo ""
warn "After installation, sign in with your Proton Account"
echo ""

# Ask if user wants to open the download page
if command -v firefox >/dev/null 2>&1
    read -P "Open download page in Firefox? [y/N] " -l confirm
    if test "$confirm" = "y" -o "$confirm" = "Y"
        firefox "$download_url" &
        info "Opening download page in Firefox"
    end
end

echo ""
info "Once installed, you can launch Proton Pass from the app menu or with: proton-pass"
