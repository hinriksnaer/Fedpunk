#!/usr/bin/env fish
# ============================================================================
# CLI Auto-Discovery and Dispatch Library for Fedpunk
# ============================================================================
# Provides self-documenting, auto-discovery patterns for CLI commands
#
# Usage in commands:
#   source "$FEDPUNK_SYSTEM/lib/fish/cli-dispatch.fish"
#   cli-dispatch <cmd-name> <cmd-dir> $argv
#
# Features:
#   - Auto-discovers subcommands from function definitions across multiple files
#   - Extracts descriptions from --description flags
#   - Generates help text dynamically
#   - Handles dispatch and error cases
# ============================================================================

# ============================================================================
# Discovery Functions
# ============================================================================

function cli-discover-subcommands --argument-names cmd_dir group_fn
    # Discover all non-private functions in command directory
    # Scans ALL .fish files in the directory
    #
    # Args:
    #   cmd_dir: Directory containing .fish files (e.g., $FEDPUNK_CLI/config)
    #   group_fn: Name of group function to exclude (e.g., "config")
    #
    # Returns: List of function names (newline separated, sorted)
    #
    # Example:
    #   cli-discover-subcommands "$FEDPUNK_CLI/vault" vault
    #   # Returns: backup, lock, login, restore, sync, unlock

    set -l found

    for file in $cmd_dir/*.fish
        test -f "$file"; or continue

        # Skip private files (starting with _)
        set -l basename_file (basename "$file")
        string match -q "_*" "$basename_file"; and continue

        # Extract function names from file
        for fn in (grep -oP "^function \K[a-zA-Z][a-zA-Z0-9_-]*" "$file" 2>/dev/null)
            # Skip private functions (starting with _)
            string match -q "_*" "$fn"; and continue

            # Skip the group function itself
            test "$fn" = "$group_fn"; and continue

            # Add to found list
            set -a found $fn
        end
    end

    # Return sorted unique list
    if test (count $found) -gt 0
        printf '%s\n' $found | sort -u
    end
end

function cli-get-description --argument-names cmd_dir fn_name
    # Extract function description from --description flag
    # Searches ALL .fish files in the directory
    #
    # Args:
    #   cmd_dir: Directory containing .fish files
    #   fn_name: Function name to find description for
    #
    # Returns: Description string (empty if not found)
    #
    # Example:
    #   cli-get-description "$FEDPUNK_CLI/vault" backup
    #   # Returns: "Backup SSH keys to vault"

    for file in $cmd_dir/*.fish
        test -f "$file"; or continue

        # Skip private files
        set -l basename_file (basename "$file")
        string match -q "_*" "$basename_file"; and continue

        # Find the function definition line
        set -l line (grep -P "^function $fn_name\\s+" "$file" 2>/dev/null | head -1)

        if test -n "$line"
            # Extract --description "text" or -d "text"
            # Handles both single and double quotes
            set -l desc (echo $line | sed -n 's/.*--description[= ]["'"'"']\([^"'"'"']*\)["'"'"'].*/\1/p')

            if test -z "$desc"
                set desc (echo $line | sed -n 's/.*-d[= ]["'"'"']\([^"'"'"']*\)["'"'"'].*/\1/p')
            end

            if test -n "$desc"
                echo $desc
                return 0
            end
        end
    end
end

# ============================================================================
# Help Generation
# ============================================================================

function cli-generate-help --argument-names cmd_name cmd_dir
    # Generate help text for a command with auto-discovered subcommands
    #
    # Args:
    #   cmd_name: Command name (e.g., "vault")
    #   cmd_dir: Directory containing command files
    #
    # Output: Formatted help text to stdout
    #
    # Example output:
    #   Bitwarden vault management
    #
    #   Usage: fedpunk vault <subcommand> [args...]
    #
    #   Subcommands:
    #     login          Login to Bitwarden
    #     unlock         Unlock the vault
    #     lock           Lock the vault
    #     ...
    #
    #   Run 'fedpunk vault <subcommand> --help' for details

    # Get and display command description
    set -l cmd_desc (cli-get-description $cmd_dir $cmd_name)
    if test -n "$cmd_desc"
        echo "$cmd_desc"
        echo ""
    end

    echo "Usage: fedpunk $cmd_name <subcommand> [args...]"
    echo ""

    # Discover and list subcommands
    set -l subcommands (cli-discover-subcommands $cmd_dir $cmd_name)

    if test -n "$subcommands"
        echo "Subcommands:"
        for fn in $subcommands
            set -l fn_desc (cli-get-description $cmd_dir $fn)
            printf "  %-14s %s\n" $fn "$fn_desc"
        end
        echo ""
        echo "Run 'fedpunk $cmd_name <subcommand> --help' for details"
    else
        echo "No subcommands available"
    end
end

# ============================================================================
# Dispatch Logic
# ============================================================================

function cli-auto-dispatch --argument-names cmd_name
    # Simplified dispatch with automatic command directory detection
    #
    # Automatically determines the command directory by searching for the
    # command file in standard locations. This eliminates the need to
    # manually calculate and pass the directory path.
    #
    # Args:
    #   cmd_name: Command name (must match a function name)
    #   ...: Remaining args are command arguments
    #
    # Returns: Exit code from subcommand or error
    #
    # Example:
    #   function mymodule --description "My module commands"
    #       cli-auto-dispatch mymodule $argv
    #   end

    # Auto-detect command directory by finding where the function is defined
    set -l cmd_dir

    # Search common locations for the command file
    for base_dir in "$FEDPUNK_CLI" "$FEDPUNK_USER/cli" "$FEDPUNK_SYSTEM/modules/*/cli" "$FEDPUNK_USER/.active-config/plugins/*/cli"
        for file in $base_dir/**/$cmd_name.fish $base_dir/$cmd_name/$cmd_name.fish
            if test -f "$file"
                if grep -q "^function $cmd_name\\s" "$file" 2>/dev/null
                    set cmd_dir (dirname "$file")
                    break 2
                end
            end
        end
    end

    # Fallback: if not found, assume current directory
    if test -z "$cmd_dir"
        set cmd_dir (pwd)
    end

    # Call standard dispatch with detected directory
    cli-dispatch $cmd_name $cmd_dir $argv[2..-1]
end

function cli-dispatch --argument-names cmd_name cmd_dir
    # Standard dispatch logic for auto-discovery commands
    #
    # Handles:
    #   - Help requests (no args, --help, -h, help)
    #   - Subcommand discovery and validation
    #   - Error handling for unknown subcommands
    #   - Execution of valid subcommands
    #
    # Args:
    #   cmd_name: Command name
    #   cmd_dir: Directory containing command files
    #   ...: Remaining args are command arguments
    #
    # Returns: Exit code from subcommand or error
    #
    # Example:
    #   cli-dispatch vault "$FEDPUNK_CLI/vault" $argv

    set -l subcmd $argv[3]
    set -l args $argv[4..-1]

    # No subcommand or --help requested
    if test -z "$subcmd"; or contains -- "$subcmd" --help -h help
        cli-generate-help $cmd_name $cmd_dir
        return 0
    end

    # Check if subcommand is private (starts with _)
    if string match -q "_*" "$subcmd"
        echo "Unknown subcommand: $cmd_name $subcmd" >&2
        echo "Run 'fedpunk $cmd_name --help' for available subcommands" >&2
        return 1
    end

    # Check if subcommand function exists
    if not functions -q "$subcmd"
        echo "Unknown subcommand: $cmd_name $subcmd" >&2
        echo "" >&2
        cli-generate-help $cmd_name $cmd_dir >&2
        return 1
    end

    # Verify it's a discovered subcommand (not a random function in scope)
    set -l valid_subcommands (cli-discover-subcommands $cmd_dir $cmd_name)
    if not contains -- "$subcmd" $valid_subcommands
        echo "Unknown subcommand: $cmd_name $subcmd" >&2
        echo "" >&2
        cli-generate-help $cmd_name $cmd_dir >&2
        return 1
    end

    # Execute subcommand with remaining args
    $subcmd $args
end
