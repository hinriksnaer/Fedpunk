# Bluetooth management commands

function bluetooth --description "Bluetooth management"
    if contains -- "$argv[1]" --help -h
        printf "Bluetooth device management\n"
        printf "\n"
        printf "Control Bluetooth devices and connections.\n"
        return 0
    end
    _show_command_help bluetooth
end

# Check if bluetoothctl is available
function _require_bt
    if not command -v bluetoothctl >/dev/null 2>&1
        printf "Error: bluetoothctl not installed\n" >&2
        printf "Run: fedpunk module deploy bluetooth\n" >&2
        return 1
    end
    return 0
end

function on --description "Power on Bluetooth"
    if contains -- "$argv[1]" --help -h
        printf "Power on Bluetooth adapter\n"
        printf "\n"
        printf "Usage: fedpunk bluetooth on\n"
        return 0
    end

    _require_bt; or return 1
    bluetoothctl power on
end

function off --description "Power off Bluetooth"
    if contains -- "$argv[1]" --help -h
        printf "Power off Bluetooth adapter\n"
        printf "\n"
        printf "Usage: fedpunk bluetooth off\n"
        return 0
    end

    _require_bt; or return 1
    bluetoothctl power off
end

function devices --description "List paired devices"
    if contains -- "$argv[1]" --help -h
        printf "List all paired Bluetooth devices\n"
        printf "\n"
        printf "Usage: fedpunk bluetooth devices\n"
        return 0
    end

    _require_bt; or return 1
    bluetoothctl devices
end

function scan --description "Scan for devices"
    if contains -- "$argv[1]" --help -h
        printf "Scan for nearby Bluetooth devices\n"
        printf "\n"
        printf "Usage: fedpunk bluetooth scan\n"
        printf "\n"
        printf "Press Ctrl+C to stop scanning.\n"
        return 0
    end

    _require_bt; or return 1
    printf "Scanning for Bluetooth devices (Ctrl+C to stop)...\n"
    bluetoothctl --timeout 30 scan on
end

function pair --description "Pair with a device"
    if contains -- "$argv[1]" --help -h
        printf "Pair with a Bluetooth device\n"
        printf "\n"
        printf "Usage: fedpunk bluetooth pair <MAC address>\n"
        printf "\n"
        printf "Get MAC address from 'fedpunk bluetooth scan'\n"
        return 0
    end

    set -l mac $argv[1]
    if test -z "$mac"
        printf "Error: MAC address required\n" >&2
        printf "Usage: fedpunk bluetooth pair <MAC address>\n" >&2
        printf "\nRun 'fedpunk bluetooth scan' to find devices\n" >&2
        return 1
    end

    _require_bt; or return 1
    bluetoothctl pair $mac
end

function connect --description "Connect to a device"
    if contains -- "$argv[1]" --help -h
        printf "Connect to a paired Bluetooth device\n"
        printf "\n"
        printf "Usage: fedpunk bluetooth connect [MAC address]\n"
        printf "\n"
        printf "If no MAC provided, shows interactive selector.\n"
        return 0
    end

    _require_bt; or return 1

    set -l mac $argv[1]
    if test -z "$mac"
        # Get list of paired devices
        set -l paired_devices (bluetoothctl devices | string match -r '.+')
        if test -z "$paired_devices"
            printf "No paired devices found\n" >&2
            printf "Run 'fedpunk bluetooth pair <MAC>' first\n" >&2
            return 1
        end

        # Smart select
        set mac (ui-select-smart \
            --header "Select device to connect:" \
            --options $paired_devices)
        or return 1

        # Extract MAC from selection (format: "Device XX:XX:XX:XX:XX:XX Name")
        set mac (string match -r '[0-9A-F:]{17}' "$mac")
    end

    bluetoothctl connect $mac
end

function disconnect --description "Disconnect from a device"
    if contains -- "$argv[1]" --help -h
        printf "Disconnect from a Bluetooth device\n"
        printf "\n"
        printf "Usage: fedpunk bluetooth disconnect [MAC address]\n"
        printf "\n"
        printf "If no MAC provided, shows interactive selector.\n"
        return 0
    end

    _require_bt; or return 1

    set -l mac $argv[1]
    if test -z "$mac"
        # Get list of paired devices
        set -l paired_devices (bluetoothctl devices | string match -r '.+')
        if test -z "$paired_devices"
            printf "No paired devices found\n" >&2
            return 1
        end

        set mac (ui-select-smart \
            --header "Select device to disconnect:" \
            --options $paired_devices)
        or return 1

        set mac (string match -r '[0-9A-F:]{17}' "$mac")
    end

    bluetoothctl disconnect $mac
end

function trust --description "Trust a device"
    if contains -- "$argv[1]" --help -h
        printf "Trust a Bluetooth device for auto-connect\n"
        printf "\n"
        printf "Usage: fedpunk bluetooth trust <MAC address>\n"
        return 0
    end

    set -l mac $argv[1]
    if test -z "$mac"
        printf "Error: MAC address required\n" >&2
        printf "Usage: fedpunk bluetooth trust <MAC address>\n" >&2
        return 1
    end

    _require_bt; or return 1
    bluetoothctl trust $mac
end

function remove --description "Remove a paired device"
    if contains -- "$argv[1]" --help -h
        printf "Remove/unpair a Bluetooth device\n"
        printf "\n"
        printf "Usage: fedpunk bluetooth remove <MAC address>\n"
        return 0
    end

    set -l mac $argv[1]
    if test -z "$mac"
        printf "Error: MAC address required\n" >&2
        printf "Usage: fedpunk bluetooth remove <MAC address>\n" >&2
        return 1
    end

    _require_bt; or return 1
    bluetoothctl remove $mac
end

function info --description "Show device info"
    if contains -- "$argv[1]" --help -h
        printf "Show information about a Bluetooth device\n"
        printf "\n"
        printf "Usage: fedpunk bluetooth info <MAC address>\n"
        return 0
    end

    set -l mac $argv[1]
    if test -z "$mac"
        printf "Error: MAC address required\n" >&2
        printf "Usage: fedpunk bluetooth info <MAC address>\n" >&2
        return 1
    end

    _require_bt; or return 1
    bluetoothctl info $mac
end

function gui --description "Open Bluetooth GUI manager"
    if contains -- "$argv[1]" --help -h
        printf "Open blueman GUI for Bluetooth management\n"
        printf "\n"
        printf "Usage: fedpunk bluetooth gui\n"
        return 0
    end

    if not command -v blueman-manager >/dev/null 2>&1
        printf "Error: blueman not installed\n" >&2
        printf "Run: fedpunk module deploy bluetooth\n" >&2
        return 1
    end

    blueman-manager &
    disown
    printf "Launched Bluetooth Manager (blueman)\n"
end
