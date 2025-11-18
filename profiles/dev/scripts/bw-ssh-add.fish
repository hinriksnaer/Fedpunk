#!/usr/bin/env fish
# Add SSH key to Bitwarden
# This script helps you store SSH keys in Bitwarden for secure access

set -l script_name (status basename)

# Colors for output
set -l green (tput setaf 2)
set -l yellow (tput setaf 3)
set -l red (tput setaf 1)
set -l blue (tput setaf 4)
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

function notice
    echo "$blue→$reset $argv"
end

# Check if bw is installed
if not command -v bw >/dev/null 2>&1
    error "Bitwarden CLI not found. Please run setup-bitwarden.fish first."
    exit 1
end

# Check if logged in and unlocked
set bw_status (bw status 2>/dev/null | grep -o '"status":"[^"]*"' | cut -d'"' -f4)

if test "$bw_status" != "unlocked"
    error "Bitwarden vault is not unlocked."
    echo ""
    echo "Please run one of the following:"
    echo "  bwlogin  - to login and unlock"
    echo "  bwunlock - to unlock your vault"
    exit 1
end

echo ""
echo "SSH Key → Bitwarden"
echo "==================="
echo ""

# Get SSH key path
if test (count $argv) -gt 0
    set ssh_key_path $argv[1]
else
    set ssh_key_path ~/.ssh/id_ed25519
end

# Check if key exists
if not test -f "$ssh_key_path"
    error "SSH key not found: $ssh_key_path"
    exit 1
end

if not test -f "$ssh_key_path.pub"
    error "SSH public key not found: $ssh_key_path.pub"
    exit 1
end

notice "Found SSH key: $ssh_key_path"

# Read the keys
set private_key (cat "$ssh_key_path")
set public_key (cat "$ssh_key_path.pub")

# Get key name
set key_name (basename "$ssh_key_path")
echo ""
set item_name (gum input --placeholder "Name for this SSH key in Bitwarden" --value "SSH Key - $key_name")

if test -z "$item_name"
    error "No name provided. Aborting."
    exit 1
end

# Check if item already exists
set existing_item (bw list items --search "$item_name" 2>/dev/null | jq -r '.[0].id // empty')

if test -n "$existing_item"
    warn "An item with name '$item_name' already exists."
    if not gum confirm "Overwrite existing item?"
        echo "Aborted."
        exit 0
    end
end

# Create JSON for secure note with SSH keys
set json_data (jq -n \
    --arg name "$item_name" \
    --arg private_key "$private_key" \
    --arg public_key "$public_key" \
    '{
        type: 2,
        name: $name,
        notes: ("SSH Private Key:\n\n\($private_key)\n\nSSH Public Key:\n\n\($public_key)"),
        secureNote: {
            type: 0
        }
    }')

# Create or update item
if test -n "$existing_item"
    notice "Updating existing item..."
    echo "$json_data" | bw encode | bw edit item "$existing_item" >/dev/null
else
    notice "Creating new item..."
    echo "$json_data" | bw encode | bw create item >/dev/null
end

if test $status -eq 0
    info "SSH key successfully saved to Bitwarden!"
    echo ""
    echo "Item name: $item_name"
    echo "To retrieve: Use bw-ssh-load function"
else
    error "Failed to save SSH key to Bitwarden"
    exit 1
end

# Sync
if gum confirm "Sync vault now?"
    bw sync >/dev/null
    info "Vault synced"
end
