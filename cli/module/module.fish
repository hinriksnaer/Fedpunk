#!/usr/bin/env fish
# Module management commands

# Main function - required for bin to discover this command
function module --description "Manage modules"
    # No-op: bin handles subcommand routing
end

function installed --description "List installed modules"
    if contains -- "$argv[1]" --help -h
        printf "List all installed/deployed modules\n"
        printf "\n"
        printf "Usage: fedpunk module installed\n"
        printf "\n"
        printf "Shows all deployed modules grouped by type:\n"
        printf "  native   - Built-in system modules\n"
        printf "  sources  - Modules from configured source repos\n"
        printf "  external - Git-cloned modules (~/.config/fedpunk/modules/)\n"
        printf "  profile  - Modules from active profile\n"
        return 0
    end

    # Source libraries
    source "$FEDPUNK_SYSTEM/lib/fish/config.fish"
    source "$FEDPUNK_SYSTEM/lib/fish/module-resolver.fish"
    source "$FEDPUNK_SYSTEM/lib/fish/external-modules.fish"
    source "$FEDPUNK_SYSTEM/lib/fish/sources.fish"

    # Collect all installed modules from multiple sources
    set -l all_modules

    # 1. Get modules from fedpunk.yaml (explicitly deployed)
    set -l config_modules (fedpunk-config-list-enabled-modules 2>/dev/null)
    for m in $config_modules
        set -a all_modules $m
    end

    # 2. Get modules from active profile's mode.yaml
    set -l profile_name (fedpunk-config-get profile 2>/dev/null)
    set -l mode_name (fedpunk-config-get mode 2>/dev/null)
    if test -n "$profile_name" -a -n "$mode_name" -a "$profile_name" != "null" -a "$mode_name" != "null"
        # Find profile directory
        set -l profile_dir ""
        if test -d "$HOME/.config/fedpunk/profiles/$profile_name"
            set profile_dir "$HOME/.config/fedpunk/profiles/$profile_name"
        else if test -d "$FEDPUNK_SYSTEM/profiles/$profile_name"
            set profile_dir "$FEDPUNK_SYSTEM/profiles/$profile_name"
        end

        if test -n "$profile_dir"
            set -l mode_file "$profile_dir/modes/$mode_name/mode.yaml"
            if test -f "$mode_file"
                # Get module references from mode.yaml
                set -l mode_modules (yq '.modules[]' "$mode_file" 2>/dev/null | string replace -r '^-\s*' '')
                for m in $mode_modules
                    # Handle both string and object formats
                    if string match -q '{*' "$m"
                        # Object format - extract module field
                        set m (echo "$m" | yq '.module' 2>/dev/null)
                    end
                    if test -n "$m" -a "$m" != "null"
                        set -a all_modules $m
                    end
                end
            end
        end
    end

    if test (count $all_modules) -eq 0
        echo "No modules installed."
        echo "Use 'fedpunk module deploy <name>' or 'fedpunk apply' to install modules."
        return 0
    end

    set -l native_modules
    set -l source_modules
    set -l external_modules_names
    set -l external_modules_git
    set -l profile_modules

    # Get source storage path for matching
    set -l source_dir (source-storage-dir)

    for module_ref in $all_modules
        # Get the resolved path to determine type
        set -l module_path (module-resolve-path "$module_ref" 2>/dev/null)
        if test -z "$module_path"
            continue
        end

        # Determine module type based on path
        set -l module_name (basename "$module_path")
        set -l is_git "no"
        if test -d "$module_path/.git"
            set is_git "yes"
        end

        if string match -q "$FEDPUNK_SYSTEM/modules/*" "$module_path"
            if not contains "$module_name" $native_modules
                set -a native_modules "$module_name"
            end
        else if string match -q "$source_dir/*" "$module_path"
            if not contains "$module_name" $source_modules
                set -a source_modules "$module_name"
            end
        else if string match -q "$HOME/.config/fedpunk/modules/*" "$module_path"
            if not contains "$module_name" $external_modules_names
                set -a external_modules_names "$module_name"
                set -a external_modules_git "$is_git"
            end
        else
            if not contains "$module_name" $profile_modules
                set -a profile_modules "$module_name"
            end
        end
    end

    # Display results
    if test (count $native_modules) -gt 0
        echo "Native modules:"
        for m in $native_modules
            echo "  $m"
        end
        echo ""
    end

    if test (count $source_modules) -gt 0
        echo "Source modules:"
        for m in $source_modules
            echo "  $m"
        end
        echo ""
    end

    if test (count $external_modules_names) -gt 0
        echo "External modules:"
        set -l i 1
        for m in $external_modules_names
            set -l git_status ""
            if test "$external_modules_git[$i]" = "yes"
                set git_status " (git)"
            end
            echo "  $m$git_status"
            set i (math $i + 1)
        end
        echo ""
    end

    if test (count $profile_modules) -gt 0
        echo "Profile modules:"
        for m in $profile_modules
            echo "  $m"
        end
        echo ""
    end
end

function available --description "List available modules"
    if contains -- "$argv[1]" --help -h
        printf "List all available modules (not yet installed)\n"
        printf "\n"
        printf "Usage: fedpunk module available\n"
        printf "\n"
        printf "Shows modules that can be installed, grouped by type:\n"
        printf "  native   - Built-in system modules\n"
        printf "  sources  - Modules from configured source repos\n"
        printf "  external - Previously cloned modules\n"
        printf "  profile  - Modules from active profile\n"
        return 0
    end

    source "$FEDPUNK_SYSTEM/lib/fish/config.fish"
    source "$FEDPUNK_SYSTEM/lib/fish/external-modules.fish"
    source "$FEDPUNK_SYSTEM/lib/fish/sources.fish"

    # Get installed modules for filtering
    set -l installed (fedpunk-config-list-enabled-modules 2>/dev/null | while read -l ref
        # Resolve to get the actual module name
        set -l path (module-resolve-path "$ref" 2>/dev/null)
        if test -n "$path"
            basename "$path"
        end
    end)

    set -l native_available
    set -l source_available
    set -l external_available
    set -l profile_available

    # Native/system modules
    if test -d "$FEDPUNK_SYSTEM/modules"
        for module in $FEDPUNK_SYSTEM/modules/*/
            if test -f "$module/module.yaml"
                set -l name (basename "$module")
                if not contains "$name" $installed
                    set -a native_available "$name"
                end
            end
        end
    end

    # Source modules (from configured source repos)
    set -l source_modules (source-list-all-modules 2>/dev/null)
    for line in $source_modules
        set -l parts (string split "|" -- $line)
        set -l name $parts[1]
        if not contains "$name" $installed
            if not contains "$name" $source_available
                set -a source_available "$name"
            end
        end
    end

    # External modules (previously cloned direct git URLs)
    set -l external_dir (external-module-storage-dir)
    if test -d "$external_dir"
        for module in $external_dir/*/
            if test -f "$module/module.yaml"
                set -l name (basename "$module")
                if not contains "$name" $installed
                    # Don't show if already in source_available
                    if not contains "$name" $source_available
                        set -a external_available "$name"
                    end
                end
            end
        end
    end

    # Profile modules
    set -l active_config_link "$FEDPUNK_USER/.active-config"
    if test -L "$active_config_link"
        set -l profile_dir (readlink -f "$active_config_link")
        if test -d "$profile_dir/modules"
            for module in $profile_dir/modules/*/
                if test -f "$module/module.yaml"
                    set -l name (basename "$module")
                    if not contains "$name" $installed
                        set -a profile_available "$name"
                    end
                end
            end
        end
    end

    # Display results
    set -l found 0

    if test (count $native_available) -gt 0
        echo "Native modules:"
        for m in $native_available
            echo "  $m"
        end
        echo ""
        set found 1
    end

    if test (count $source_available) -gt 0
        echo "Source modules:"
        for m in $source_available
            echo "  $m"
        end
        echo ""
        set found 1
    end

    if test (count $external_available) -gt 0
        echo "External modules:"
        for m in $external_available
            echo "  $m"
        end
        echo ""
        set found 1
    end

    if test (count $profile_available) -gt 0
        echo "Profile modules:"
        for m in $profile_available
            echo "  $m"
        end
        echo ""
        set found 1
    end

    if test $found -eq 0
        echo "All available modules are already installed."
    end
end

function deploy --description "Deploy a module"
    if contains -- "$argv[1]" --help -h
        printf "Deploy a module (install packages + config + lifecycle scripts)\n"
        printf "\n"
        printf "Usage: fedpunk module deploy <name|url>\n"
        printf "\n"
        printf "Modules are added to ~/.config/fedpunk/fedpunk.yaml\n"
        printf "Run 'fedpunk apply' to re-apply configuration.\n"
        printf "\n"
        printf "Examples:\n"
        printf "  fedpunk module deploy neovim\n"
        printf "  fedpunk module deploy https://github.com/user/module.git\n"
        return 0
    end

    set -l module_name $argv[1]

    if test -z "$module_name"
        printf "Error: Module name or URL required\n" >&2
        printf "Usage: fedpunk module deploy <name|url>\n" >&2
        printf "\n"
        printf "Examples:\n"
        printf "  fedpunk module deploy neovim\n"
        printf "  fedpunk module deploy https://github.com/user/module.git\n"
        return 1
    end

    # Source deployer library
    if not functions -q deployer-deploy-module
        source "$FEDPUNK_SYSTEM/lib/fish/deployer.fish"
    end

    # Use deployer to deploy and update config
    deployer-deploy-module $module_name
end

function update --description "Update external modules"
    if contains -- "$argv[1]" --help -h
        printf "Update external modules from git\n"
        printf "\n"
        printf "Usage: fedpunk module update <name|all>\n"
        printf "\n"
        printf "Pulls latest changes from git and redeploys if updated.\n"
        printf "Only works for external modules with .git directory.\n"
        printf "\n"
        printf "Examples:\n"
        printf "  fedpunk module update thinkpad-fans\n"
        printf "  fedpunk module update all\n"
        return 0
    end

    set -l target $argv[1]

    if test -z "$target"
        printf "Error: Module name or 'all' required\n" >&2
        printf "Usage: fedpunk module update <name|all>\n" >&2
        return 1
    end

    # Source libraries
    source "$FEDPUNK_SYSTEM/lib/fish/config.fish"
    source "$FEDPUNK_SYSTEM/lib/fish/module-resolver.fish"
    source "$FEDPUNK_SYSTEM/lib/fish/external-modules.fish"
    source "$FEDPUNK_SYSTEM/lib/fish/deployer.fish"

    set -l external_dir (external-module-storage-dir)

    # Build list of modules to update
    set -l modules_to_update

    if test "$target" = "all"
        # Get all external modules that are git repos
        if test -d "$external_dir"
            for module in $external_dir/*/
                if test -d "$module/.git"
                    set -a modules_to_update (basename "$module")
                end
            end
        end

        if test (count $modules_to_update) -eq 0
            echo "No external git modules found to update."
            return 0
        end
    else
        # Single module
        set -l module_path "$external_dir/$target"
        if not test -d "$module_path"
            printf "Error: Module '%s' not found in external modules\n" "$target" >&2
            printf "External modules directory: %s\n" "$external_dir" >&2
            return 1
        end

        if not test -d "$module_path/.git"
            printf "Error: Module '%s' is not a git repository\n" "$target" >&2
            return 1
        end

        set modules_to_update $target
    end

    # Update each module
    set -l updated_count 0
    for module_name in $modules_to_update
        set -l module_path "$external_dir/$module_name"
        echo "Checking $module_name..."

        # Get current commit
        set -l old_commit (git -C "$module_path" rev-parse HEAD 2>/dev/null)

        # Pull changes
        set -l pull_output (git -C "$module_path" pull 2>&1)
        set -l pull_status $status

        if test $pull_status -ne 0
            printf "  Error pulling %s: %s\n" "$module_name" "$pull_output" >&2
            continue
        end

        # Get new commit
        set -l new_commit (git -C "$module_path" rev-parse HEAD 2>/dev/null)

        if test "$old_commit" = "$new_commit"
            echo "  Already up to date."
        else
            echo "  Updated: $old_commit -> $new_commit"
            echo "  Redeploying..."

            # Redeploy the module
            deployer-deploy-module "$module_name"
            set updated_count (math $updated_count + 1)
        end
    end

    echo ""
    if test "$target" = "all"
        echo "Updated $updated_count of "(count $modules_to_update)" modules."
    end
end
