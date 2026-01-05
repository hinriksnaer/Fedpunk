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
        mkdir -p "$config_dir/sources"
        mkdir -p "$config_dir/modules"
    end

    # Create initial config with null values
    printf "# Fedpunk Configuration\n" > "$config_file"
    printf "# Auto-generated on %s\n\n" (date) >> "$config_file"
    printf "profile: null\n" >> "$config_file"
    printf "mode: null\n" >> "$config_file"
    printf "sources: []\n" >> "$config_file"
    printf "modules:\n" >> "$config_file"
    printf "  enabled: []\n" >> "$config_file"
    printf "  disabled: []\n" >> "$config_file"
    printf "params: {}\n" >> "$config_file"
    printf "last_deployed: null\n" >> "$config_file"
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

function fedpunk-config-add-module
    # Add a module to the enabled list
    # Usage: fedpunk-config-add-module <module-name>

    set -l module_name $argv[1]

    if test -z "$module_name"
        echo "Error: Module name required" >&2
        return 1
    end

    if not fedpunk-config-exists
        fedpunk-config-init
    end

    set -l config_file (fedpunk-config-path)

    # Check if module is already in enabled list
    set -l current_modules (yq '.modules.enabled[]' "$config_file" 2>/dev/null)
    if contains $module_name $current_modules
        # Already enabled, nothing to do
        return 0
    end

    # Add to enabled modules list
    yq -i ".modules.enabled += [\"$module_name\"]" "$config_file"
end

function fedpunk-config-add-source
    # Add a git URL to the sources list
    # Usage: fedpunk-config-add-source <git-url>
    #
    # Sources can be:
    #   - Single module repo: git@gitlab.com:org/module.git (has module.yaml at root)
    #   - Multi-module repo: git@gitlab.com:org/modules (has subdirs with module.yaml)

    set -l source_url $argv[1]

    if test -z "$source_url"
        echo "Error: Source URL required" >&2
        return 1
    end

    if not fedpunk-config-exists
        fedpunk-config-init
    end

    set -l config_file (fedpunk-config-path)

    # Ensure sources array exists
    set -l has_sources (yq '.sources' "$config_file" 2>/dev/null)
    if test -z "$has_sources" -o "$has_sources" = "null"
        yq -i '.sources = []' "$config_file"
    end

    # Check if source is already in list
    set -l current_sources (yq '.sources[]' "$config_file" 2>/dev/null)
    if contains "$source_url" $current_sources
        # Already added
        return 0
    end

    # Add to sources list
    yq -i ".sources += [\"$source_url\"]" "$config_file"
end

function fedpunk-config-list-sources
    # List all configured sources
    # Usage: fedpunk-config-list-sources

    if not fedpunk-config-exists
        return 1
    end

    set -l config_file (fedpunk-config-path)
    yq '.sources[]' "$config_file" 2>/dev/null
end

function fedpunk-config-list-enabled-modules
    # List all enabled module names/URLs from config (without params)
    # Usage: fedpunk-config-list-enabled-modules
    # Returns: List of module references (one per line), just names/URLs
    # Params are handled separately by param-generate-fish-config
    #
    # Example output:
    #   neovim
    #   tmux
    #   https://github.com/org/module.git

    if not fedpunk-config-exists
        return 1
    end

    set -l config_file (fedpunk-config-path)

    # Get count of enabled modules
    set -l count (yq '.modules.enabled | length' "$config_file" 2>/dev/null)

    if test -z "$count" -o "$count" = "null" -o "$count" = "0"
        return 1
    end

    # Parse each entry - could be string or object
    set -l i 0
    while test $i -lt $count
        # Check if it's an object (has .module key)
        set -l ref_type (yq ".modules.enabled[$i] | type" "$config_file" 2>/dev/null)

        if test "$ref_type" = "!!map"
            # It's an object, get the .module field
            yq ".modules.enabled[$i].module" "$config_file" 2>/dev/null
        else
            # It's a simple string
            yq ".modules.enabled[$i]" "$config_file" 2>/dev/null
        end

        set i (math $i + 1)
    end
end
