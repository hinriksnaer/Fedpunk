#!/usr/bin/env fish
# Module path resolution - handles base modules, profile modules, and external modules

# Source dependencies
set -l lib_dir (dirname (status -f))
source "$lib_dir/module-ref-parser.fish"
source "$lib_dir/external-modules.fish"

function module-resolve-path
    # Resolve module name to actual directory path
    # Handles: regular modules, profile modules, external git URLs, local paths
    set -l module_name $argv[1]

    # Check if it's an external URL (https://, git@, file://)
    if module-ref-is-url "$module_name"
        set -l storage_path (external-module-get-storage-path "$module_name")
        if test -d "$storage_path"
            echo "$storage_path"
            return 0
        else
            # Auto-fetch external module
            set -l fetched_path (external-module-fetch "$module_name")
            if test $status -eq 0
                echo "$fetched_path"
                return 0
            else
                return 1
            end
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

        # Otherwise, treat as relative to active profile's modules directory
        set -l active_config_link "$FEDPUNK_USER/.active-config"
        if test -L "$active_config_link"
            set -l active_profile_dir (readlink -f "$active_config_link")
            set -l module_path "$active_profile_dir/modules/$module_name"

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
    else
        # Regular module lookup (not a URL or path)
        # Regular module - check multiple locations
        # Priority: 1) Profile modules, 2) External modules, 3) System modules

        # Check active profile's modules directory first
        set -l active_config_link "$FEDPUNK_USER/.active-config"
        if test -L "$active_config_link"
            set -l active_profile_dir (readlink -f "$active_config_link")
            set -l profile_module_dir "$active_profile_dir/modules/$module_name"

            if test -d "$profile_module_dir"
                echo "$profile_module_dir"
                return 0
            end
        end

        # Check external modules directory
        set -l external_module_dir (external-module-storage-dir)"/$module_name"
        if test -d "$external_module_dir"
            echo "$external_module_dir"
            return 0
        end

        # Check system modules directory
        set -l module_dir "$FEDPUNK_SYSTEM/modules/$module_name"

        if test -d "$module_dir"
            echo "$module_dir"
            return 0
        else
            echo "Module not found: $module_name" >&2
            return 1
        end
    end
end
