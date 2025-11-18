function bw-get --description "Quickly get a password or item from Bitwarden"
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

    # If search term provided, use it
    if test (count $argv) -gt 0
        set search_term $argv[1]
    else
        # Interactive search
        set search_term (gum input --placeholder "Search for item...")
        if test -z "$search_term"
            return 0
        end
    end

    # Search for items
    set items (bw list items --search "$search_term" 2>/dev/null)
    set item_count (echo "$items" | jq '. | length')

    if test "$item_count" -eq 0
        echo "✗ No items found matching: $search_term"
        return 1
    end

    # If multiple items, let user choose
    if test "$item_count" -gt 1
        set item_names (echo "$items" | jq -r '.[].name')
        set selected (printf "%s\n" $item_names | gum choose --header "Multiple items found. Select one:")
        if test -z "$selected"
            return 0
        end
        set item (echo "$items" | jq -r ".[] | select(.name == \"$selected\")")
    else
        set item (echo "$items" | jq -r '.[0]')
    end

    # Get password/username
    set password (echo "$item" | jq -r '.login.password // empty')
    set username (echo "$item" | jq -r '.login.username // empty')
    set name (echo "$item" | jq -r '.name')

    echo ""
    echo "Item: $name"
    if test -n "$username"
        echo "Username: $username"
    end

    if test -n "$password"
        # Copy to clipboard if available
        if command -v wl-copy >/dev/null 2>&1
            echo "$password" | wl-copy
            echo "✓ Password copied to clipboard"
        else if command -v xclip >/dev/null 2>&1
            echo "$password" | xclip -selection clipboard
            echo "✓ Password copied to clipboard"
        else
            echo "Password: $password"
        end
    else
        echo "No password found in this item"
    end
end
