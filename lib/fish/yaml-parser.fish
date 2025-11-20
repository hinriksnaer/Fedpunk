#!/usr/bin/env fish
# Simple YAML parser for fedpunk module system using yq
# Handles basic YAML parsing needed for module.yaml and mode files

function yaml-get-value
    # Get a simple value from YAML
    # Usage: yaml-get-value <file> <section> <key>
    set -l file $argv[1]
    set -l section $argv[2]
    set -l key $argv[3]

    if not test -f "$file"
        return 1
    end

    # Build yq path
    set -l path ".$section.$key"

    # Use yq to get the value
    set -l value (yq -r "$path // empty" "$file" 2>/dev/null)

    # Only output if value exists and is not null
    if test -n "$value" -a "$value" != "null"
        echo $value
    end
end

function yaml-get-array
    # Get array values from YAML using a yq path
    # Usage: yaml-get-array <file> <path>
    # Path should be in yq format (e.g., ".section.key[]")
    set -l file $argv[1]
    set -l path $argv[2]

    if not test -f "$file"
        return 1
    end

    # Use yq to get array values, one per line
    yq -r "$path // empty" "$file" 2>/dev/null | grep -v '^$'
end

function yaml-get-list
    # Get array/list values from YAML
    # Usage: yaml-get-list <file> <section> <key>
    # Returns one value per line
    set -l file $argv[1]
    set -l section $argv[2]
    set -l key $argv[3]

    if not test -f "$file"
        return 1
    end

    # Build yq path for array access
    set -l path ".$section.$key\[]"

    # Use yaml-get-array to get the values
    yaml-get-array "$file" "$path"
end

function yaml-get-bool
    # Get boolean value (returns "true" or "false")
    # Usage: yaml-get-bool <file> <section> <key>
    set -l value (yaml-get-value $argv)

    # Normalize boolean
    switch "$value"
        case "true" "True" "TRUE" "yes" "Yes" "YES" "1"
            echo "true"
        case "false" "False" "FALSE" "no" "No" "NO" "0"
            echo "false"
        case "*"
            echo "false"
    end
end

function yaml-section-exists
    # Check if a section exists in YAML file
    # Usage: yaml-section-exists <file> <section>
    set -l file $argv[1]
    set -l section $argv[2]

    if not test -f "$file"
        return 1
    end

    # Check if section exists and is not null
    set -l result (yq -r ".$section // empty" "$file" 2>/dev/null)
    test -n "$result" -a "$result" != "null"
end

function yaml-list-sections
    # List all top-level sections in YAML file
    # Usage: yaml-list-sections <file>
    set -l file $argv[1]

    if not test -f "$file"
        return 1
    end

    # Get all top-level keys
    yq -r 'keys | .[]' "$file" 2>/dev/null
end
