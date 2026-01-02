#!/usr/bin/env fish
# Source repository management commands

# Main function - required for bin to discover this command
function source --description "Manage module sources"
    # No-op: bin handles subcommand routing
end

function add --description "Add a source repository"
    if contains -- "$argv[1]" --help -h
        printf "Add a source repository (multi-module git repo)\n"
        printf "\n"
        printf "Usage: fedpunk source add <git-url>\n"
        printf "\n"
        printf "Sources are git repositories containing multiple modules.\n"
        printf "Modules within sources are discovered automatically.\n"
        printf "\n"
        printf "Examples:\n"
        printf "  fedpunk source add git@gitlab.com:org/fedpunk-modules.git\n"
        printf "  fedpunk source add https://github.com/user/modules.git\n"
        return 0
    end

    set -l url $argv[1]

    if test -z "$url"
        printf "Error: Source URL required\n" >&2
        printf "Usage: fedpunk source add <git-url>\n" >&2
        return 1
    end

    # Source libraries
    if not functions -q fedpunk-config-add-source
        source "$FEDPUNK_SYSTEM/lib/fish/config.fish"
    end
    if not functions -q source-clone
        source "$FEDPUNK_SYSTEM/lib/fish/sources.fish"
    end

    # Add to config
    fedpunk-config-add-source "$url"
    or begin
        printf "Error: Failed to add source to config\n" >&2
        return 1
    end

    # Clone the source
    source-clone "$url"
    or begin
        printf "Error: Failed to clone source\n" >&2
        return 1
    end

    # Show discovered modules
    set -l modules (source-discover-modules "$url")
    if test (count $modules) -gt 0
        printf "Source added successfully!\n"
        printf "\n"
        printf "Discovered modules:\n"
        for m in $modules
            printf "  %s\n" "$m"
        end
        printf "\n"
        printf "Deploy modules with:\n"
        printf "  fedpunk module deploy <name>\n"
    else
        printf "Source added, but no modules found.\n"
        printf "Make sure the repository contains module.yaml files.\n"
    end
end

function remove --description "Remove a source repository"
    if contains -- "$argv[1]" --help -h
        printf "Remove a source repository\n"
        printf "\n"
        printf "Usage: fedpunk source remove <git-url>\n"
        printf "\n"
        printf "Removes the source from config and optionally deletes local clone.\n"
        return 0
    end

    set -l url $argv[1]

    if test -z "$url"
        printf "Error: Source URL required\n" >&2
        printf "Usage: fedpunk source remove <git-url>\n" >&2
        return 1
    end

    # Source libraries
    if not functions -q fedpunk-config-path
        source "$FEDPUNK_SYSTEM/lib/fish/config.fish"
    end
    if not functions -q source-get-path
        source "$FEDPUNK_SYSTEM/lib/fish/sources.fish"
    end

    set -l config_file (fedpunk-config-path)

    # Remove from config
    yq -i "del(.sources[] | select(. == \"$url\"))" "$config_file"

    # Ask about local clone
    set -l source_path (source-get-path "$url")
    if test -d "$source_path"
        printf "Source removed from config.\n"
        printf "Local clone exists at: %s\n" "$source_path"
        printf "\n"
        printf "Remove local clone? [y/N] "
        read -l confirm
        if test "$confirm" = "y" -o "$confirm" = "Y"
            rm -rf "$source_path"
            printf "Local clone removed.\n"
        else
            printf "Local clone kept.\n"
        end
    else
        printf "Source removed from config.\n"
    end
end

function list --description "List configured sources"
    if contains -- "$argv[1]" --help -h
        printf "List all configured source repositories\n"
        printf "\n"
        printf "Usage: fedpunk source list\n"
        printf "\n"
        printf "Shows all source repositories and their sync status.\n"
        return 0
    end

    # Source libraries
    if not functions -q fedpunk-config-list-sources
        source "$FEDPUNK_SYSTEM/lib/fish/config.fish"
    end
    if not functions -q source-get-path
        source "$FEDPUNK_SYSTEM/lib/fish/sources.fish"
    end

    set -l sources (fedpunk-config-list-sources)

    if test -z "$sources"
        printf "No sources configured.\n"
        printf "\n"
        printf "Add a source with:\n"
        printf "  fedpunk source add <git-url>\n"
        return 0
    end

    printf "Configured sources:\n"
    for url in $sources
        set -l source_path (source-get-path "$url")
        set -l status_marker ""

        if test -d "$source_path/.git"
            set status_marker "(synced)"
        else if test -d "$source_path"
            set status_marker "(not a git repo)"
        else
            set status_marker "(not cloned)"
        end

        printf "  %s %s\n" "$url" "$status_marker"
    end
end

function sync --description "Sync all source repositories"
    if contains -- "$argv[1]" --help -h
        printf "Clone or update all configured source repositories\n"
        printf "\n"
        printf "Usage: fedpunk source sync\n"
        printf "\n"
        printf "Runs git pull on all sources, cloning if needed.\n"
        return 0
    end

    # Source libraries
    if not functions -q source-sync-all
        source "$FEDPUNK_SYSTEM/lib/fish/sources.fish"
    end

    source-sync-all
    or begin
        printf "Some sources failed to sync.\n" >&2
        return 1
    end

    printf "All sources synced.\n"
end

function modules --description "List modules from all sources"
    if contains -- "$argv[1]" --help -h
        printf "List all modules available from configured sources\n"
        printf "\n"
        printf "Usage: fedpunk source modules\n"
        printf "\n"
        printf "Shows modules discovered in each source repository.\n"
        return 0
    end

    # Source libraries
    if not functions -q source-list-all-modules
        source "$FEDPUNK_SYSTEM/lib/fish/sources.fish"
    end

    set -l module_list (source-list-all-modules)

    if test -z "$module_list"
        printf "No modules found in sources.\n"
        printf "\n"
        printf "Make sure sources are synced:\n"
        printf "  fedpunk source sync\n"
        return 0
    end

    printf "Modules from sources:\n"

    # Group by source
    set -l current_source ""
    for line in $module_list
        set -l parts (string split "|" -- $line)
        set -l module_name $parts[1]
        set -l source_name $parts[2]

        if test "$source_name" != "$current_source"
            if test -n "$current_source"
                printf "\n"
            end
            printf "  %s:\n" "$source_name"
            set current_source "$source_name"
        end

        printf "    %s\n" "$module_name"
    end
end
