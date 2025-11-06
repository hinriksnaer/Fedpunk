function claude
    # Enhanced claude command with Fish-specific features
    if test (count $argv) -eq 0
        # Interactive mode
        command claude --interactive
    else
        # Pass through all arguments
        command claude $argv
    end
end
