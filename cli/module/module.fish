#!/usr/bin/env fish
# Module management commands

# Main function - required for bin to discover this command
function module --description "Manage modules"
    # No-op: bin handles subcommand routing
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

