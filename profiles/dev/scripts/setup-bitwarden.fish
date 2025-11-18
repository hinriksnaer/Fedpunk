#!/usr/bin/env fish
# Setup Bitwarden password manager (GUI + CLI)
# Installs both the desktop app via Flatpak and the CLI tool

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
echo "Setting up Bitwarden password manager..."
echo ""

# Check if CLI already installed
set cli_installed false
if command -v bw >/dev/null 2>&1
    info "Bitwarden CLI already installed"
    bw --version
    set cli_installed true
end

# Check if GUI already installed
set gui_installed false
if flatpak list --app 2>/dev/null | grep -q "com.bitwarden.desktop"
    info "Bitwarden desktop app already installed (Flatpak)"
    set gui_installed true
end

if test "$cli_installed" = true -a "$gui_installed" = true
    info "Both Bitwarden CLI and GUI are already installed"
    exit 0
end

# Install Flatpak if not available
if not command -v flatpak >/dev/null 2>&1
    info "Installing Flatpak..."
    sudo dnf install -qy flatpak
    if test $status -ne 0
        error "Failed to install Flatpak"
        exit 1
    end
    info "Flatpak installed successfully"
end

# Add Flathub repository if not already added
if not flatpak remotes 2>/dev/null | grep -q flathub
    info "Adding Flathub repository..."
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    if test $status -ne 0
        error "Failed to add Flathub repository"
        exit 1
    end
    info "Flathub repository added"
else
    info "Flathub repository already configured"
end

# Install Bitwarden desktop app from Flathub
if test "$gui_installed" = false
    info "Installing Bitwarden desktop app from Flathub..."
    echo ""
    flatpak install -y flathub com.bitwarden.desktop

    if test $status -eq 0
        info "Bitwarden desktop app installed successfully!"
        set gui_installed true
    else
        error "Failed to install Bitwarden desktop app"
    end
end

# Install Bitwarden CLI
if test "$cli_installed" = false
    echo ""
    info "Installing Bitwarden CLI..."

    # Install via npm (most reliable method)
    if command -v npm >/dev/null 2>&1
        sudo npm install -g @bitwarden/cli
        if test $status -eq 0
            info "Bitwarden CLI installed successfully!"
            set cli_installed true
        else
            warn "Failed to install via npm, trying alternative method..."
        end
    else
        info "npm not found, installing Node.js first..."
        sudo dnf install -qy nodejs npm
        if test $status -eq 0
            sudo npm install -g @bitwarden/cli
            if test $status -eq 0
                info "Bitwarden CLI installed successfully!"
                set cli_installed true
            end
        end
    end

    # Fallback: download binary directly
    if test "$cli_installed" = false
        info "Installing Bitwarden CLI from binary..."
        set BW_VERSION (curl -s https://api.github.com/repos/bitwarden/cli/releases/latest | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/')
        set BW_URL "https://github.com/bitwarden/clients/releases/download/cli-v$BW_VERSION/bw-linux-$BW_VERSION.zip"

        mkdir -p ~/.local/bin
        cd /tmp
        curl -fL "$BW_URL" -o bw.zip
        unzip -o bw.zip
        chmod +x bw
        mv bw ~/.local/bin/
        rm bw.zip

        if command -v bw >/dev/null 2>&1
            info "Bitwarden CLI installed successfully!"
            set cli_installed true
        else
            error "Failed to install Bitwarden CLI"
        end
    end
end

# Helper function to save session key
function save_session_key
    set session_key $argv[1]
    echo ""
    gum style --foreground 212 "  set -Ux BW_SESSION \"$session_key\""
    echo ""
    if gum confirm "Save BW_SESSION for this user?"
        set -Ux BW_SESSION "$session_key"
        info "BW_SESSION saved! CLI is ready to use."
        return 0
    end
    return 1
end

# Helper function to perform login
function do_bw_login
    set email (gum input --placeholder "Enter your Bitwarden email")
    test -z "$email"; and return 1

    echo ""
    info "Logging in as $email..."
    bw login "$email"; or return 1

    info "Login successful! Unlocking vault..."
    set session_key (bw unlock --raw)
    test -n "$session_key"; and save_session_key "$session_key"
end

# Helper function to unlock vault
function do_bw_unlock
    info "Unlocking vault..."
    set session_key (bw unlock --raw)
    test -n "$session_key"; and save_session_key "$session_key"
end

echo ""
if test "$gui_installed" = false -o "$cli_installed" = false
    warn "Bitwarden installation incomplete"
    test "$gui_installed" = false; and echo "  • Desktop app: Not installed"
    test "$cli_installed" = false; and echo "  • CLI: Not installed"
    exit 1
end

info "Bitwarden setup complete!"
echo ""
echo "GUI App: Search for 'Bitwarden' in app menu"
echo ""

# Interactive CLI setup (skip in non-interactive mode)
if set -q FEDPUNK_NON_INTERACTIVE
    info "Run 'bw login' to set up CLI in interactive mode"
    exit 0
end

gum confirm "Set up Bitwarden CLI now?"; or exit 0

echo ""
info "Setting up Bitwarden CLI..."

# Get current status
set bw_status (bw status 2>/dev/null | grep -o '"status":"[^"]*"' | cut -d'"' -f4)

# Handle each status
switch $bw_status
    case "unauthenticated"
        do_bw_login
    case "locked"
        do_bw_unlock
    case "unlocked"
        info "CLI is already unlocked and ready!"
    case "*"
        warn "Unknown status. Run: bw login"
end

echo ""
info "CLI Quick Reference:"
echo "  bwg <name>  - Get password"
echo "  bwl         - List items"
echo "  bwgen       - Generate password"
echo "  bws         - Sync vault"
