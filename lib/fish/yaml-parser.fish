#!/usr/bin/env fish
# YAML parser for Fedpunk modules
# Uses yq for parsing YAML files

# Get a simple value from YAML
# Usage: yaml-get-value <file> <section> <key>
# Example: yaml-get-value module.yaml "module" "name"
function yaml-get-value
    set -l file $argv[1]
    set -l section $argv[2]
    set -l key $argv[3]

    if not test -f "$file"
        return 1
    end

    # Build path: .section.key
    set -l path ".$section.$key"

    # Use yq to get value, suppress errors
    set -l value (yq -r "$path // empty" "$file" 2>/dev/null)

    if test -n "$value" -a "$value" != "null"
        echo $value
    end
end

# Get an array from YAML
# Usage: yaml-get-array <file> <path>
# Example: yaml-get-array module.yaml ".packages.dnf[]"
function yaml-get-array
    set -l file $argv[1]
    set -l path $argv[2]

    if not test -f "$file"
        return 1
    end

    # Use yq to get array values, one per line
    set -l values (yq -r "$path // empty" "$file" 2>/dev/null | string trim)

    if test -n "$values"
        echo $values
    end
end

# Get array with specific path format
# Usage: yaml-get-list <file> <section> <key>
# Example: yaml-get-list module.yaml "packages" "dnf"
# Translates to: .packages.dnf[]
function yaml-get-list
    set -l file $argv[1]
    set -l section $argv[2]
    set -l key $argv[3]

    if not test -f "$file"
        return 1
    end

    set -l path ".$section.$key\[]"
    yaml-get-array "$file" "$path"
end

# Check if yq is installed
function yaml-check-dependencies
    if not command -v yq >/dev/null 2>&1
        echo "Error: yq is required for YAML parsing" >&2
        echo "Install with: sudo dnf install yq" >&2
        return 1
    end
end
