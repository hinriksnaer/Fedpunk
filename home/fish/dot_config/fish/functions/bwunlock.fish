function bwunlock --description "Unlock Bitwarden vault and automatically set session key"
    # Get session key directly with --raw flag
    set -l session_key (bw unlock --raw)

    if test $status -eq 0 -a -n "$session_key"
        # Set session key as universal variable
        set -Ux BW_SESSION $session_key
        echo "✓ Vault unlocked and session key saved to BW_SESSION"
        echo "✓ You can now use: bw list items, bw get password, etc."
    else
        echo "✗ Failed to unlock vault"
        return 1
    end
end
