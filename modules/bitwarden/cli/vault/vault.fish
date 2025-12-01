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

function ssh-backup --description "Backup SSH keys to vault"
    if contains -- "$argv[1]" --help -h
        printf "Backup SSH keys to Bitwarden vault\n"
        printf "\n"
        printf "Usage: fedpunk vault ssh-backup [name]\n"
        printf "\n"
        printf "Arguments:\n"
        printf "  name    Backup name (default: hostname)\n"
        printf "\n"
        printf "Examples:\n"
        printf "  fedpunk vault ssh-backup             # Use hostname as name\n"
        printf "  fedpunk vault ssh-backup work-laptop # Named backup\n"
        return 0
    end

    _require_unlocked; or return 1

    set -l SSH_DIR "$HOME/.ssh"
    set -l backup_name $argv[1]

    if test -z "$backup_name"
        set backup_name (hostname)
    end

    # Check SSH directory exists
    if not test -d "$SSH_DIR"
        printf "Error: No ~/.ssh directory found\n" >&2
        return 1
    end

    # Find SSH key files
    set -l key_files (find "$SSH_DIR" -maxdepth 1 -type f -name "id_*" ! -name "*.pub" 2>/dev/null)

    if test -z "$key_files"
        printf "Error: No SSH keys found in %s\n" "$SSH_DIR" >&2
        return 1
    end

    printf "SSH Key Backup\n"
    printf "\n"
    printf "Backup name: %s\n" "$backup_name"
    printf "Found SSH keys:\n"
    for key in $key_files
        printf "  - %s\n" (basename $key)
    end

    # Show additional files being backed up
    set -l extra_files
    if test -f "$SSH_DIR/config.d/hosts"
        set -a extra_files "config.d/hosts"
    end
    if test (count $extra_files) -gt 0
        printf "\nAdditional files:\n"
        for f in $extra_files
            printf "  - %s\n" $f
        end
    end
    printf "\n"

    # Build list of files to backup
    set -l files_to_backup
    for k in $key_files
        set -a files_to_backup (basename $k)
        if test -f "$k.pub"
            set -a files_to_backup (basename $k).pub
        end
    end

    # Include config if exists (but this is usually managed by SSH module)
    if test -f "$SSH_DIR/config"
        set -a files_to_backup config
    end

    # Include user's personal hosts configuration
    if test -f "$SSH_DIR/config.d/hosts"
        set -a files_to_backup config.d/hosts
    end

    # Create tarball
    set -l temp_tar (mktemp --suffix=.tar.gz)
    tar -czf "$temp_tar" -C "$SSH_DIR" $files_to_backup 2>/dev/null

    if test $status -ne 0
        rm -f "$temp_tar"
        printf "Error: Failed to create archive\n" >&2
        return 1
    end

    # Get passphrase for encryption
    set -l passphrase
    if test -t 0  # Check if stdin is a terminal
        if command -v gum >/dev/null 2>&1
            set passphrase (gum input --password --placeholder "Enter passphrase to encrypt backup")
        else
            printf "Enter passphrase to encrypt backup: "
            read -s passphrase
            printf "\n"
        end
    else
        # Non-interactive: read from stdin
        read passphrase
    end

    if test -z "$passphrase"
        rm -f "$temp_tar"
        printf "Error: Passphrase cannot be empty\n" >&2
        return 1
    end

    # Encrypt with GPG
    set -l encrypted_file (mktemp --suffix=.tar.gz.gpg)
    printf "Encrypting backup...\n"
    echo "$passphrase" | gpg --batch --yes --passphrase-fd 0 --symmetric --cipher-algo AES256 --output "$encrypted_file" "$temp_tar" 2>/dev/null
    set -l gpg_status $status
    rm -f "$temp_tar"

    if test $gpg_status -ne 0
        rm -f "$encrypted_file"
        printf "Error: Failed to encrypt backup\n" >&2
        return 1
    end

    # Base64 encode for storage
    set -l encoded_backup (base64 -w 0 "$encrypted_file")
    rm -f "$encrypted_file"

    set -l hostname_str (hostname)
    set -l timestamp (date -u +"%Y-%m-%dT%H:%M:%SZ")
    set -l item_name "SSH Backup - $backup_name"

    printf "Backing up to Bitwarden vault...\n"

    # Prepare note content
    set -l note_content "SSH Key Backup
Name: $backup_name
Hostname: $hostname_str
Timestamp: $timestamp
Format: tar.gz.gpg (base64 encoded)

--- BEGIN SSH BACKUP ---
$encoded_backup
--- END SSH BACKUP ---"

    # Check if item exists
    set -l existing_item (bw get item "$item_name" 2>/dev/null)
    set -l bw_result 1

    if test -n "$existing_item"
        # Update existing item
        printf "Updating existing backup...\n"
        set -l item_id (echo "$existing_item" | jq -r '.id')
        echo "$existing_item" | jq --arg notes "$note_content" '.notes = $notes' | bw encode | bw edit item "$item_id" >/dev/null 2>&1
        set bw_result $status
    else
        # Create new secure note
        printf "Creating new backup...\n"
        jq -n --arg name "$item_name" --arg notes "$note_content" '{
            organizationId: null,
            folderId: null,
            type: 2,
            name: $name,
            notes: $notes,
            favorite: false,
            secureNote: { type: 0 }
        }' | bw encode | bw create item >/dev/null 2>&1
        set bw_result $status
    end

    if test $bw_result -eq 0
        printf "\n"
        printf "✓ SSH keys backed up to Bitwarden\n"
        printf "  Item: %s\n" "$item_name"
        printf "\n"
        printf "Run 'fedpunk vault sync' to sync with server\n"
    else
        printf "Error: Failed to save backup to Bitwarden\n" >&2
        return 1
    end
end

function ssh-restore --description "Restore SSH keys from vault"
    if contains -- "$argv[1]" --help -h
        printf "Restore SSH keys from Bitwarden vault\n"
        printf "\n"
        printf "Usage: fedpunk vault ssh-restore [--force] [name]\n"
        printf "\n"
        printf "Options:\n"
        printf "  --force  Overwrite existing SSH directory without confirmation\n"
        printf "\n"
        printf "Arguments:\n"
        printf "  name    Backup name (interactive if not provided)\n"
        printf "\n"
        printf "Examples:\n"
        printf "  fedpunk vault ssh-restore             # Interactive selection\n"
        printf "  fedpunk vault ssh-restore work-laptop # Restore specific backup\n"
        printf "  fedpunk vault ssh-restore --force my-backup  # Force overwrite\n"
        return 0
    end

    _require_unlocked; or return 1

    # Parse --force flag
    set -l force_overwrite false
    set -l remaining_args
    for arg in $argv
        if test "$arg" = "--force"
            set force_overwrite true
        else
            set -a remaining_args $arg
        end
    end

    set -l SSH_DIR "$HOME/.ssh"
    set -l backup_name $remaining_args[1]

    # Sync vault
    printf "Syncing vault...\n"
    bw sync >/dev/null 2>&1

    # List available backups
    set -l available_backups (bw list items --search "SSH Backup" 2>/dev/null | jq -r '.[] | select(.type == 2) | .name' | sed 's/SSH Backup - //')

    if test -z "$available_backups"
        printf "Error: No SSH backups found in Bitwarden\n" >&2
        printf "Run 'fedpunk vault ssh-backup' to create a backup first\n" >&2
        return 1
    end

    # Select backup
    if test -z "$backup_name"
        set -l backup_list (string split \n $available_backups)
        if test (count $backup_list) -eq 1
            set backup_name $backup_list[1]
            printf "Found backup: %s\n" "$backup_name"
        else
            set backup_name (ui-select-smart \
                --header "Select backup to restore:" \
                --options $backup_list)
            or return 1
        end
    end

    printf "\n"
    printf "Restoring: %s\n" "$backup_name"
    printf "\n"

    set -l item_name "SSH Backup - $backup_name"
    set -l item (bw get item "$item_name" 2>/dev/null)

    if test -z "$item"
        printf "Error: Backup not found: %s\n" "$backup_name" >&2
        return 1
    end

    # Extract encoded backup
    set -l encoded_backup (echo "$item" | jq -r '.notes' | sed -n '/--- BEGIN SSH BACKUP ---/,/--- END SSH BACKUP ---/p' | sed '1d;$d' | tr -d '\n')

    if test -z "$encoded_backup"
        printf "Error: Could not extract backup data\n" >&2
        return 1
    end

    # Check if .ssh already exists
    if test -d "$SSH_DIR"
        printf "Warning: ~/.ssh directory already exists\n"
        printf "\n"
        ls -la "$SSH_DIR" 2>/dev/null | head -10
        printf "\n"

        if test "$force_overwrite" != "true"
            if not ui-confirm-smart --prompt "Overwrite existing SSH configuration?" --default no
                printf "Restore cancelled\n"
                return 0
            end
        else
            printf "Force overwrite enabled, continuing...\n"
        end

        # Backup existing .ssh
        set -l backup_dir "$HOME/.ssh.backup."(date +%Y%m%d-%H%M%S)
        printf "Backing up existing .ssh to %s\n" "$backup_dir"
        mv "$SSH_DIR" "$backup_dir"
    end

    # Create SSH directory
    mkdir -p "$SSH_DIR"
    chmod 700 "$SSH_DIR"

    # Decode and decrypt
    set -l encrypted_file (mktemp --suffix=.tar.gz.gpg)
    echo "$encoded_backup" | base64 -d > "$encrypted_file"

    # Get passphrase for decryption
    set -l passphrase
    if test -t 0  # Check if stdin is a terminal
        if command -v gum >/dev/null 2>&1
            set passphrase (gum input --password --placeholder "Enter passphrase to decrypt backup")
        else
            printf "Enter passphrase to decrypt backup: "
            read -s passphrase
            printf "\n"
        end
    else
        # Non-interactive: read from stdin
        read passphrase
    end

    if test -z "$passphrase"
        rm -f "$encrypted_file"
        printf "Error: Passphrase cannot be empty\n" >&2
        return 1
    end

    set -l temp_tar (mktemp --suffix=.tar.gz)
    printf "Decrypting backup...\n"
    echo "$passphrase" | gpg --batch --yes --passphrase-fd 0 --decrypt --output "$temp_tar" "$encrypted_file" 2>/dev/null
    set -l gpg_status $status
    rm -f "$encrypted_file"

    if test $gpg_status -ne 0
        rm -f "$temp_tar"
        printf "Error: Failed to decrypt backup (wrong passphrase?)\n" >&2
        return 1
    end

    # Extract to SSH directory
    tar -xzf "$temp_tar" -C "$SSH_DIR" 2>/dev/null
    set -l tar_status $status
    rm -f "$temp_tar"

    if test $tar_status -ne 0
        printf "Error: Failed to extract backup\n" >&2
        return 1
    end

    # Set correct permissions
    chmod 700 "$SSH_DIR"
    chmod 600 "$SSH_DIR"/id_* 2>/dev/null
    chmod 644 "$SSH_DIR"/*.pub 2>/dev/null
    chmod 644 "$SSH_DIR/config" 2>/dev/null

    printf "\n"
    printf "✓ SSH keys restored to %s\n" "$SSH_DIR"
    printf "\n"
    printf "Restored files:\n"
    ls -la "$SSH_DIR" | grep -v "^total" | grep -v "known_hosts"
    printf "\n"
    printf "Next steps:\n"
    printf "  fedpunk ssh load         # Load keys into ssh-agent\n"
    printf "  fedpunk vault gh-restore # Authenticate with GitHub\n"
end

function ssh-list --description "List SSH key backups"
    if contains -- "$argv[1]" --help -h
        printf "List available SSH key backups in Bitwarden\n"
        printf "\n"
        printf "Usage: fedpunk vault ssh-list\n"
        return 0
    end

    _require_unlocked; or return 1

    printf "SSH Backups in Bitwarden:\n"
    printf "\n"

    set -l backups (bw list items --search "SSH Backup" 2>/dev/null | jq -r '.[] | select(.type == 2) | .name' | sed 's/SSH Backup - //')

    if test -z "$backups"
        printf "  No backups found\n"
        printf "\n"
        printf "Run 'fedpunk vault ssh-backup' to create a backup\n"
    else
        for name in (string split \n $backups)
            printf "  - %s\n" "$name"
        end
    end
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

function gh-backup --description "Backup GitHub CLI token"
    if contains -- "$argv[1]" --help -h
        printf "Backup GitHub personal access token to Bitwarden\n"
        printf "\n"
        printf "Usage: fedpunk vault gh-backup [name]\n"
        printf "\n"
        printf "This stores your GitHub PAT for automated gh auth login.\n"
        printf "Create a PAT at: https://github.com/settings/tokens\n"
        printf "\n"
        printf "Required scopes: repo, read:org, workflow, gist\n"
        printf "\n"
        printf "Examples:\n"
        printf "  fedpunk vault gh-backup              # Default backup\n"
        printf "  fedpunk vault gh-backup work         # Named backup\n"
        return 0
    end

    _require_unlocked; or return 1

    set -l backup_name $argv[1]
    set -l item_name "GitHub PAT"
    if test -n "$backup_name"
        set item_name "GitHub PAT - $backup_name"
    end

    printf "GitHub CLI Token Backup\n"
    printf "\n"
    printf "Backup name: %s\n" "$item_name"
    printf "\n"

    # Get the PAT from user
    set -l gh_token
    if test -t 0
        if command -v gum >/dev/null 2>&1
            printf "Enter your GitHub Personal Access Token:\n"
            printf "(Create one at https://github.com/settings/tokens)\n"
            printf "\n"
            set gh_token (gum input --password --placeholder "ghp_xxxxxxxxxxxx")
        else
            printf "Enter your GitHub Personal Access Token: "
            read -s gh_token
            printf "\n"
        end
    else
        read gh_token
    end

    if test -z "$gh_token"
        printf "Error: Token cannot be empty\n" >&2
        return 1
    end

    # Validate token format (should start with ghp_ or github_pat_)
    if not string match -q -r '^(ghp_|github_pat_)' "$gh_token"
        printf "Warning: Token doesn't look like a GitHub PAT\n"
        printf "Expected format: ghp_xxx or github_pat_xxx\n"
        printf "\n"
    end

    # Setup metadata
    set -l backup_hostname (hostname)
    set -l timestamp (date -u +"%Y-%m-%dT%H:%M:%SZ")

    printf "Backing up to Bitwarden vault...\n"

    # Check if item exists
    set -l existing_item (bw get item "$item_name" 2>/dev/null)
    set -l bw_result 1

    if test -n "$existing_item"
        printf "Updating existing backup...\n"
        set -l item_id (echo "$existing_item" | jq -r '.id')
        echo "$existing_item" | jq --arg token "$gh_token" --arg notes "GitHub Personal Access Token
Hostname: $backup_hostname
Timestamp: $timestamp

Restore with: fedpunk vault gh-restore" '.login.password = $token | .notes = $notes' | bw encode | bw edit item "$item_id" >/dev/null 2>&1
        set bw_result $status
    else
        printf "Creating new backup...\n"
        jq -n --arg name "$item_name" --arg token "$gh_token" --arg notes "GitHub Personal Access Token
Hostname: $backup_hostname
Timestamp: $timestamp

Restore with: fedpunk vault gh-restore" '{
            organizationId: null,
            folderId: null,
            type: 1,
            name: $name,
            notes: $notes,
            favorite: false,
            login: {
                username: "github",
                password: $token
            }
        }' | bw encode | bw create item >/dev/null 2>&1
        set bw_result $status
    end

    if test $bw_result -eq 0
        printf "\n"
        printf "✓ GitHub token backed up to Bitwarden\n"
        printf "  Item: %s\n" "$item_name"
        printf "\n"
        printf "Run 'fedpunk vault sync' to sync with server\n"
    else
        printf "Error: Failed to save backup to Bitwarden\n" >&2
        return 1
    end
end

function gh-restore --description "Restore GitHub CLI auth"
    if contains -- "$argv[1]" --help -h
        printf "Restore GitHub CLI authentication from Bitwarden\n"
        printf "\n"
        printf "Usage: fedpunk vault gh-restore [name]\n"
        printf "\n"
        printf "Authenticates gh CLI using stored PAT - no browser needed!\n"
        printf "\n"
        printf "Examples:\n"
        printf "  fedpunk vault gh-restore             # Default backup\n"
        printf "  fedpunk vault gh-restore work        # Named backup\n"
        return 0
    end

    _require_unlocked; or return 1

    if not command -v gh >/dev/null 2>&1
        printf "Error: GitHub CLI (gh) not installed\n" >&2
        return 1
    end

    set -l backup_name $argv[1]
    set -l item_name "GitHub PAT"
    if test -n "$backup_name"
        set item_name "GitHub PAT - $backup_name"
    end

    printf "GitHub CLI Authentication\n"
    printf "\n"

    # Sync vault first
    printf "Syncing vault...\n"
    bw sync >/dev/null 2>&1

    # Get the item
    set -l item (bw get item "$item_name" 2>/dev/null)

    if test -z "$item"
        printf "Error: Backup not found: %s\n" "$item_name" >&2
        printf "\n"
        printf "Available backups:\n"
        bw list items --search "GitHub PAT" 2>/dev/null | jq -r '.[] | select(.type == 1) | "  - " + .name'
        printf "\n"
        printf "Run 'fedpunk vault gh-backup' to create a backup first\n"
        return 1
    end

    # Extract token
    set -l gh_token (echo "$item" | jq -r '.login.password')

    if test -z "$gh_token" -o "$gh_token" = "null"
        printf "Error: Could not extract token from backup\n" >&2
        return 1
    end

    printf "Authenticating with GitHub...\n"

    # Login to gh using the token
    echo "$gh_token" | gh auth login --with-token 2>&1
    set -l auth_result $status

    if test $auth_result -eq 0
        printf "\n"
        printf "✓ GitHub CLI authenticated successfully\n"
        printf "\n"

        # Show auth status
        gh auth status 2>&1 | head -5
        printf "\n"
        printf "You can now use gh commands!\n"
    else
        printf "Error: Failed to authenticate with GitHub\n" >&2
        printf "The token may be invalid or expired.\n" >&2
        printf "Create a new one at: https://github.com/settings/tokens\n" >&2
        return 1
    end
end
