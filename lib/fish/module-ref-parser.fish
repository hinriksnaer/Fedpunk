#!/usr/bin/env fish
# Module reference parser - handles simple names, paths, URLs, and objects with params
# Parses module references from mode.yaml

function module-ref-parse
    # Parse a module reference (can be string or object with params)
    # Usage: module-ref-parse <yaml-file> <index>
    # Returns: module_url or module_name on one line, then params as KEY=VALUE pairs
    set -l yaml_file $argv[1]
    set -l index $argv[2]

    if not test -f "$yaml_file"
        echo "Error: YAML file not found: $yaml_file" >&2
        return 1
    end

    # Check if yq is available
    if not command -v yq >/dev/null 2>&1
        echo "Error: yq command not found" >&2
        return 1
    end

    # Get the module reference at the given index
    set -l ref_type (yq eval ".modules[$index] | type" "$yaml_file" 2>/dev/null)

    switch "$ref_type"
        case "!!str"
            # Simple string reference (e.g., "essentials" or "https://...")
            set -l module_ref (yq eval ".modules[$index]" "$yaml_file" 2>/dev/null)
            echo "$module_ref"
            return 0

        case "!!map"
            # Object with module and params
            set -l module_ref (yq eval ".modules[$index].module" "$yaml_file" 2>/dev/null)
            if test "$module_ref" = "null" -o -z "$module_ref"
                echo "Error: Object reference missing 'module' key at index $index" >&2
                return 1
            end

            # Output module reference first
            echo "$module_ref"

            # Then output parameters as KEY=VALUE pairs
            set -l param_keys (yq eval ".modules[$index].params | keys | .[]" "$yaml_file" 2>/dev/null)
            for key in $param_keys
                set -l value (yq eval ".modules[$index].params.$key" "$yaml_file" 2>/dev/null)
                echo "$key=$value"
            end
            return 0

        case "!!null" "null"
            echo "Error: Module reference at index $index is null" >&2
            return 1

        case "*"
            echo "Error: Unsupported module reference type: $ref_type" >&2
            return 1
    end
end

function module-ref-is-url
    # Check if a module reference is a URL
    # Usage: module-ref-is-url <module-ref>
    set -l module_ref $argv[1]

    string match -qr '^(https?://|git@)' "$module_ref"
end

function module-ref-is-path
    # Check if a module reference is a path (contains /)
    # Usage: module-ref-is-path <module-ref>
    set -l module_ref $argv[1]

    # Is path if contains / but is not a URL
    if string match -q '*/*' "$module_ref"
        and not module-ref-is-url "$module_ref"
        return 0
    end
    return 1
end

function module-ref-extract-name
    # Extract module name from a reference
    # Usage: module-ref-extract-name <module-ref>
    set -l module_ref $argv[1]

    if module-ref-is-url "$module_ref"
        # Extract from URL: https://github.com/org/repo.git -> repo
        # Remove .git suffix and get last path component
        set -l name (string replace -r '\.git$' '' "$module_ref" | string split '/' | tail -n1)
        echo "$name"
    else if module-ref-is-path "$module_ref"
        # Extract from path: plugins/neovim-custom -> neovim-custom
        echo (basename "$module_ref")
    else
        # Simple name
        echo "$module_ref"
    end
end

function module-ref-list-all
    # List all module references from a mode.yaml file
    # Usage: module-ref-list-all <yaml-file>
    # Returns: One module reference per line (just the module name/url, no params)
    set -l yaml_file $argv[1]

    if not test -f "$yaml_file"
        echo "Error: YAML file not found: $yaml_file" >&2
        return 1
    end

    # Get count of modules
    set -l count (yq eval '.modules | length' "$yaml_file" 2>/dev/null)

    if test "$count" = "0" -o "$count" = "null"
        return 0
    end

    # Iterate through each module
    for i in (seq 0 (math $count - 1))
        # Parse and output just the first line (module reference)
        module-ref-parse "$yaml_file" $i | head -n1
    end
end
