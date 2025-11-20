function bwlogin --description "Login to Bitwarden and automatically set session key"
    # Run bw login and capture output
    set -l output (bw login $argv 2>&1)
    set -l login_status $pipestatus[1]

    # Display the output
    echo $output

    # Check if login succeeded
    if test $login_status -ne 0
        echo ""
        echo "✗ Login failed"
        return 1
    end

    # Extract session key from output
    set -l session_key (echo $output | grep -o 'BW_SESSION="[^"]*"' | head -1 | cut -d'"' -f2)

    if test -n "$session_key"
        # Set session key as universal variable
        set -Ux BW_SESSION $session_key
        echo ""
        echo "✓ Session key automatically saved to BW_SESSION"
        echo "✓ You can now use: bw list items, bw get password, etc."
    else
        echo ""
        echo "⚠ Could not extract session key from login output"
        return 1
    end
end
