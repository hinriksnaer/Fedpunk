function bwlogin --description "Login to Bitwarden and automatically unlock with session key"
    # Run bw login interactively (allows password prompt to work)
    if not bw login $argv
        echo ""
        echo "✗ Login failed"
        return 1
    end

    echo ""
    echo "✓ Login successful"
    echo ""
    echo "→ Unlocking vault..."

    # Now unlock and get session key
    set -l session_key (bw unlock --raw)

    if test $status -eq 0 -a -n "$session_key"
        # Set session key as universal variable
        set -Ux BW_SESSION $session_key
        echo "✓ Vault unlocked and session key saved to BW_SESSION"
        echo "✓ You can now use: bw list items, bw get password, etc."
    else
        echo "✗ Failed to unlock vault"
        echo "  Run 'bwunlock' to unlock manually"
        return 1
    end
end
