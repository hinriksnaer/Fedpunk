# Profile management commands

function profile --description "Profile management"
    if contains -- "$argv[1]" --help -h
        printf "Profile management for Fedpunk\n"
        printf "\n"
        printf "Profiles define which modules and configurations are deployed.\n"
        return 0
    end
    _show_command_help profile
end

function list --description "List available profiles"
    if contains -- "$argv[1]" --help -h
        printf "List all available profiles\n"
        printf "\n"
        printf "Usage: fedpunk profile list\n"
        return 0
    end

    set -l profiles_dir "$FEDPUNK_ROOT/profiles"
    if not test -d "$profiles_dir"
        printf "No profiles directory found\n" >&2
        return 1
    end

    printf "Available profiles:\n"
    for profile_dir in $profiles_dir/*/
        if test -d "$profile_dir"
            set -l profile_name (basename "$profile_dir")
            set -l active_marker ""

            if test -L "$FEDPUNK_ROOT/.active-config"
                set -l active_profile (basename (readlink "$FEDPUNK_ROOT/.active-config"))
                if test "$profile_name" = "$active_profile"
                    set active_marker " (active)"
                end
            end
            printf "  • %s%s\n" "$profile_name" "$active_marker"
        end
    end
end

function current --description "Show active profile"
    if contains -- "$argv[1]" --help -h
        printf "Show the currently active profile\n"
        printf "\n"
        printf "Usage: fedpunk profile current\n"
        return 0
    end

    if test -L "$FEDPUNK_ROOT/.active-config"
        set -l active_profile (basename (readlink "$FEDPUNK_ROOT/.active-config"))
        printf "Active profile: %s\n" "$active_profile"
    else
        printf "No active profile (no .active-config symlink)\n" >&2
        return 1
    end
end

function activate --description "Activate a profile"
    if contains -- "$argv[1]" --help -h
        printf "Activate a profile by name\n"
        printf "\n"
        printf "Usage: fedpunk profile activate <name>\n"
        printf "\n"
        printf "Examples:\n"
        printf "  fedpunk profile activate dev\n"
        printf "  fedpunk profile activate default\n"
        return 0
    end

    set -l profile_name $argv[1]
    if test -z "$profile_name"
        printf "Error: Profile name required\n" >&2
        printf "Usage: fedpunk profile activate <name>\n" >&2
        return 1
    end

    # Delegate to existing script
    set -l script "$HOME/.local/bin/fedpunk-activate-profile"
    if test -x "$script"
        exec $script $profile_name
    else
        printf "Error: fedpunk-activate-profile not found\n" >&2
        return 1
    end
end

function select --description "Select profile interactively"
    if contains -- "$argv[1]" --help -h
        printf "Interactive profile selector using TUI\n"
        printf "\n"
        printf "Usage: fedpunk profile select\n"
        printf "\n"
        printf "Requires: gum\n"
        return 0
    end

    if not command -v gum >/dev/null 2>&1
        printf "Error: gum is required for TUI mode\n" >&2
        printf "Install with: sudo dnf install gum\n" >&2
        return 1
    end

    set -l profiles_dir "$FEDPUNK_ROOT/profiles"
    if not test -d "$profiles_dir"
        printf "No profiles directory found\n" >&2
        return 1
    end

    # Get list of profiles
    set -l profiles
    for profile_dir in $profiles_dir/*/
        if test -d "$profile_dir"
            set -a profiles (basename "$profile_dir")
        end
    end

    if test (count $profiles) -eq 0
        printf "No profiles found\n" >&2
        return 1
    end

    # Get current profile for display
    set -l current_profile ""
    if test -L "$FEDPUNK_ROOT/.active-config"
        set current_profile (basename (readlink "$FEDPUNK_ROOT/.active-config"))
    end

    # Build display list with markers
    set -l display_list
    for p in $profiles
        if test "$p" = "$current_profile"
            set -a display_list "$p (active)"
        else
            set -a display_list "$p"
        end
    end

    # Show interactive selector
    set -l selected (gum choose --header "Select a profile to activate:" $display_list)

    if test -z "$selected"
        printf "No profile selected\n"
        return 0
    end

    # Remove " (active)" marker if present
    set -l profile_name (string replace " (active)" "" "$selected")

    # Activate the selected profile
    activate $profile_name
end

function create --description "Create new profile from template"
    if contains -- "$argv[1]" --help -h
        printf "Create a new profile from an existing template\n"
        printf "\n"
        printf "Usage: fedpunk profile create [name]\n"
        printf "\n"
        printf "If name is not provided, you'll be prompted interactively.\n"
        printf "\n"
        printf "Requires: gum\n"
        return 0
    end

    if not command -v gum >/dev/null 2>&1
        printf "Error: gum is required for TUI mode\n" >&2
        printf "Install with: sudo dnf install gum\n" >&2
        return 1
    end

    # Get profile name
    set -l new_profile_name $argv[1]
    if test -z "$new_profile_name"
        set new_profile_name (gum input --placeholder "Enter new profile name (e.g., myprofile)")
    end

    if test -z "$new_profile_name"
        printf "Profile name is required\n" >&2
        return 1
    end

    set -l profiles_dir "$FEDPUNK_ROOT/profiles"
    set -l new_profile_path "$profiles_dir/$new_profile_name"

    # Check if profile already exists
    if test -d "$new_profile_path"
        printf "Error: Profile '%s' already exists\n" "$new_profile_name" >&2
        return 1
    end

    # Ask which template to use
    set -l template (gum choose --header "Select template to copy from:" "example" "default" "dev")

    if test -z "$template"
        printf "No template selected\n"
        return 0
    end

    # Copy template
    printf "Creating profile '%s' from template '%s'...\n" "$new_profile_name" "$template"
    cp -r "$profiles_dir/$template" "$new_profile_path"

    # Update fedpunk.toml metadata
    if test -f "$new_profile_path/fedpunk.toml"
        # Prompt for profile metadata
        set -l profile_desc (gum input --placeholder "Profile description" --value "My custom Fedpunk profile")
        set -l profile_author (gum input --placeholder "Author name" --value (whoami))

        # Update TOML file
        sed -i "s/^name = .*/name = \"$new_profile_name\"/" "$new_profile_path/fedpunk.toml"
        sed -i "s/^description = .*/description = \"$profile_desc\"/" "$new_profile_path/fedpunk.toml"
        sed -i "s/^author = .*/author = \"$profile_author\"/" "$new_profile_path/fedpunk.toml"
    end

    printf "✓ Profile created: %s\n" "$new_profile_path"
    printf "\n"

    # Ask if they want to activate it now
    if gum confirm "Activate this profile now?"
        activate $new_profile_name
    else
        printf "Profile created but not activated.\n"
        printf "To activate later, run: fedpunk profile activate %s\n" "$new_profile_name"
    end
end
