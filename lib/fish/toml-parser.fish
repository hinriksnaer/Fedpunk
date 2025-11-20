#!/usr/bin/env fish
# Simple TOML parser for fedpunk module system
# Handles basic TOML parsing needed for module.toml and mode files

function toml-get-value
    # Get a simple value from TOML
    # Usage: toml-get-value <file> <section> <key>
    set -l file $argv[1]
    set -l section $argv[2]
    set -l key $argv[3]

    if not test -f "$file"
        return 1
    end

    # Use awk to parse TOML
    awk -v section="$section" -v key="$key" '
        BEGIN { in_section = 0 }

        # Track current section
        /^\[.*\]/ {
            current_section = $0
            gsub(/^\[/, "", current_section)
            gsub(/\].*$/, "", current_section)
            in_section = (current_section == section)
            next
        }

        # Skip comments and empty lines
        /^[[:space:]]*#/ { next }
        /^[[:space:]]*$/ { next }

        # Parse key = value in our section
        in_section && $0 ~ "^[[:space:]]*"key"[[:space:]]*=" {
            # Extract value after =
            sub(/^[^=]*=[[:space:]]*/, "")
            # Remove quotes if present
            gsub(/^"/, "")
            gsub(/"[[:space:]]*$/, "")
            # Remove trailing comments
            gsub(/[[:space:]]*#.*$/, "")
            print
            exit
        }
    ' "$file"
end

function toml-get-array
    # Get array values from TOML
    # Usage: toml-get-array <file> <section> <key>
    # Returns one value per line
    set -l file $argv[1]
    set -l section $argv[2]
    set -l key $argv[3]

    if not test -f "$file"
        return 1
    end

    # Use awk to parse TOML array
    awk -v section="$section" -v key="$key" '
        BEGIN { in_section = 0; in_array = 0 }

        # Track current section
        /^\[.*\]/ {
            current_section = $0
            gsub(/^\[/, "", current_section)
            gsub(/\].*$/, "", current_section)
            in_section = (current_section == section)
            in_array = 0
            next
        }

        # Skip comments and empty lines
        /^[[:space:]]*#/ { next }
        /^[[:space:]]*$/ { next }

        # Start of array
        in_section && !in_array && $0 ~ "^[[:space:]]*"key"[[:space:]]*=" {
            in_array = 1
            line = $0
            # Remove key =
            sub(/^[^=]*=[[:space:]]*/, "", line)

            # Check if single-line array
            if (line ~ /\[.*\]/) {
                # Single line array
                gsub(/\[/, "", line)
                gsub(/\].*$/, "", line)
                # Split by comma
                split(line, items, /[[:space:]]*,[[:space:]]*/)
                for (i in items) {
                    item = items[i]
                    gsub(/^[[:space:]]*"/, "", item)
                    gsub(/"[[:space:]]*$/, "", item)
                    gsub(/^[[:space:]]+/, "", item)
                    gsub(/[[:space:]]+$/, "", item)
                    if (item != "") print item
                }
                exit
            }

            # Multi-line array - remove opening bracket
            gsub(/\[/, "", line)

            # Process first line if it has values
            if (line !~ /^[[:space:]]*$/) {
                gsub(/^[[:space:]]*"/, "", line)
                gsub(/"[[:space:]]*,.*$/, "", line)
                gsub(/^[[:space:]]+/, "", line)
                gsub(/[[:space:]]+$/, "", line)
                if (line != "") print line
            }
            next
        }

        # Inside multi-line array
        in_array {
            # Check for end of array
            if ($0 ~ /\]/) {
                in_array = 0
                # Process last line before ]
                line = $0
                gsub(/\].*$/, "", line)
                gsub(/^[[:space:]]*"/, "", line)
                gsub(/"[[:space:]]*,.*$/, "", line)
                gsub(/"[[:space:]]*$/, "", line)
                gsub(/^[[:space:]]+/, "", line)
                gsub(/[[:space:]]+$/, "", line)
                if (line != "") print line
                exit
            }

            # Regular array item
            line = $0
            gsub(/^[[:space:]]*"/, "", line)
            gsub(/"[[:space:]]*,.*$/, "", line)
            gsub(/"[[:space:]]*$/, "", line)
            gsub(/^[[:space:]]+/, "", line)
            gsub(/[[:space:]]+$/, "", line)
            if (line != "") print line
        }
    ' "$file"
end

function toml-get-bool
    # Get boolean value (returns "true" or "false")
    # Usage: toml-get-bool <file> <section> <key>
    set -l value (toml-get-value $argv)

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

function toml-section-exists
    # Check if a section exists in TOML file
    # Usage: toml-section-exists <file> <section>
    set -l file $argv[1]
    set -l section $argv[2]

    if not test -f "$file"
        return 1
    end

    grep -q "^\[$section\]" "$file"
end

function toml-list-sections
    # List all sections in TOML file
    # Usage: toml-list-sections <file>
    set -l file $argv[1]

    if not test -f "$file"
        return 1
    end

    grep '^\[' "$file" | sed 's/^\[\(.*\)\]$/\1/'
end
