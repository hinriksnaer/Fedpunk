function claude
    # Enhanced claude command with Fish-specific features
    if test (count $argv) -eq 0
        # No arguments - run claude as-is
        command claude
    else
        # Pass through all arguments
        command claude $argv
    end
end
