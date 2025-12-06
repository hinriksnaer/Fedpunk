# WiFi management commands

function wifi --description "WiFi network management"
    if contains -- "$argv[1]" --help -h
        printf "WiFi network management\n"
        printf "\n"
        printf "Scan, connect, and manage WiFi networks.\n"
        return 0
    end
    _show_command_help wifi
end

# Check if nmcli is available
function _require_nmcli
    if not command -v nmcli >/dev/null 2>&1
        printf "Error: nmcli not installed\n" >&2
        printf "Run: fedpunk module deploy wifi\n" >&2
        return 1
    end
    return 0
end

function on --description "Enable WiFi"
    if contains -- "$argv[1]" --help -h
        printf "Enable WiFi radio\n"
        printf "\n"
        printf "Usage: fedpunk wifi on\n"
        return 0
    end

    _require_nmcli; or return 1
    nmcli radio wifi on
end

function off --description "Disable WiFi"
    if contains -- "$argv[1]" --help -h
        printf "Disable WiFi radio\n"
        printf "\n"
        printf "Usage: fedpunk wifi off\n"
        return 0
    end

    _require_nmcli; or return 1
    nmcli radio wifi off
end

function info --description "Show WiFi status"
    if contains -- "$argv[1]" --help -h
        printf "Show WiFi radio and connection status\n"
        printf "\n"
        printf "Usage: fedpunk wifi info\n"
        return 0
    end

    _require_nmcli; or return 1

    printf "WiFi Radio: "
    set -l radio_status (nmcli radio wifi)
    if test "$radio_status" = "enabled"
        printf "enabled\n"
    else
        printf "disabled\n"
    end

    printf "\nCurrent connection:\n"
    nmcli -t -f NAME,TYPE,DEVICE connection show --active | string match -r '.*:802-11-wireless:.*' | while read -l line
        set -l parts (string split ':' "$line")
        printf "  Network: %s\n" $parts[1]
        printf "  Device: %s\n" $parts[3]
    end
end

function list --description "List available WiFi networks"
    if contains -- "$argv[1]" --help -h
        printf "List all available WiFi networks\n"
        printf "\n"
        printf "Usage: fedpunk wifi list [--rescan]\n"
        printf "\n"
        printf "Options:\n"
        printf "  --rescan    Trigger a new scan before listing\n"
        return 0
    end

    _require_nmcli; or return 1

    # Rescan if requested
    if contains -- "--rescan" $argv
        printf "Scanning for networks...\n"
        nmcli device wifi rescan 2>/dev/null
        sleep 2
    end

    nmcli -f SSID,SIGNAL,SECURITY device wifi list
end

function scan --description "Scan for WiFi networks"
    if contains -- "$argv[1]" --help -h
        printf "Scan for available WiFi networks\n"
        printf "\n"
        printf "Usage: fedpunk wifi scan\n"
        return 0
    end

    _require_nmcli; or return 1

    printf "Scanning for WiFi networks...\n"
    nmcli device wifi rescan 2>/dev/null
    sleep 2

    printf "Scan complete\n\n"
    nmcli -f SSID,SIGNAL,SECURITY device wifi list
end

function connect --description "Connect to a WiFi network"
    if contains -- "$argv[1]" --help -h
        printf "Connect to a WiFi network\n"
        printf "\n"
        printf "Usage: fedpunk wifi connect [SSID] [--password PASSWORD]\n"
        printf "\n"
        printf "If no SSID provided, shows interactive selector.\n"
        printf "If network requires password and none provided, will prompt.\n"
        return 0
    end

    _require_nmcli; or return 1

    set -l ssid ""
    set -l password ""

    # Parse arguments
    set -l i 1
    while test $i -le (count $argv)
        switch $argv[$i]
            case --password
                set i (math $i + 1)
                set password $argv[$i]
            case -*
                # Skip unknown flags
            case '*'
                if test -z "$ssid"
                    set ssid $argv[$i]
                end
        end
        set i (math $i + 1)
    end

    # If no SSID provided, show interactive selector
    if test -z "$ssid"
        # Rescan for fresh results
        printf "Scanning for networks...\n"
        nmcli device wifi rescan 2>/dev/null
        sleep 2

        # Get list of networks with signal and security
        set -l networks (nmcli -t -f SSID,SIGNAL,SECURITY device wifi list | string match -r '.+')

        if test -z "$networks"
            printf "Error: No WiFi networks found\n" >&2
            return 1
        end

        # Format networks for display: "SSID (Signal%)"
        set -l formatted_networks
        for network in $networks
            set -l parts (string split ':' "$network")
            set -l network_ssid $parts[1]
            set -l signal $parts[2]
            set -l security $parts[3]

            # Skip empty SSIDs
            if test -z "$network_ssid"
                continue
            end

            # Build display string
            set -l security_indicator ""
            if test -n "$security"
                set security_indicator " [secured]"
            end

            set -a formatted_networks "$network_ssid ($signal%)$security_indicator"
        end

        # Remove duplicates (same SSID may appear multiple times from different APs)
        set formatted_networks (printf "%s\n" $formatted_networks | sort -u)

        # Show selector
        set -l selection (ui-choose --header "Select WiFi network:" $formatted_networks)
        or return 1

        # Extract SSID from selection (format: "SSID (Signal%)")
        set ssid (string match -r '^[^(]+' "$selection" | string trim)
    end

    if test -z "$ssid"
        printf "Error: No network selected\n" >&2
        return 1
    end

    # Check if network is already saved
    set -l saved_connection (nmcli -t -f NAME connection show | string match -e "$ssid")

    if test -n "$saved_connection"
        # Connection exists, just activate it
        printf "Connecting to $ssid...\n"
        if nmcli connection up "$ssid"
            printf "Connected to $ssid\n"
            return 0
        else
            printf "Error: Failed to connect to $ssid\n" >&2
            return 1
        end
    end

    # New network - check if it requires a password
    set -l network_info (nmcli -t -f SSID,SECURITY device wifi list | string match -r "^$ssid:")
    set -l security (echo $network_info | string split ':' | tail -1)

    if test -n "$security" -a -z "$password"
        # Network is secured, prompt for password
        set password (ui-input --placeholder "Enter password for $ssid")
        if test -z "$password"
            printf "Error: Password required for secured network\n" >&2
            return 1
        end
    end

    # Connect to the network
    printf "Connecting to $ssid...\n"
    if test -n "$password"
        if nmcli device wifi connect "$ssid" password "$password"
            printf "Connected to $ssid\n"
            return 0
        else
            printf "Error: Failed to connect to $ssid\n" >&2
            return 1
        end
    else
        if nmcli device wifi connect "$ssid"
            printf "Connected to $ssid\n"
            return 0
        else
            printf "Error: Failed to connect to $ssid\n" >&2
            return 1
        end
    end
end

function disconnect --description "Disconnect from current WiFi network"
    if contains -- "$argv[1]" --help -h
        printf "Disconnect from current WiFi network\n"
        printf "\n"
        printf "Usage: fedpunk wifi disconnect\n"
        return 0
    end

    _require_nmcli; or return 1

    # Get current WiFi connection
    set -l current (nmcli -t -f NAME,TYPE connection show --active | string match -r '.*:802-11-wireless' | string split ':' | head -1)

    if test -z "$current"
        printf "No active WiFi connection\n"
        return 0
    end

    printf "Disconnecting from $current...\n"
    if nmcli connection down "$current"
        printf "Disconnected from $current\n"
    else
        printf "Error: Failed to disconnect\n" >&2
        return 1
    end
end

function saved --description "List saved WiFi networks"
    if contains -- "$argv[1]" --help -h
        printf "List all saved WiFi network connections\n"
        printf "\n"
        printf "Usage: fedpunk wifi saved\n"
        return 0
    end

    _require_nmcli; or return 1
    nmcli -f NAME,TYPE connection show | string match -r '.*802-11-wireless'
end

function forget --description "Forget a saved WiFi network"
    if contains -- "$argv[1]" --help -h
        printf "Remove a saved WiFi network connection\n"
        printf "\n"
        printf "Usage: fedpunk wifi forget [SSID]\n"
        printf "\n"
        printf "If no SSID provided, shows interactive selector.\n"
        return 0
    end

    _require_nmcli; or return 1

    set -l ssid $argv[1]

    if test -z "$ssid"
        # Get list of saved WiFi connections
        set -l saved (nmcli -t -f NAME,TYPE connection show | string match -r '.*:802-11-wireless' | string split ':' | string match -v -r '^$')

        if test -z "$saved"
            printf "No saved WiFi networks\n"
            return 0
        end

        # Show selector
        set ssid (ui-choose --header "Select network to forget:" $saved)
        or return 1
    end

    if test -z "$ssid"
        printf "Error: No network selected\n" >&2
        return 1
    end

    # Confirm before deleting
    if ui-confirm "Forget network '$ssid'?"
        if nmcli connection delete "$ssid"
            printf "Forgot network $ssid\n"
        else
            printf "Error: Failed to forget network $ssid\n" >&2
            return 1
        end
    else
        printf "Cancelled\n"
    end
end
