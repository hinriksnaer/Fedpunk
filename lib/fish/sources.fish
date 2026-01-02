#!/usr/bin/env fish
# Fedpunk source repository management
# Handles cloning, updating, and discovering modules from source repos
#
# Sources can be:
# 1. Multi-module repos: subdirectories with module.yaml files
# 2. Registry repos: modules.yaml at root mapping names to git URLs
#
# They are cloned to ~/.config/fedpunk/sources/<repo-name>/
# Registry-referenced modules are cloned to ~/.config/fedpunk/modules/

# Source dependencies
set -l lib_dir (dirname (status -f))
source "$lib_dir/config.fish"
source "$lib_dir/ui.fish"
source "$lib_dir/external-modules.fish"

function source-storage-dir
    # Get the base directory for source repositories
    echo "$HOME/.config/fedpunk/sources"
end

function source-extract-repo-name
    # Extract repository name from a git URL
    # Usage: source-extract-repo-name <url>
    # Examples:
    #   git@gitlab.com:org/fedpunk-modules.git -> fedpunk-modules
    #   https://github.com/user/modules -> modules

    set -l url $argv[1]

    # Remove .git suffix and extract last path component
    set -l repo_name (string replace -r '\.git$' '' "$url")
    set -l repo_name (string replace -r '^.*[/:]' '' "$repo_name")

    echo "$repo_name"
end

function source-get-path
    # Get the local path for a source repository
    # Usage: source-get-path <url>

    set -l url $argv[1]
    set -l repo_name (source-extract-repo-name "$url")
    set -l storage_dir (source-storage-dir)

    echo "$storage_dir/$repo_name"
end

function source-clone
    # Clone a source repository
    # Usage: source-clone <url>
    # Returns: 0 on success, 1 on failure

    set -l url $argv[1]

    if test -z "$url"
        echo "Error: URL required" >&2
        return 1
    end

    set -l repo_name (source-extract-repo-name "$url")
    set -l storage_dir (source-storage-dir)
    set -l source_path "$storage_dir/$repo_name"

    # Create storage directory if needed
    if not test -d "$storage_dir"
        mkdir -p "$storage_dir"
    end

    if test -d "$source_path"
        # Already exists
        return 0
    end

    # Clone the repository
    ui-info "Cloning source: $repo_name"
    git clone --quiet "$url" "$source_path"
    or begin
        ui-error "Failed to clone source: $url"
        return 1
    end

    return 0
end

function source-update
    # Update a source repository (git pull)
    # Usage: source-update <url>
    # Returns: 0 on success (or no changes), 1 on failure

    set -l url $argv[1]

    if test -z "$url"
        echo "Error: URL required" >&2
        return 1
    end

    set -l repo_name (source-extract-repo-name "$url")
    set -l source_path (source-get-path "$url")

    if not test -d "$source_path"
        # Not cloned yet, clone it
        source-clone "$url"
        return $status
    end

    if not test -d "$source_path/.git"
        ui-error "Source '$repo_name' is not a git repository"
        return 1
    end

    # Get current commit
    set -l old_commit (git -C "$source_path" rev-parse HEAD 2>/dev/null)

    # Pull changes
    ui-info "Updating source: $repo_name"
    git -C "$source_path" pull --quiet
    or begin
        ui-error "Failed to update source: $repo_name"
        return 1
    end

    # Check if updated
    set -l new_commit (git -C "$source_path" rev-parse HEAD 2>/dev/null)
    if test "$old_commit" != "$new_commit"
        ui-info "Source updated: $old_commit -> $new_commit"
    end

    return 0
end

function source-sync-all
    # Clone or update all configured sources
    # Usage: source-sync-all
    # Returns: 0 if all succeed, 1 if any fail

    set -l sources (fedpunk-config-list-sources)

    if test -z "$sources"
        # No sources configured
        return 0
    end

    set -l failed 0
    for url in $sources
        if not source-update "$url"
            set failed 1
        end
    end

    return $failed
end

function source-is-registry
    # Check if a source is a registry (has modules.yaml at root)
    # Usage: source-is-registry <source-path>
    # Returns: 0 if registry, 1 if not

    set -l source_path $argv[1]
    test -f "$source_path/modules.yaml"
end

function source-registry-list-modules
    # List module names from a registry's modules.yaml
    # Usage: source-registry-list-modules <source-path>
    # Returns: List of module names (one per line)

    set -l source_path $argv[1]
    set -l registry_file "$source_path/modules.yaml"

    if not test -f "$registry_file"
        return 1
    end

    # Get all keys under .modules
    yq '.modules | keys | .[]' "$registry_file" 2>/dev/null
end

function source-registry-get-repo
    # Get the git repo URL for a module from a registry
    # Usage: source-registry-get-repo <source-path> <module-name>
    # Returns: Git URL for the module

    set -l source_path $argv[1]
    set -l module_name $argv[2]
    set -l registry_file "$source_path/modules.yaml"

    if not test -f "$registry_file"
        return 1
    end

    yq ".modules.$module_name.repo" "$registry_file" 2>/dev/null
end

function source-discover-modules
    # Discover all modules in a source repository
    # Usage: source-discover-modules <url>
    # Returns: List of module names (one per line)
    #
    # Checks for:
    # 1. modules.yaml at root (registry repo)
    # 2. module.yaml at root (single-module repo)
    # 3. */module.yaml in subdirectories (multi-module repo)

    set -l url $argv[1]
    set -l source_path (source-get-path "$url")

    if not test -d "$source_path"
        return 1
    end

    # Check for registry repo (modules.yaml at root)
    if source-is-registry "$source_path"
        source-registry-list-modules "$source_path"
        return 0
    end

    # Check for single-module repo (module.yaml at root)
    if test -f "$source_path/module.yaml"
        set -l repo_name (source-extract-repo-name "$url")
        echo "$repo_name"
        return 0
    end

    # Check for multi-module repo (subdirectories with module.yaml)
    for module_dir in $source_path/*/
        if test -f "$module_dir/module.yaml"
            basename "$module_dir"
        end
    end

    return 0
end

function source-find-module
    # Find a module by name in all configured sources
    # Usage: source-find-module <module-name>
    # Returns: Path to module directory, or empty if not found
    #
    # For registry sources, this will clone the module repo if needed

    set -l module_name $argv[1]

    if test -z "$module_name"
        return 1
    end

    set -l sources (fedpunk-config-list-sources)

    for url in $sources
        set -l source_path (source-get-path "$url")

        if not test -d "$source_path"
            continue
        end

        # Check if this is a registry source
        if source-is-registry "$source_path"
            set -l module_repo (source-registry-get-repo "$source_path" "$module_name")
            if test -n "$module_repo" -a "$module_repo" != "null"
                # Found in registry - clone to external modules if needed
                set -l external_path (external-module-get-storage-path "$module_repo")
                if not test -d "$external_path"
                    # Clone the module
                    external-module-fetch "$module_repo" >/dev/null
                    or continue
                end
                # Return the external module path
                echo "$external_path"
                return 0
            end
            continue
        end

        # Check if source itself is the module (single-module repo)
        set -l repo_name (source-extract-repo-name "$url")
        if test "$repo_name" = "$module_name" -a -f "$source_path/module.yaml"
            echo "$source_path"
            return 0
        end

        # Check subdirectories (multi-module repo)
        set -l module_path "$source_path/$module_name"
        if test -d "$module_path" -a -f "$module_path/module.yaml"
            echo "$module_path"
            return 0
        end
    end

    return 1
end

function source-list-all-modules
    # List all modules available from all configured sources
    # Usage: source-list-all-modules
    # Returns: List of "module_name|source_repo" (one per line)

    set -l sources (fedpunk-config-list-sources)

    for url in $sources
        set -l repo_name (source-extract-repo-name "$url")
        set -l modules (source-discover-modules "$url")

        for module in $modules
            echo "$module|$repo_name"
        end
    end
end
