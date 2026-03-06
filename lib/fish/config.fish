#!/usr/bin/env fish
# Fedpunk configuration file management
# Handles reading/writing ~/.config/fedpunk/fedpunk.yaml

# Source yq utilities for clean environment execution
set -l lib_dir (dirname (status -f))
source "$lib_dir/yq-utils.fish"

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
    set -l value (_yq_safe ".$key" "$config_file" 2>/dev/null)

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
    #
    # Checks for duplicates in:
    # 1. modules.enabled in fedpunk.yaml
    # 2. Profile's mode.yaml modules (if profile is configured)

    set -l module_name $argv[1]

    if test -z "$module_name"
        echo "Error: Module name required" >&2
        return 1
    end

    if not fedpunk-config-exists
        fedpunk-config-init
    end

    set -l config_file (fedpunk-config-path)

    # Check if module is already in enabled list (handles both string and object formats)
    set -l current_modules (fedpunk-config-list-enabled-modules 2>/dev/null)
    if test -n "$current_modules"
        if contains -- $module_name $current_modules
            # Already enabled, nothing to do
            return 0
        end
    end

    # Check if module is part of the active profile's mode.yaml
    set -l profile_modules (fedpunk-config-list-profile-modules 2>/dev/null)
    if test -n "$profile_modules"
        if contains -- $module_name $profile_modules
            # Already part of profile, nothing to add
            return 0
        end
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
    set -l has_sources (_yq_safe '.sources' "$config_file" 2>/dev/null)
    if test -z "$has_sources" -o "$has_sources" = "null"
        yq -i '.sources = []' "$config_file"
    end

    # Check if source is already in list
    set -l current_sources (_yq_safe '.sources[]' "$config_file" 2>/dev/null)
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
    _yq_safe '.sources[]' "$config_file" 2>/dev/null
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
    set -l count (_yq_safe '.modules.enabled | length' "$config_file" 2>/dev/null)

    if test -z "$count" -o "$count" = "null" -o "$count" = "0"
        return 1
    end

    # Parse each entry - could be string or object
    set -l i 0
    while test $i -lt $count
        # Check if it's an object (has .module key)
        set -l ref_type (_yq_safe ".modules.enabled[$i] | type" "$config_file" 2>/dev/null)

        if test "$ref_type" = "!!map"
            # It's an object, get the .module field
            _yq_safe ".modules.enabled[$i].module" "$config_file" 2>/dev/null
        else
            # It's a simple string
            _yq_safe ".modules.enabled[$i]" "$config_file" 2>/dev/null
        end

        set i (math $i + 1)
    end
end

function fedpunk-config-list-profile-modules
    # List module names from the active profile's mode.yaml
    # Returns: module names (one per line)

    if not fedpunk-config-exists
        return 1
    end

    set -l profile (fedpunk-config-get profile 2>/dev/null)
    set -l mode (fedpunk-config-get mode 2>/dev/null)

    if test -z "$profile" -o "$profile" = "null" -o -z "$mode" -o "$mode" = "null"
        return 1
    end

    # Find profile directory
    set -l profile_dir ""
    for search_path in "$HOME/.config/fedpunk/profiles" "$FEDPUNK_USER/profiles" "$FEDPUNK_SYSTEM/profiles"
        if test -d "$search_path/$profile"
            set profile_dir "$search_path/$profile"
            break
        end
    end

    if test -z "$profile_dir"
        return 1
    end

    set -l mode_file "$profile_dir/modes/$mode/mode.yaml"
    if not test -f "$mode_file"
        return 1
    end

    # Extract module names (handles both string and object formats)
    for m in (_yq_safe '.modules[]' "$mode_file" 2>/dev/null)
        if string match -q '{*' "$m"
            # Object format - extract module field
            echo "$m" | yq '.module' 2>/dev/null
        else if test -n "$m" -a "$m" != "null"
            echo "$m"
        end
    end
end
