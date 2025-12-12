#!/usr/bin/env fish
# Profile discovery across multiple locations
# Priority: ~/.config/fedpunk/profiles > $FEDPUNK_USER/profiles > $FEDPUNK_SYSTEM/profiles

function profile-get-search-paths
    # Returns profile search paths in priority order
    # Custom user profiles override user data profiles override system profiles
    echo "$HOME/.config/fedpunk/profiles"
    echo "$FEDPUNK_USER/profiles"
    echo "$FEDPUNK_SYSTEM/profiles"
end

function profile-find-path
    # Find the path to a profile by name
    # Usage: profile-find-path <profile-name>
    # Returns: absolute path to profile directory, or empty if not found
    # Exit code: 0 if found, 1 if not found

    set -l profile_name $argv[1]

    if test -z "$profile_name"
        echo "Error: profile name required" >&2
        return 1
    end

    for search_path in (profile-get-search-paths)
        set -l profile_dir "$search_path/$profile_name"
        if test -d "$profile_dir"
            echo "$profile_dir"
            return 0
        end
    end

    return 1
end

function profile-list-all
    # List all available profiles with their sources
    # Output format: "profile_name|path|source" (one per line)
    # Source: custom (from ~/.config), user (from $FEDPUNK_USER), system (from $FEDPUNK_SYSTEM)
    # De-duplicates: first match wins (custom > user > system)

    set -l seen_profiles

    for search_path in (profile-get-search-paths)
        if not test -d "$search_path"
            continue
        end

        # Determine source label
        set -l source "custom"
        if string match -q "*/.local/share/fedpunk/profiles" "$search_path"
            set source "user"
        else if string match -q "*/usr/share/fedpunk/profiles" "$search_path"
            set source "system"
        end

        # List profiles in this directory
        for profile_dir in $search_path/*
            if not test -d "$profile_dir"
                continue
            end

            set -l profile_name (basename "$profile_dir")

            # Skip if already seen (priority override)
            if contains $profile_name $seen_profiles
                continue
            end

            set -a seen_profiles $profile_name
            echo "$profile_name|$profile_dir|$source"
        end
    end
end

function profile-list-modes
    # List available modes for a profile
    # Usage: profile-list-modes <profile-name>
    # Returns: list of mode names, one per line

    set -l profile_name $argv[1]

    if test -z "$profile_name"
        echo "Error: profile name required" >&2
        return 1
    end

    set -l profile_dir (profile-find-path "$profile_name")
    if test -z "$profile_dir"
        echo "Error: profile '$profile_name' not found" >&2
        return 1
    end

    set -l modes_dir "$profile_dir/modes"
    if not test -d "$modes_dir"
        echo "Error: no modes directory in profile '$profile_name'" >&2
        return 1
    end

    for mode_dir in $modes_dir/*
        if test -d "$mode_dir"
            basename "$mode_dir"
        end
    end
end
