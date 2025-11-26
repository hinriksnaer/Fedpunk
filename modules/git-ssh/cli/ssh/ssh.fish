# SSH key management commands
# Backup and restore SSH keys using Bitwarden vault

function ssh --description "SSH key backup and restore"
    if contains -- "$argv[1]" --help -h
        printf "SSH key backup and restore\n"
        printf "\n"
        printf "Backup and restore SSH keys using Bitwarden vault.\n"
        printf "Keys are stored as GPG-encrypted secure notes.\n"
        return 0
    end
    _show_command_help ssh
end

function _require_vault_unlocked
    if not command -v bw >/dev/null 2>&1
        printf "Error: Bitwarden CLI not installed\n" >&2
        printf "Run: fedpunk module deploy bitwarden\n" >&2
        return 1
    end

    set -l bw_status (bw status 2>/dev/null | grep -o '"status":"[^"]*"' | cut -d'"' -f4)
    if test "$bw_status" != "unlocked"
        printf "Error: Bitwarden vault is locked\n" >&2
        printf "Run: fedpunk vault unlock\n" >&2
        return 1
    end
    return 0
end

function backup --description "Backup SSH keys to vault"
    if contains -- "$argv[1]" --help -h
        printf "Backup SSH keys to Bitwarden vault\n"
        printf "\n"
        printf "Usage: fedpunk ssh backup [name]\n"
        printf "\n"
        printf "Arguments:\n"
        printf "  name    Backup name (default: hostname)\n"
        printf "\n"
        printf "Examples:\n"
        printf "  fedpunk ssh backup             # Use hostname as name\n"
        printf "  fedpunk ssh backup work-laptop # Named backup\n"
        return 0
    end

    _require_vault_unlocked; or return 1

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
    printf "\n"

    # Build list of files to backup
    set -l files_to_backup
    for k in $key_files
        set -a files_to_backup (basename $k)
        if test -f "$k.pub"
            set -a files_to_backup (basename $k).pub
        end
    end

    # Include config if exists
    if test -f "$SSH_DIR/config"
        set -a files_to_backup config
    end

    # Create tarball
    set -l temp_tar (mktemp --suffix=.tar.gz)
    tar -czf "$temp_tar" -C "$SSH_DIR" $files_to_backup 2>/dev/null

    if test $status -ne 0
        rm -f "$temp_tar"
        printf "Error: Failed to create archive\n" >&2
        return 1
    end

    # Encrypt with GPG
    set -l encrypted_file (mktemp --suffix=.tar.gz.gpg)
    printf "Enter a passphrase to encrypt your backup:\n"
    gpg --symmetric --cipher-algo AES256 --output "$encrypted_file" "$temp_tar" 2>/dev/null
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

    if test -n "$existing_item"
        # Update existing item
        printf "Updating existing backup...\n"
        set -l item_id (echo "$existing_item" | jq -r '.id')
        echo "$existing_item" | jq --arg notes "$note_content" '.notes = $notes' | bw encode | bw edit item "$item_id" >/dev/null 2>&1
        set -l bw_result $status
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
        set -l bw_result $status
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

function restore --description "Restore SSH keys from vault"
    if contains -- "$argv[1]" --help -h
        printf "Restore SSH keys from Bitwarden vault\n"
        printf "\n"
        printf "Usage: fedpunk ssh restore [name]\n"
        printf "\n"
        printf "Arguments:\n"
        printf "  name    Backup name (interactive if not provided)\n"
        printf "\n"
        printf "Examples:\n"
        printf "  fedpunk ssh restore             # Interactive selection\n"
        printf "  fedpunk ssh restore work-laptop # Restore specific backup\n"
        return 0
    end

    _require_vault_unlocked; or return 1

    set -l SSH_DIR "$HOME/.ssh"
    set -l backup_name $argv[1]

    # Sync vault
    printf "Syncing vault...\n"
    bw sync >/dev/null 2>&1

    # List available backups
    set -l available_backups (bw list items --search "SSH Backup" 2>/dev/null | jq -r '.[] | select(.type == 2) | .name' | sed 's/SSH Backup - //')

    if test -z "$available_backups"
        printf "Error: No SSH backups found in Bitwarden\n" >&2
        printf "Run 'fedpunk ssh backup' to create a backup first\n" >&2
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

        if not ui-confirm-smart --prompt "Overwrite existing SSH configuration?" --default no
            printf "Restore cancelled\n"
            return 0
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

    set -l temp_tar (mktemp --suffix=.tar.gz)
    printf "Enter the passphrase to decrypt your backup:\n"
    gpg --decrypt --output "$temp_tar" "$encrypted_file" 2>/dev/null
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
    printf "  fedpunk ssh load    # Load keys into ssh-agent\n"
    printf "  gh auth login       # Authenticate with GitHub\n"
end

function load --description "Load SSH keys into agent"
    if contains -- "$argv[1]" --help -h
        printf "Load SSH keys into ssh-agent\n"
        printf "\n"
        printf "Usage: fedpunk ssh load [key]\n"
        printf "\n"
        printf "Arguments:\n"
        printf "  key    Specific key to load (default: all keys)\n"
        printf "\n"
        printf "Examples:\n"
        printf "  fedpunk ssh load           # Load all keys\n"
        printf "  fedpunk ssh load id_ed25519 # Load specific key\n"
        return 0
    end

    set -l SSH_DIR "$HOME/.ssh"
    set -l key_name $argv[1]

    # Start ssh-agent if not running
    if not set -q SSH_AGENT_PID
        eval (ssh-agent -c) >/dev/null
        set -Ux SSH_AGENT_PID $SSH_AGENT_PID
        set -Ux SSH_AUTH_SOCK $SSH_AUTH_SOCK
        printf "Started ssh-agent\n"
    end

    if test -n "$key_name"
        # Load specific key
        set -l key_path "$SSH_DIR/$key_name"
        if not test -f "$key_path"
            printf "Error: Key not found: %s\n" "$key_path" >&2
            return 1
        end
        ssh-add "$key_path"
    else
        # Load all keys
        set -l key_files (find "$SSH_DIR" -maxdepth 1 -type f -name "id_*" ! -name "*.pub" 2>/dev/null)

        if test -z "$key_files"
            printf "Error: No SSH keys found in %s\n" "$SSH_DIR" >&2
            return 1
        end

        for key in $key_files
            printf "Loading %s...\n" (basename $key)
            ssh-add "$key" 2>/dev/null
        end
    end

    printf "\n"
    printf "Loaded keys:\n"
    ssh-add -l
end

function list --description "List available backups"
    if contains -- "$argv[1]" --help -h
        printf "List available SSH key backups in Bitwarden\n"
        printf "\n"
        printf "Usage: fedpunk ssh list\n"
        return 0
    end

    _require_vault_unlocked; or return 1

    printf "SSH Backups in Bitwarden:\n"
    printf "\n"

    set -l backups (bw list items --search "SSH Backup" 2>/dev/null | jq -r '.[] | select(.type == 2) | .name' | sed 's/SSH Backup - //')

    if test -z "$backups"
        printf "  No backups found\n"
        printf "\n"
        printf "Run 'fedpunk ssh backup' to create a backup\n"
    else
        for name in (string split \n $backups)
            printf "  - %s\n" "$name"
        end
    end
end
