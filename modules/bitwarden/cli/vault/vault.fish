# Bitwarden vault management commands

function vault --description "Bitwarden vault management"
    if contains -- "$argv[1]" --help -h
        printf "Bitwarden vault management\n"
        printf "\n"
        printf "Securely manage passwords, SSH keys, and tokens.\n"
        return 0
    end
    _show_command_help vault
end

# Ensure Bitwarden CLI is available
function _require_bw
    if not command -v bw >/dev/null 2>&1
        printf "Error: Bitwarden CLI not installed\n" >&2
        printf "Install with: sudo dnf install bw\n" >&2
        return 1
    end
    return 0
end

# Check if vault is unlocked
function _require_unlocked
    _require_bw; or return 1

    set -l bw_status (bw status 2>/dev/null | grep -o '"status":"[^"]*"' | cut -d'"' -f4)
    if test "$bw_status" != "unlocked"
        printf "Error: Bitwarden vault is locked\n" >&2
        printf "Run: fedpunk vault unlock\n" >&2
        return 1
    end
    return 0
end

function state --description "Show vault status"
    if contains -- "$argv[1]" --help -h
        printf "Show current Bitwarden vault status\n"
        printf "\n"
        printf "Usage: fedpunk vault state\n"
        return 0
    end

    _require_bw; or return 1
    bw status | fish -c 'read -z input; echo $input | jq .'
end

function login --description "Login to Bitwarden"
    if contains -- "$argv[1]" --help -h
        printf "Login to Bitwarden account\n"
        printf "\n"
        printf "Usage: fedpunk vault login\n"
        return 0
    end

    _require_bw; or return 1
    bwlogin
end

function unlock --description "Unlock the vault"
    if contains -- "$argv[1]" --help -h
        printf "Unlock the Bitwarden vault\n"
        printf "\n"
        printf "Usage: fedpunk vault unlock\n"
        return 0
    end

    _require_bw; or return 1
    bwunlock
end

function lock --description "Lock the vault"
    if contains -- "$argv[1]" --help -h
        printf "Lock the Bitwarden vault\n"
        printf "\n"
        printf "Usage: fedpunk vault lock\n"
        return 0
    end

    _require_bw; or return 1
    bw lock
end

function sync --description "Sync vault with server"
    if contains -- "$argv[1]" --help -h
        printf "Sync local vault cache with Bitwarden server\n"
        printf "\n"
        printf "Usage: fedpunk vault sync\n"
        return 0
    end

    _require_bw; or return 1
    if not bw sync
        printf "Error: Failed to sync vault\n" >&2
        return 1
    end
    printf "✓ Vault synced successfully\n"
end

function get --description "Get password for item"
    if contains -- "$argv[1]" --help -h
        printf "Get password for a vault item\n"
        printf "\n"
        printf "Usage: fedpunk vault get <name>\n"
        printf "\n"
        printf "Copies password to clipboard.\n"
        return 0
    end

    set -l item_name $argv[1]
    if test -z "$item_name"
        printf "Error: Item name required\n" >&2
        printf "Usage: fedpunk vault get <name>\n" >&2
        return 1
    end

    _require_unlocked; or return 1
    bw-get $item_name
end

function env --description "Load environment variables from item"
    if contains -- "$argv[1]" --help -h
        printf "Load environment variables from a vault item's notes\n"
        printf "\n"
        printf "Usage: fedpunk vault env <name>\n"
        return 0
    end

    set -l item_name $argv[1]
    if test -z "$item_name"
        printf "Error: Item name required\n" >&2
        printf "Usage: fedpunk vault env <name>\n" >&2
        return 1
    end

    _require_unlocked; or return 1
    bw-env $item_name
end

function ssh-load --description "Load SSH keys into agent"
    if contains -- "$argv[1]" --help -h
        printf "Load SSH keys from Bitwarden into ssh-agent\n"
        printf "\n"
        printf "Usage: fedpunk vault ssh-load\n"
        return 0
    end

    _require_unlocked; or return 1
    bw-ssh-load
end

function claude-backup --description "Backup Claude Code token"
    if contains -- "$argv[1]" --help -h
        printf "Generate and backup Claude Code long-lived token\n"
        printf "\n"
        printf "Usage: fedpunk vault claude-backup [name]\n"
        printf "\n"
        printf "Creates a long-lived token that won't expire like OAuth tokens.\n"
        printf "Optional name allows multiple backups (e.g., work, home).\n"
        return 0
    end

    _require_unlocked; or return 1

    if not command -v claude >/dev/null 2>&1
        printf "Error: Claude Code not installed\n" >&2
        printf "Install first: npm install -g @anthropic-ai/claude-code\n" >&2
        return 1
    end

    # Get backup name
    set -l backup_name $argv[1]
    if test -n "$backup_name"
        set -l item_name "Claude Code Token - $backup_name"
    else
        set -l item_name "Claude Code Token"
    end

    printf "🔒 Backing up Claude Code token to Bitwarden...\n"
    printf "\n"
    printf "This will generate a long-lived token using 'claude setup-token'\n"
    printf "\n"
    printf "Backup name: %s\n" "$item_name"
    printf "\n"

    printf "→ Generating long-lived token...\n"
    printf "  (This will open a browser window for authentication)\n"
    printf "\n"

    set -l token_output (claude setup-token 2>&1)
    set -l claude_token (echo "$token_output" | grep -o 'sk-ant-[a-zA-Z0-9_-]*' | head -1)

    if test -z "$claude_token"
        printf "Error: Failed to generate token\n" >&2
        printf "Output: %s\n" "$token_output" >&2
        return 1
    end

    # Setup metadata
    set -l backup_hostname (hostname)
    set -l timestamp (date -u +"%Y-%m-%dT%H:%M:%SZ")

    # Check if item exists
    set -l existing_item (bw get item "$item_name" 2>/dev/null)

    if test -n "$existing_item"
        printf "→ Updating existing backup...\n"
        set -l item_id (echo "$existing_item" | jq -r '.id')
        echo "$existing_item" | jq --arg token "$claude_token" --arg notes "Claude Code Long-Lived Token
Hostname: $backup_hostname
Timestamp: $timestamp

Set as environment variable:
export CLAUDE_CODE_OAUTH_TOKEN='\$token'" '.login.password = $token | .notes = $notes' | bw encode | bw edit item "$item_id" >/dev/null 2>&1
        set -l bw_status $status
    else
        printf "→ Creating new backup item...\n"
        jq -n --arg name "$item_name" --arg token "$claude_token" --arg notes "Claude Code Long-Lived Token
Hostname: $backup_hostname
Timestamp: $timestamp

Set as environment variable:
export CLAUDE_CODE_OAUTH_TOKEN='\$token'" '{
  organizationId: null,
  folderId: null,
  type: 1,
  name: $name,
  notes: $notes,
  favorite: false,
  login: {
    username: "claude-code",
    password: $token
  }
}' | bw encode | bw create item >/dev/null 2>&1
        set -l bw_status $status
    end

    if test $bw_status -eq 0
        printf "\n"
        printf "✓ Claude Code token backed up successfully\n"
        printf "  Item: %s\n" "$item_name"
        printf "  Hostname: %s\n" "$backup_hostname"
        printf "\n"
        printf "💡 Run 'fedpunk vault sync' to sync with server\n"
    else
        printf "Error: Failed to create/update backup in Bitwarden\n" >&2
        return 1
    end
end

function claude-restore --description "Restore Claude Code token"
    if contains -- "$argv[1]" --help -h
        printf "Restore Claude Code token from Bitwarden\n"
        printf "\n"
        printf "Usage: fedpunk vault claude-restore [name]\n"
        printf "\n"
        printf "Sets CLAUDE_CODE_OAUTH_TOKEN environment variable.\n"
        printf "No browser login needed after restore!\n"
        return 0
    end

    _require_unlocked; or return 1

    printf "🔓 Restoring Claude Code token from Bitwarden...\n"
    printf "\n"

    printf "→ Syncing vault...\n"
    bw sync >/dev/null 2>&1; or printf "⚠️  Warning: Failed to sync vault\n"
    printf "\n"

    # Get backup name
    set -l backup_name $argv[1]
    set -l item_name

    if test -n "$backup_name"
        set item_name "Claude Code Token - $backup_name"
    else
        # List available backups
        set -l available (bw list items --search "Claude Code Token" 2>/dev/null | jq -r '.[] | select(.type == 1) | .name')

        if test -z "$available"
            printf "Error: No Claude Code token backups found\n" >&2
            printf "Run 'fedpunk vault claude-backup' first\n" >&2
            return 1
        end

        set -l backup_count (echo "$available" | wc -l)
        if test $backup_count -eq 1
            set item_name (echo "$available" | head -1)
            printf "Found backup: %s\n" "$item_name"
        else
            # Use smart selector
            set -l options (echo "$available" | string split \n)
            set item_name (ui-select-smart \
                --header "Select backup to restore:" \
                --options $options)
            or return 1
        end
    end

    printf "Restoring: %s\n" "$item_name"
    printf "\n"

    set -l claude_token (bw get password "$item_name" 2>/dev/null)

    if test -z "$claude_token"
        printf "Error: Could not retrieve token from: %s\n" "$item_name" >&2
        return 1
    end

    # Add to fish config
    set -l fish_config "$HOME/.config/fish/conf.d/claude-token.fish"
    printf "→ Setting up environment variable...\n"

    mkdir -p "$HOME/.config/fish/conf.d"
    echo "# Claude Code OAuth Token (restored from Bitwarden)" > "$fish_config"
    echo "set -gx CLAUDE_CODE_OAUTH_TOKEN '$claude_token'" >> "$fish_config"

    # Set for current session
    set -gx CLAUDE_CODE_OAUTH_TOKEN "$claude_token"

    printf "\n"
    printf "✓ Claude Code token restored successfully\n"
    printf "\n"
    printf "Environment variable set: \$CLAUDE_CODE_OAUTH_TOKEN\n"
    printf "Config file: %s\n" "$fish_config"
    printf "\n"
    printf "🎉 You can now use Claude Code without logging in!\n"
end
