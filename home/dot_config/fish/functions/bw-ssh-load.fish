function bw-ssh-load --description "Load SSH key from Bitwarden into SSH agent"
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

    # Search for SSH key items
    set ssh_items (bw list items --search "SSH Key" 2>/dev/null | jq -r '.[] | select(.type == 2) | .name')

    if test -z "$ssh_items"
        echo "✗ No SSH keys found in Bitwarden"
        echo "  Run 'bw-ssh-add' to add your SSH keys"
        return 1
    end

    # If specific key name provided, use it
    if test (count $argv) -gt 0
        set selected_key $argv[1]
    else
        # Let user select which key to load
        set selected_key (printf "%s\n" $ssh_items | gum choose --header "Select SSH key to load:")
        if test -z "$selected_key"
            echo "No key selected"
            return 0
        end
    end

    # Get the item
    set item (bw get item "$selected_key" 2>/dev/null)
    if test -z "$item"
        echo "✗ Failed to retrieve key: $selected_key"
        return 1
    end

    # Extract private key from notes
    set notes (echo "$item" | jq -r '.notes')
    set private_key (echo "$notes" | sed -n '/SSH Private Key:/,/SSH Public Key:/p' | sed '1d;$d' | string trim)

    if test -z "$private_key"
        echo "✗ Could not extract private key from item"
        return 1
    end

    # Start SSH agent if not running
    if not set -q SSH_AGENT_PID
        eval (ssh-agent -c) >/dev/null
        set -Ux SSH_AGENT_PID $SSH_AGENT_PID
        set -Ux SSH_AUTH_SOCK $SSH_AUTH_SOCK
    end

    # Write key to temporary file and add to agent
    set temp_key (mktemp)
    echo "$private_key" > "$temp_key"
    chmod 600 "$temp_key"

    ssh-add "$temp_key" 2>/dev/null
    set add_status $status

    # Clean up temp file
    rm -f "$temp_key"

    if test $add_status -eq 0
        echo "✓ SSH key loaded into agent: $selected_key"
        return 0
    else
        echo "✗ Failed to add key to SSH agent"
        return 1
    end
end
