#!/usr/bin/env fish
# Fedpunk configuration file management
# Handles reading/writing ~/.config/fedpunk/fedpunk.yaml

function fedpunk-config-path
    # Returns the path to the fedpunk config file
    echo "$HOME/.config/fedpunk/fedpunk.yaml"
end

function fedpunk-config-exists
    # Check if config file exists
    # Returns: 0 if exists, 1 if not
    test -f (fedpunk-config-path)
end

function fedpunk-config-get
    # Get a value from the config file
    # Usage: fedpunk-config-get <key>
    # Example: fedpunk-config-get profile
    # Returns: value if exists and not null, empty otherwise
    # Exit code: 0 if found, 1 if not found or null

    set -l key $argv[1]

    if test -z "$key"
        echo "Error: key required" >&2
        return 1
    end

    if not fedpunk-config-exists
        return 1
    end

    set -l config_file (fedpunk-config-path)
    set -l value (yq ".$key" "$config_file" 2>/dev/null)

    if test -n "$value" -a "$value" != "null"
        echo $value
        return 0
    end

    return 1
end

function fedpunk-config-set
    # Set a value in the config file
    # Usage: fedpunk-config-set <key> <value>
    # Creates config file if it doesn't exist

    set -l key $argv[1]
    set -l value $argv[2]

    if test -z "$key"
        echo "Error: key required" >&2
        return 1
    end

    if test -z "$value"
        echo "Error: value required" >&2
        return 1
    end

    if not fedpunk-config-exists
        fedpunk-config-init
    end

    set -l config_file (fedpunk-config-path)
    yq -i ".$key = \"$value\"" "$config_file"
end

function fedpunk-config-init
    # Initialize config file with null values
    # Creates directory structure if needed

    set -l config_file (fedpunk-config-path)
    set -l config_dir (dirname "$config_file")

    # Ensure directory exists
    if not test -d "$config_dir"
        mkdir -p "$config_dir"
        mkdir -p "$config_dir/profiles"
    end

    # Create initial config with null values
    echo "# Fedpunk Configuration
# Auto-generated on "(date)

"profile: null
mode: null
modules:
  enabled: []
  disabled: []
params: {}
last_deployed: null" > "$config_file"
end

function fedpunk-config-update-metadata
    # Update the last_deployed timestamp
    # Usage: fedpunk-config-update-metadata

    if not fedpunk-config-exists
        fedpunk-config-init
    end

    set -l config_file (fedpunk-config-path)
    set -l timestamp (date -Iseconds)

    yq -i ".last_deployed = \"$timestamp\"" "$config_file"
end
