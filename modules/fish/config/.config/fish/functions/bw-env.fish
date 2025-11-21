function bw-env --description "Load environment variables from Bitwarden secure note"
    # Check if bw is installed
    if not command -v bw >/dev/null 2>&1
        echo "✗ Bitwarden CLI not found"
        return 1
    end

    # Check if vault is unlocked
    set bw_status (bw status 2>/dev/null | grep -o '"status":"[^"]*"' | cut -d'"' -f4)
    if test "$bw_status" != "unlocked"
        echo "✗ Bitwarden vault is locked. Run 'bwunlock' first."
        return 1
    end

    # If item name provided, use it
    if test (count $argv) -gt 0
        set item_name $argv[1]
    else
        # Search for env files
        set env_items (bw list items 2>/dev/null | jq -r '.[] | select(.type == 2 and (.name | test("env|ENV|environment"; "i"))) | .name')

        if test -z "$env_items"
            echo "✗ No environment variable items found"
            echo "  Create a secure note with 'env' or 'environment' in the name"
            return 1
        end

        # Let user select
        set item_name (printf "%s\n" $env_items | gum choose --header "Select environment file:")
        if test -z "$item_name"
            return 0
        end
    end

    # Get the item
    set item (bw get item "$item_name" 2>/dev/null)
    if test -z "$item"
        echo "✗ Failed to retrieve item: $item_name"
        return 1
    end

    # Extract notes and parse as env variables
    set notes (echo "$item" | jq -r '.notes')

    if test -z "$notes"
        echo "✗ No content found in item"
        return 1
    end

    # Parse and export variables (format: KEY=value or export KEY=value)
    set count 0
    for line in (echo "$notes" | string split \n)
        # Skip comments and empty lines
        if string match -qr '^\s*#' $line; or test -z (string trim $line)
            continue
        end

        # Extract KEY=value
        if string match -qr '^(export\s+)?([A-Z_][A-Z0-9_]*)=(.*)$' $line
            set parts (string split -m 1 = (string replace 'export ' '' $line))
            if test (count $parts) -eq 2
                set -gx $parts[1] $parts[2]
                set count (math $count + 1)
                echo "✓ Loaded: $parts[1]"
            end
        end
    end

    echo ""
    echo "✓ Loaded $count environment variables from '$item_name'"
end
