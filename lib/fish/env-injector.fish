#!/usr/bin/env fish
# Environment variable injection system - generates Fish config with module/user environment variables

# Source dependencies
set -l lib_dir (dirname (status -f))
source "$lib_dir/yq-utils.fish"
source "$lib_dir/module-ref-parser.fish"
source "$lib_dir/module-resolver.fish"
source "$lib_dir/yaml-parser.fish"

function env-get-module-environment
    # Get environment key-value pairs from a module.yaml
    # Usage: env-get-module-environment <module-yaml-path>
    # Returns: KEY=VALUE pairs, one per line

    set -l yaml_file $argv[1]

    if not test -f "$yaml_file"
        return 1
    end

    # Check if environment section exists
    set -l has_env (_yq_safe '.environment // null' "$yaml_file" 2>/dev/null)
    if test -z "$has_env" -o "$has_env" = "null"
        return 0  # No environment section
    end

    # Get all keys from environment section
    set -l env_keys (_yq_safe '.environment | keys | .[]' "$yaml_file" 2>/dev/null)

    for key in $env_keys
        set -l value (_yq_safe ".environment.$key" "$yaml_file" 2>/dev/null)
        if test -n "$value" -a "$value" != "null"
            echo "$key=$value"
        end
    end
end

function env-get-user-environment
    # Get environment key-value pairs from fedpunk.yaml
    # Usage: env-get-user-environment [yaml-path]
    # Returns: KEY=VALUE pairs, one per line

    set -l yaml_path $argv[1]

    if test -z "$yaml_path"
        set yaml_path "$HOME/.config/fedpunk/fedpunk.yaml"
    end

    if not test -f "$yaml_path"
        return 1
    end

    # Check if environment section exists
    set -l has_env (_yq_safe '.environment // null' "$yaml_path" 2>/dev/null)
    if test -z "$has_env" -o "$has_env" = "null"
        return 0
    end

    # Get all keys from environment section
    set -l env_keys (_yq_safe '.environment | keys | .[]' "$yaml_path" 2>/dev/null)

    for key in $env_keys
        set -l value (_yq_safe ".environment.$key" "$yaml_path" 2>/dev/null)
        if test -n "$value" -a "$value" != "null"
            echo "$key=$value"
        end
    end
end

function env-generate-fish-config
    # Generate environment config files for both Fish and Bash
    # Usage: env-generate-fish-config [yaml-path]
    # If no path provided, reads from fedpunk.yaml
    #
    # Precedence (later overrides earlier):
    # 1. Module-defined environment variables
    # 2. User-defined environment variables (fedpunk.yaml)
    #
    # Generates:
    # - ~/.config/fish/conf.d/fedpunk-module-env.fish (user fish config)
    # - ~/.config/fedpunk/profile.d/fedpunk-env.sh (user bash/sh config - source from .bashrc)

    set -l yaml_path $argv[1]
    set -l fish_config "$HOME/.config/fish/conf.d/fedpunk-module-env.fish"
    set -l bash_config "$HOME/.config/fedpunk/profile.d/fedpunk-env.sh"

    # Ensure directories exist
    set -l fish_dir (dirname "$fish_config")
    set -l bash_dir (dirname "$bash_config")
    if not test -d "$fish_dir"
        mkdir -p "$fish_dir"
    end
    if not test -d "$bash_dir"
        mkdir -p "$bash_dir"
    end

    # Track env vars: keys and values separately (Fish lacks associative arrays)
    set -l seen_vars
    set -l var_values

    # === Phase 1: Collect module environment variables ===

    # Determine source YAML file
    if test -z "$yaml_path"
        set yaml_path "$HOME/.config/fedpunk/fedpunk.yaml"
    end

    if test -f "$yaml_path"
        # Determine which path to use (.modules[] or .modules.enabled[])
        set -l modules_path ".modules"
        set -l enabled_count (_yq_safe '.modules.enabled | length' "$yaml_path" 2>/dev/null)

        if test -n "$enabled_count" -a "$enabled_count" != "null" -a "$enabled_count" != "0"
            set modules_path ".modules.enabled"
        end

        set -l count (_yq_safe "$modules_path | length" "$yaml_path" 2>/dev/null)

        if test "$count" != "0" -a "$count" != "null" -a -n "$count"
            for i in (seq 0 (math $count - 1))
                # Get module reference
                set -l item_path "$modules_path""[$i]"
                set -l ref_type (_yq_safe "$item_path | type" "$yaml_path" 2>/dev/null)

                set -l module_ref
                switch "$ref_type"
                    case '*str'
                        set module_ref (_yq_safe "$item_path" "$yaml_path" 2>/dev/null)
                    case '*map'
                        set module_ref (_yq_safe "$item_path.module" "$yaml_path" 2>/dev/null)
                end

                if test -z "$module_ref" -o "$module_ref" = "null"
                    continue
                end

                # Resolve module path
                set -l module_path (module-resolve-path "$module_ref" 2>/dev/null)
                if test -z "$module_path" -o ! -d "$module_path"
                    continue
                end

                set -l module_yaml "$module_path/module.yaml"
                if not test -f "$module_yaml"
                    continue
                end

                # Get environment from this module
                set -l env_pairs (env-get-module-environment "$module_yaml")

                for pair in $env_pairs
                    set -l parts (string split -m 1 '=' -- "$pair")
                    if test (count $parts) -eq 2
                        set -l key $parts[1]
                        set -l value $parts[2]

                        # Store or update
                        if not contains "$key" $seen_vars
                            set -a seen_vars "$key"
                            set -a var_values "$pair"
                        else
                            # Update existing
                            for idx in (seq (count $seen_vars))
                                if test "$seen_vars[$idx]" = "$key"
                                    set var_values[$idx] "$pair"
                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    # === Phase 2: Collect user environment variables (override module) ===

    set -l user_env (env-get-user-environment "$yaml_path")
    for pair in $user_env
        set -l parts (string split -m 1 '=' -- "$pair")
        if test (count $parts) -eq 2
            set -l key $parts[1]
            set -l value $parts[2]

            if not contains "$key" $seen_vars
                set -a seen_vars "$key"
                set -a var_values "$pair"
            else
                # Update existing (user overrides module)
                for idx in (seq (count $seen_vars))
                    if test "$seen_vars[$idx]" = "$key"
                        set var_values[$idx] "$pair"
                        break
                    end
                end
            end
        end
    end

    # === Phase 3: Generate output ===

    # Fish config lines
    set -l fish_lines
    set -a fish_lines "#!/usr/bin/env fish"
    set -a fish_lines "# Auto-generated by fedpunk - DO NOT EDIT"
    set -a fish_lines "# Regenerate with: fedpunk apply"
    set -a fish_lines "# Environment variables from modules and user config"
    set -a fish_lines ""

    # Bash config lines
    set -l bash_lines
    set -a bash_lines "#!/bin/sh"
    set -a bash_lines "# Auto-generated by fedpunk - DO NOT EDIT"
    set -a bash_lines "# Regenerate with: fedpunk apply"
    set -a bash_lines "# Environment variables from modules and user config"
    set -a bash_lines ""

    if test (count $seen_vars) -gt 0
        for pair in $var_values
            set -l parts (string split -m 1 '=' -- "$pair")
            set -l key $parts[1]
            set -l value $parts[2]

            # Remove surrounding quotes if present (yq adds them)
            set value (string replace -r '^"' '' "$value")
            set value (string replace -r '"$' '' "$value")

            # For values with $FEDPUNK_PARAM_*, generate unquoted so shell expands
            if string match -q '*$FEDPUNK_PARAM_*' "$value"
                set -a fish_lines "set -gx $key $value"
                set -a bash_lines "export $key=$value"
            else
                # Static value - quote it and escape special chars
                set -l escaped_value (string replace -a '\\' '\\\\' "$value")
                set escaped_value (string replace -a '"' '\\"' "$escaped_value")
                set -a fish_lines "set -gx $key \"$escaped_value\""
                set -a bash_lines "export $key=\"$escaped_value\""
            end
        end
    end

    # Write fish config
    printf "%s\n" $fish_lines > "$fish_config"
    echo "Generated environment config: $fish_config"

    # Write bash config (user must source from .bashrc if using bash)
    printf "%s\n" $bash_lines > "$bash_config"
    echo "Generated environment config: $bash_config"

    return 0
end
