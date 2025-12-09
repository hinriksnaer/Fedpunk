#!/usr/bin/env fish
# Module path resolution - handles base modules, profile plugins, and external modules

# Source dependencies
set -l lib_dir (dirname (status -f))
source "$lib_dir/module-ref-parser.fish"
source "$lib_dir/external-modules.fish"

function module-resolve-path
    # Resolve module name to actual directory path
    # Handles: regular modules, profile plugins, external git URLs, local paths
    set -l module_name $argv[1]

    # Check if it's an external URL (https://, git@, file://)
    if module-ref-is-url "$module_name"
        set -l cache_path (external-module-get-cache-path "$module_name")
        if test -d "$cache_path"
            echo "$cache_path"
            return 0
        else
            echo "External module not cached: $module_name (run 'fedpunk external sync')" >&2
            return 1
        end
    end

    # Check if it's a local path (contains / but not a URL)
    if module-ref-is-path "$module_name"
        # Expand ~ to $HOME if present
        set -l expanded_path (string replace -r '^~' "$HOME" "$module_name")

        # If absolute path, use it directly
        if string match -q '/*' "$expanded_path"
            if test -d "$expanded_path"
                echo "$expanded_path"
                return 0
            else
                echo "Module not found at path: $expanded_path" >&2
                return 1
            end
        end

        # Otherwise, treat as relative to active profile (for plugins/*)
        set -l active_config_link "$FEDPUNK_ROOT/.active-config"
        if test -L "$active_config_link"
            set -l active_profile_dir (readlink -f "$active_config_link")
            set -l module_path "$active_profile_dir/$module_name"

            if test -d "$module_path"
                echo "$module_path"
                return 0
            else
                echo "Module not found: $module_name (looked in $module_path)" >&2
                return 1
            end
        else
            echo "No active profile set (.active-config symlink missing)" >&2
            return 1
        end
    end

    # Check if it's a plugin reference (starts with "plugins/")
    if string match -q "plugins/*" $module_name
        # Get active profile
        set -l active_config_link "$FEDPUNK_ROOT/.active-config"

        if test -L "$active_config_link"
            set -l active_profile_dir (readlink -f "$active_config_link")
            set -l plugin_name (string replace "plugins/" "" $module_name)
            set -l plugin_dir "$active_profile_dir/plugins/$plugin_name"

            if test -d "$plugin_dir"
                echo "$plugin_dir"
                return 0
            else
                echo "Plugin not found: $module_name (looked in $plugin_dir)" >&2
                return 1
            end
        else
            echo "No active profile set (.active-config symlink missing)" >&2
            return 1
        end
    else
        # Regular module in base modules directory
        set -l module_dir "$FEDPUNK_ROOT/modules/$module_name"

        if test -d "$module_dir"
            echo "$module_dir"
            return 0
        else
            echo "Module not found: $module_name" >&2
            return 1
        end
    end
end
