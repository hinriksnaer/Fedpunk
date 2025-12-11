function bwlogin --description "Login to Bitwarden and automatically unlock with session key"
    # Use bw login --raw to login and get session key in one step (only one password prompt)
    echo "Logging in to Bitwarden..."
    echo ""

    set -l session_key (bw login --raw $argv)

    if test $status -eq 0 -a -n "$session_key"
        # Set session key as universal variable
        set -Ux BW_SESSION $session_key
        echo ""
        echo "✓ Login successful"
        echo "✓ Vault unlocked and session key saved to BW_SESSION"
        echo "✓ You can now use: bw list items, bw get password, etc."
    else
        echo ""
        echo "✗ Login failed"
        return 1
    end
end
