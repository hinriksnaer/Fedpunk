#!/usr/bin/env fish
# Module path resolution - handles both base modules and profile plugins

function module-resolve-path
    # Resolve module name to actual directory path
    # Handles: regular modules, profile plugins
    set -l module_name $argv[1]

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
