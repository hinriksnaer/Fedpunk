# SSH key management commands

function ssh --description "SSH key backup and restore"
    if contains -- "$argv[1]" --help -h
        printf "SSH key backup and restore\n"
        printf "\n"
        printf "Backup and restore SSH keys using GitHub (private gist) or Bitwarden.\n"
        printf "All backups are GPG encrypted (AES256).\n"
        return 0
    end
    _show_command_help ssh
end

# Parse backend and name options from args
function _parse_ssh_args
    set -g _ssh_backend "github"
    set -g _ssh_backup_name ""
    set -g _ssh_filtered_args

    set -l i 1
    while test $i -le (count $argv)
        switch $argv[$i]
            case --github -g
                set _ssh_backend "github"
            case --bitwarden -b
                set _ssh_backend "bitwarden"
            case --name -n
                set i (math $i + 1)
                set _ssh_backup_name $argv[$i]
            case '*'
                set -a _ssh_filtered_args $argv[$i]
        end
        set i (math $i + 1)
    end
end

function backup --description "Backup SSH keys"
    if contains -- "$argv[1]" --help -h
        printf "Backup SSH keys to GitHub or Bitwarden\n"
        printf "\n"
        printf "Usage: fedpunk ssh backup [options]\n"
        printf "\n"
        printf "Options:\n"
        printf "  -g, --github      Use GitHub private gist (default)\n"
        printf "  -b, --bitwarden   Use Bitwarden vault\n"
        printf "  -n, --name NAME   Backup name (default: ssh-backup)\n"
        printf "\n"
        printf "Examples:\n"
        printf "  fedpunk ssh backup                    # GitHub (default)\n"
        printf "  fedpunk ssh backup -b                 # Bitwarden\n"
        printf "  fedpunk ssh backup -g -n work-laptop  # Named GitHub backup\n"
        return 0
    end

    _parse_ssh_args $argv

    set -l SSH_DIR "$HOME/.ssh"

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
    printf "Backend: %s\n" "$_ssh_backend"
    printf "Found SSH keys:\n"
    for key in $key_files
        printf "  - %s\n" (basename $key)
    end
    printf "\n"

    # Create encrypted tarball
    set -l timestamp (date +%Y%m%d_%H%M%S)
    set -l temp_tar (mktemp --suffix=.tar.gz)

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
    if test -z "$_ssh_backup_name"
        set _ssh_backup_name "ssh-backup"
    end

    switch $_ssh_backend
        case github
            _backup_to_github "$encoded_backup" "$_ssh_backup_name" "$hostname_str" "$timestamp"
        case bitwarden
            _backup_to_bitwarden "$encoded_backup" "$_ssh_backup_name" "$hostname_str" "$timestamp"
    end
end

function _backup_to_github
    set -l encoded_backup $argv[1]
    set -l backup_name $argv[2]
    set -l hostname_str $argv[3]
    set -l timestamp $argv[4]

    # Check GitHub CLI
    if not command -v gh >/dev/null 2>&1
        printf "Error: GitHub CLI not found. Install with: sudo dnf install gh\n" >&2
        return 1
    end

    if not gh auth status >/dev/null 2>&1
        printf "Error: Not authenticated with GitHub. Run 'gh auth login' first.\n" >&2
        return 1
    end

    printf "Backing up to GitHub private gist...\n"

    set -l gist_name "git-ssh-backup-$backup_name"
    set -l gist_filename "$gist_name.enc"

    # Check if gist already exists
    set -l existing_gist (gh gist list --limit 100 2>/dev/null | grep "$gist_name" | head -1 | awk '{print $1}')

    # Create content file
    set -l content_file (mktemp)
    printf "# Git SSH Backup\n" > "$content_file"
    printf "# Name: %s\n" "$backup_name" >> "$content_file"
    printf "# Hostname: %s\n" "$hostname_str" >> "$content_file"
    printf "# Timestamp: %s\n" "$timestamp" >> "$content_file"
    printf "# Format: tar.gz.gpg (base64 encoded)\n" >> "$content_file"
    printf "\n" >> "$content_file"
    printf "--- BEGIN SSH BACKUP ---\n" >> "$content_file"
    printf "%s\n" "$encoded_backup" >> "$content_file"
    printf "--- END SSH BACKUP ---\n" >> "$content_file"

    if test -n "$existing_gist"
        # Update existing gist
        gh gist edit "$existing_gist" -f "$gist_filename" "$content_file" >/dev/null 2>&1
        set -l gist_status $status
        set -l gist_url "https://gist.github.com/$existing_gist"
    else
        # Create new private gist
        set -l gist_output (gh gist create --private -f "$gist_filename" "$content_file" 2>&1)
        set -l gist_status $status
        set -l gist_url "$gist_output"
    end

    rm -f "$content_file"

    if test $gist_status -eq 0
        printf "\n"
        printf "SSH keys backed up to GitHub\n"
        printf "  Name: %s\n" "$backup_name"
        printf "  Gist: %s\n" "$gist_url"
        printf "\n"
        printf "To restore: fedpunk ssh restore -g -n %s\n" "$backup_name"
    else
        printf "Error: Failed to create/update GitHub gist\n" >&2
        return 1
    end
end

function _backup_to_bitwarden
    set -l encoded_backup $argv[1]
    set -l backup_name $argv[2]
    set -l hostname_str $argv[3]
    set -l timestamp $argv[4]

    # Check Bitwarden CLI
    if not command -v bw >/dev/null 2>&1
        printf "Error: Bitwarden CLI not found. Install with: sudo dnf install bw\n" >&2
        return 1
    end

    set -l bw_status (bw status 2>/dev/null | grep -o '"status":"[^"]*"' | cut -d'"' -f4)
    if test "$bw_status" != "unlocked"
        printf "Error: Bitwarden vault is locked. Run 'fedpunk vault unlock' first.\n" >&2
        return 1
    end

    printf "Backing up to Bitwarden vault...\n"

    set -l item_name "SSH Backup - $backup_name"

    # Prepare note content
    set -l note_content "SSH Backup
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
        set -l item_id (echo "$existing_item" | jq -r '.id')
        echo "$existing_item" | jq --arg notes "$note_content" '.notes = $notes' | bw encode | bw edit item "$item_id" >/dev/null 2>&1
        set -l bw_result $status
    else
        # Create new secure note
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
        printf "SSH keys backed up to Bitwarden\n"
        printf "  Item: %s\n" "$item_name"
        printf "\n"
        printf "To restore: fedpunk ssh restore -b -n %s\n" "$backup_name"
        printf "Run 'bw sync' to sync with server\n"
    else
        printf "Error: Failed to create/update Bitwarden item\n" >&2
        return 1
    end
end

function restore --description "Restore SSH keys"
    if contains -- "$argv[1]" --help -h
        printf "Restore SSH keys from GitHub or Bitwarden\n"
        printf "\n"
        printf "Usage: fedpunk ssh restore [options]\n"
        printf "\n"
        printf "Options:\n"
        printf "  -g, --github      Use GitHub private gist (default)\n"
        printf "  -b, --bitwarden   Use Bitwarden vault\n"
        printf "  -n, --name NAME   Backup name to restore\n"
        printf "\n"
        printf "Examples:\n"
        printf "  fedpunk ssh restore                   # Restore from GitHub\n"
        printf "  fedpunk ssh restore -b                # Restore from Bitwarden\n"
        printf "  fedpunk ssh restore -g -n work-laptop # Restore named backup\n"
        return 0
    end

    _parse_ssh_args $argv

    set -l SSH_DIR "$HOME/.ssh"

    switch $_ssh_backend
        case github
            _restore_from_github "$_ssh_backup_name" "$SSH_DIR"
        case bitwarden
            _restore_from_bitwarden "$_ssh_backup_name" "$SSH_DIR"
    end
end

function _restore_from_github
    set -l backup_name $argv[1]
    set -l SSH_DIR $argv[2]

    # Check GitHub CLI
    if not command -v gh >/dev/null 2>&1
        printf "Error: GitHub CLI not found. Install with: sudo dnf install gh\n" >&2
        return 1
    end

    if not gh auth status >/dev/null 2>&1
        printf "Error: Not authenticated with GitHub. Run 'gh auth login' first.\n" >&2
        return 1
    end

    # List available backups
    set -l available_gists (gh gist list --limit 100 2>/dev/null | grep "git-ssh-backup-")

    if test -z "$available_gists"
        printf "Error: No SSH backups found in GitHub gists\n" >&2
        printf "Run 'fedpunk ssh backup -g' to create a backup first\n" >&2
        return 1
    end

    # Select backup
    if test -z "$backup_name"
        set -l gist_names (gh gist list --limit 100 2>/dev/null | grep "git-ssh-backup-" | awk '{print $2}' | sed 's/git-ssh-backup-//' | sed 's/\.enc//')

        if test (count $gist_names) -eq 1
            set backup_name $gist_names[1]
            printf "Found backup: %s\n" "$backup_name"
        else
            set backup_name (ui-select-smart \
                --header "Select backup to restore:" \
                --options $gist_names)
            or return 1
        end
    end

    printf "SSH Key Restore (GitHub)\n"
    printf "\n"
    printf "Restoring: %s\n" "$backup_name"
    printf "\n"

    # Find the gist
    set -l gist_id (gh gist list --limit 100 2>/dev/null | grep "git-ssh-backup-$backup_name" | head -1 | awk '{print $1}')

    if test -z "$gist_id"
        printf "Error: Backup not found: %s\n" "$backup_name" >&2
        return 1
    end

    # Get gist content
    set -l gist_content (gh gist view "$gist_id" --raw 2>/dev/null)

    if test -z "$gist_content"
        printf "Error: Failed to retrieve gist content\n" >&2
        return 1
    end

    # Extract encoded backup
    set -l encoded_backup (echo "$gist_content" | sed -n '/--- BEGIN SSH BACKUP ---/,/--- END SSH BACKUP ---/p' | sed '1d;$d' | tr -d '\n')

    _do_restore "$encoded_backup" "$SSH_DIR"
end

function _restore_from_bitwarden
    set -l backup_name $argv[1]
    set -l SSH_DIR $argv[2]

    # Check Bitwarden CLI
    if not command -v bw >/dev/null 2>&1
        printf "Error: Bitwarden CLI not found. Install with: sudo dnf install bw\n" >&2
        return 1
    end

    set -l bw_status (bw status 2>/dev/null | grep -o '"status":"[^"]*"' | cut -d'"' -f4)
    if test "$bw_status" != "unlocked"
        printf "Error: Bitwarden vault is locked. Run 'fedpunk vault unlock' first.\n" >&2
        return 1
    end

    # Sync vault
    bw sync >/dev/null 2>&1

    # List available backups
    set -l available_backups (bw list items --search "SSH Backup" 2>/dev/null | jq -r '.[] | select(.type == 2) | .name' | sed 's/SSH Backup - //')

    if test -z "$available_backups"
        printf "Error: No SSH backups found in Bitwarden\n" >&2
        printf "Run 'fedpunk ssh backup -b' to create a backup first\n" >&2
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

    printf "SSH Key Restore (Bitwarden)\n"
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

    _do_restore "$encoded_backup" "$SSH_DIR"
end

function _do_restore
    set -l encoded_backup $argv[1]
    set -l SSH_DIR $argv[2]

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
    printf "SSH keys restored to %s\n" "$SSH_DIR"
    printf "\n"
    printf "Restored files:\n"
    ls -la "$SSH_DIR" | grep -v "^total" | grep -v "known_hosts"
end

function list --description "List available backups"
    if contains -- "$argv[1]" --help -h
        printf "List available SSH key backups\n"
        printf "\n"
        printf "Usage: fedpunk ssh list [options]\n"
        printf "\n"
        printf "Options:\n"
        printf "  -g, --github      List GitHub backups (default)\n"
        printf "  -b, --bitwarden   List Bitwarden backups\n"
        return 0
    end

    _parse_ssh_args $argv

    switch $_ssh_backend
        case github
            if not command -v gh >/dev/null 2>&1
                printf "Error: GitHub CLI not found\n" >&2
                return 1
            end

            if not gh auth status >/dev/null 2>&1
                printf "Error: Not authenticated with GitHub\n" >&2
                return 1
            end

            printf "GitHub SSH Backups:\n"
            printf "\n"
            set -l gists (gh gist list --limit 100 2>/dev/null | grep "git-ssh-backup-")
            if test -z "$gists"
                printf "  No backups found\n"
            else
                for gist in $gists
                    set -l gist_name (echo "$gist" | awk '{print $2}' | sed 's/git-ssh-backup-//' | sed 's/\.enc//')
                    printf "  - %s\n" "$gist_name"
                end
            end

        case bitwarden
            if not command -v bw >/dev/null 2>&1
                printf "Error: Bitwarden CLI not found\n" >&2
                return 1
            end

            set -l bw_status (bw status 2>/dev/null | grep -o '"status":"[^"]*"' | cut -d'"' -f4)
            if test "$bw_status" != "unlocked"
                printf "Error: Bitwarden vault is locked\n" >&2
                return 1
            end

            printf "Bitwarden SSH Backups:\n"
            printf "\n"
            set -l backups (bw list items --search "SSH Backup" 2>/dev/null | jq -r '.[] | select(.type == 2) | .name' | sed 's/SSH Backup - //')
            if test -z "$backups"
                printf "  No backups found\n"
            else
                for name in (string split \n $backups)
                    printf "  - %s\n" "$name"
                end
            end
    end
end
