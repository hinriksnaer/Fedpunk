#!/usr/bin/env fish
# Parameter prompting system - handles interactive parameter collection
# Prompts for required parameters and saves them to fedpunk.yaml

# Source dependencies
set -l lib_dir (dirname (status -f))
source "$lib_dir/ui.fish"
source "$lib_dir/yaml-parser.fish"
source "$lib_dir/module-resolver.fish"

function param-get-fedpunk-config-path
    # Get the path to fedpunk.yaml, creating directory if needed
    set -l config_path "$HOME/.config/fedpunk/fedpunk.yaml"
    set -l config_dir (dirname "$config_path")

    if not test -d "$config_dir"
        mkdir -p "$config_dir"
    end

    echo "$config_path"
end

function param-init-fedpunk-config
    # Initialize fedpunk.yaml if it doesn't exist
    set -l config_path (param-get-fedpunk-config-path)

    if not test -f "$config_path"
        echo "# Fedpunk declarative configuration" > "$config_path"
        echo "# This file stores module parameters and enabled modules" >> "$config_path"
        echo "" >> "$config_path"
        echo "modules:" >> "$config_path"
        echo "  enabled: []" >> "$config_path"
    end

    echo "$config_path"
end

function param-load-module-definition
    # Load parameter definitions from module.yaml
    # Usage: param-load-module-definition <module-path>
    # Returns: JSON-formatted parameter definitions

    set -l module_path $argv[1]
    set -l module_yaml "$module_path/module.yaml"

    if not test -f "$module_yaml"
        return 1
    end

    # Check if parameters section exists
    set -l has_params (yq eval '.parameters | length' "$module_yaml" 2>/dev/null)
    if test "$has_params" = "0" -o "$has_params" = "null"
        return 0
    end

    # Get parameter keys
    set -l param_keys (yq eval '.parameters | keys | .[]' "$module_yaml" 2>/dev/null)

    for key in $param_keys
        set -l param_type (yq eval ".parameters.$key.type" "$module_yaml" 2>/dev/null)
        set -l param_desc (yq eval ".parameters.$key.description" "$module_yaml" 2>/dev/null)
        set -l param_default (yq eval ".parameters.$key.default" "$module_yaml" 2>/dev/null)
        set -l param_required (yq eval ".parameters.$key.required" "$module_yaml" 2>/dev/null)

        # Output in parseable format: key|type|description|default|required
        echo "$key|$param_type|$param_desc|$param_default|$param_required"
    end
end

function param-get-current-value
    # Get current value of a parameter from fedpunk.yaml
    # Usage: param-get-current-value <module-name> <param-key>

    set -l module_name $argv[1]
    set -l param_key $argv[2]
    set -l config_path (param-get-fedpunk-config-path)

    if not test -f "$config_path"
        return 1
    end

    # Search through enabled modules for this module
    set -l count (yq eval '.modules.enabled | length' "$config_path" 2>/dev/null)
    if test "$count" = "0" -o "$count" = "null"
        return 1
    end

    for i in (seq 0 (math $count - 1))
        set -l ref_type (yq eval ".modules.enabled[$i] | type" "$config_path" 2>/dev/null)

        if test "$ref_type" = "!!map"
            set -l mod_ref (yq eval ".modules.enabled[$i].module" "$config_path" 2>/dev/null)
            set -l mod_name (module-ref-extract-name "$mod_ref")

            if test "$mod_name" = "$module_name"
                set -l value (yq eval ".modules.enabled[$i].params.$param_key" "$config_path" 2>/dev/null)
                if test "$value" != "null" -a -n "$value"
                    echo "$value"
                    return 0
                end
            end
        end
    end

    return 1
end

function param-prompt-for-value
    # Prompt user for a parameter value
    # Usage: param-prompt-for-value <param-key> <param-desc> <param-default>

    set -l param_key $argv[1]
    set -l param_desc $argv[2]
    set -l param_default $argv[3]

    set -l prompt_msg "$param_desc"
    if test "$param_default" != "null" -a -n "$param_default"
        set prompt_msg "$prompt_msg (default: $param_default)"
    end

    # Use gum input parameters - --placeholder for the prompt, --value for default
    if test "$param_default" != "null" -a -n "$param_default"
        set -l value (ui-input --placeholder "$prompt_msg" --value "$param_default")
        echo "$value"
    else
        set -l value (ui-input --placeholder "$prompt_msg")
        echo "$value"
    end
end

function param-save-to-config
    # Save parameter values to fedpunk.yaml
    # Usage: param-save-to-config <module-ref> <param-key> <param-value>

    set -l module_ref $argv[1]
    set -l param_key $argv[2]
    set -l param_value $argv[3]

    set -l config_path (param-init-fedpunk-config)
    set -l module_name (module-ref-extract-name "$module_ref")

    # Check if module already exists in enabled list
    set -l count (yq eval '.modules.enabled | length' "$config_path" 2>/dev/null)
    set -l module_index -1

    if test "$count" != "0" -a "$count" != "null"
        for i in (seq 0 (math $count - 1))
            set -l ref_type (yq eval ".modules.enabled[$i] | type" "$config_path" 2>/dev/null)

            if test "$ref_type" = "!!str"
                set -l existing_ref (yq eval ".modules.enabled[$i]" "$config_path" 2>/dev/null)
                if test "$existing_ref" = "$module_ref"
                    set module_index $i
                    break
                end
            else if test "$ref_type" = "!!map"
                set -l existing_ref (yq eval ".modules.enabled[$i].module" "$config_path" 2>/dev/null)
                if test "$existing_ref" = "$module_ref"
                    set module_index $i
                    break
                end
            end
        end
    end

    if test $module_index -ge 0
        # Module exists - check if it's a string or map
        set -l ref_type (yq eval ".modules.enabled[$module_index] | type" "$config_path" 2>/dev/null)

        if test "$ref_type" = "!!str"
            # Convert from string to map
            yq eval -i ".modules.enabled[$module_index] = {\"module\": .modules.enabled[$module_index], \"params\": {}}" "$config_path"
        end

        # Add/update parameter
        yq eval -i ".modules.enabled[$module_index].params.$param_key = \"$param_value\"" "$config_path"
    else
        # Add new module entry with parameter
        yq eval -i ".modules.enabled += [{\"module\": \"$module_ref\", \"params\": {\"$param_key\": \"$param_value\"}}]" "$config_path"
    end

    ui-success "Saved $param_key to $config_path"
end

function param-prompt-required
    # Prompt for all required parameters that don't have values
    # Usage: param-prompt-required <module-ref> <module-path>
    # Returns: 0 if all required params satisfied, 1 otherwise

    set -l module_ref $argv[1]
    set -l module_path $argv[2]
    set -l module_name (module-ref-extract-name "$module_ref")

    # Load parameter definitions
    set -l param_defs (param-load-module-definition "$module_path")

    if test (count $param_defs) -eq 0
        # No parameters defined
        return 0
    end

    set -l missing_required 0

    for def in $param_defs
        set -l parts (string split '|' -- $def)
        set -l key $parts[1]
        set -l param_type $parts[2]
        set -l description $parts[3]
        set -l default $parts[4]
        set -l required $parts[5]

        # Check if we need to prompt for this parameter
        if test "$required" = "true"
            # Check if value already exists
            set -l current_value (param-get-current-value "$module_name" "$key")

            if test -z "$current_value"
                ui-info "Module '$module_name' requires parameter: $key"
                set -l value (param-prompt-for-value "$key" "$description" "$default")

                if test -n "$value"
                    param-save-to-config "$module_ref" "$key" "$value"
                else
                    ui-error "Required parameter '$key' cannot be empty"
                    set missing_required 1
                end
            end
        end
    end

    return $missing_required
end

function param-prompt-all-modules
    # Prompt for required parameters for all modules in a mode.yaml
    # Usage: param-prompt-all-modules <mode-yaml-path>

    set -l mode_yaml $argv[1]

    if not test -f "$mode_yaml"
        ui-error "Mode YAML not found: $mode_yaml"
        return 1
    end

    # Get count of modules
    set -l count (yq eval '.modules | length' "$mode_yaml" 2>/dev/null)

    if test "$count" = "0" -o "$count" = "null"
        return 0
    end

    # Process each module
    for i in (seq 0 (math $count - 1))
        set -l ref_type (yq eval ".modules[$i] | type" "$mode_yaml" 2>/dev/null)
        set -l module_ref ""

        if test "$ref_type" = "!!str"
            set module_ref (yq eval ".modules[$i]" "$mode_yaml" 2>/dev/null)
        else if test "$ref_type" = "!!map"
            set module_ref (yq eval ".modules[$i].module" "$mode_yaml" 2>/dev/null)
        end

        if test -n "$module_ref" -a "$module_ref" != "null"
            # Resolve module path
            set -l module_path (module-resolve-path "$module_ref" 2>/dev/null)

            if test -n "$module_path" -a -d "$module_path"
                # Prompt for required parameters
                param-prompt-required "$module_ref" "$module_path"
            end
        end
    end
end
