function bwunlock --description "Unlock Bitwarden vault and automatically set session key"
    # Run bw unlock --raw to get just the session key
    # Only redirect stdout, let stderr (password prompt) go to terminal
    echo "Unlocking Bitwarden vault..."
    set -l temp_file (mktemp)

    # Run unlock, stdout goes to temp file, stderr (prompt) stays on terminal
    bw unlock --raw >$temp_file
    set -l unlock_status $status

    # Read the session key from temp file
    set -l session_key (cat $temp_file | string trim)
    rm -f $temp_file

    if test $unlock_status -eq 0 -a -n "$session_key"
        # Set session key as universal variable
        set -Ux BW_SESSION $session_key
        echo ""
        echo "✓ Vault unlocked and session key saved to BW_SESSION"
        echo "✓ You can now use: bw list items, bw get password, etc."
        return 0
    else
        echo ""
        echo "✗ Failed to unlock vault (exit: $unlock_status, key empty: "(test -z "$session_key"; and echo "yes"; or echo "no")")"
        return 1
    end
end
