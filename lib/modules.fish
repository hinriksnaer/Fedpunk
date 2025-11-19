#!/usr/bin/env fish
# ============================================================================
# Module Loader Library
# ============================================================================
# Provides functions for executing modules with proper environment setup

# Execute a module hook script
# Usage: execute_module_hook <module_name> <hook_script> [phase]
function execute_module_hook
    set module_name $argv[1]
    set hook_script $argv[2]
    set phase $argv[3]

    set module_path "$FEDPUNK_PATH/modules/$module_name"
    set script_path "$module_path/$hook_script"

    if not test -f "$script_path"
        warning "Hook script not found: $script_path"
        return 1
    end

    # Make script executable
    chmod +x "$script_path" 2>/dev/null

    # Set module-specific environment
    set -lx FEDPUNK_CURRENT_MODULE $module_name
    set -lx FEDPUNK_MODULE_PATH $module_path

    # Execute the hook script
    fish "$script_path"
    set exit_code $status

    if test $exit_code -ne 0
        error "Module hook failed: $module_name/$hook_script (exit code: $exit_code)"
        return $exit_code
    end

    return 0
end

# Check if a module should run based on mode
# Usage: module_enabled_for_mode <module_name>
function module_enabled_for_mode
    set module_name $argv[1]

    # Check if module is enabled for current mode via environment variable
    set var_name "FEDPUNK_MODULE_"(echo $module_name | string upper | string replace '-' '_')"_ENABLED"

    if set -q $var_name
        test "$$var_name" = "true"
        return $status
    end

    # Default to enabled if not specified
    return 0
end

# Check if module should auto-detect and prompt
# Usage: should_run_module <module_name>
function should_run_module
    set module_name $argv[1]

    # First check if enabled for mode
    if not module_enabled_for_mode $module_name
        info "Skipping module '$module_name' (disabled for mode: $FEDPUNK_MODE)"
        return 1
    end

    # Check for auto-detect command
    set var_name "FEDPUNK_MODULE_"(echo $module_name | string upper | string replace '-' '_')"_AUTO_DETECT_CMD"

    if set -q $var_name
        # Run detection command
        eval $$var_name >/dev/null 2>&1
        if test $status -eq 0
            # Detected - check if we should prompt
            set prompt_var "FEDPUNK_MODULE_"(echo $module_name | string upper | string replace '-' '_')"_AUTO_DETECT_PROMPT"
            set default_var "FEDPUNK_MODULE_"(echo $module_name | string upper | string replace '-' '_')"_AUTO_DETECT_DEFAULT"

            if set -q $prompt_var
                # Prompt user
                if command -v gum >/dev/null 2>&1
                    set default_answer "yes"
                    if set -q $default_var
                        set default_answer $$default_var
                    end

                    gum confirm "$$prompt_var" --default=$default_answer
                    return $status
                else
                    # No gum, use default
                    if set -q $default_var; and test "$$default_var" = "yes"
                        return 0
                    else
                        return 1
                    end
                end
            end

            # Auto-detected and no prompt configured - run it
            return 0
        else
            # Not detected - skip
            info "Skipping module '$module_name' (auto-detection failed)"
            return 1
        end
    end

    # No auto-detection - run the module
    return 0
end

# Export module parameters as environment variables
# Usage: export_module_params <module_name> <param_list_json>
function export_module_params
    set module_name $argv[1]
    set params_json $argv[2]

    # Module parameters are exported as FEDPUNK_MODULE_<NAME>_<PARAM>=value
    # The params_json is expected to be parsed by chezmoi template and passed as arguments

    # This is a placeholder - actual implementation will receive pre-parsed params from template
end
