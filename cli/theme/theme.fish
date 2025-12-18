# Theme management commands

function theme --description "Theme management"
    if contains -- "$argv[1]" --help -h
        printf "Theme management for Fedpunk\n"
        printf "\n"
        printf "Themes control colors across Hyprland, Kitty, Neovim, Waybar, and more.\n"
        printf "Themes are provided by your active profile.\n"
        return 0
    end
    _show_command_help theme
end

function use --description "Switch to a theme"
    if contains -- "$argv[1]" --help -h
        printf "Switch to a specific theme by name\n"
        printf "\n"
        printf "Usage: fedpunk theme use [name]\n"
        printf "\n"
        printf "If no name provided, shows interactive selector (TUI).\n"
        printf "\n"
        printf "Examples:\n"
        printf "  fedpunk theme use            # TUI selector\n"
        printf "  fedpunk theme use nord       # Direct set\n"
        return 0
    end

    # Get active profile
    set -l active_config "$FEDPUNK_USER/.active-config"
    if not test -L "$active_config"
        printf "Error: No active profile set\n" >&2
        printf "Deploy a profile first: fedpunk profile deploy <url>\n" >&2
        return 1
    end

    set -l active_profile (readlink -f "$active_config")
    set -l themes_dir "$active_profile/themes"

    if not test -d "$themes_dir"
        printf "Error: Active profile does not have themes\n" >&2
        return 1
    end

    # Get available themes
    set -l themes
    for theme_dir in $themes_dir/*/
        if test -d "$theme_dir"
            set -a themes (basename "$theme_dir")
        end
    end

    if test (count $themes) -eq 0
        printf "Error: No themes found in profile\n" >&2
        return 1
    end

    # If theme name provided, validate it
    if test (count $argv) -gt 0
        set -l theme_name $argv[1]
        if not contains -- "$theme_name" $themes
            printf "Error: Theme '$theme_name' not found\n" >&2
            printf "Available themes: %s\n" (string join ", " $themes) >&2
            return 1
        end
    else
        # Interactive selection
        set -l theme_name (printf "%s\n" $themes | gum choose --header "Select theme:")
        or return 1
    end

    # Execute theme-set script from profile
    set -l script "$active_profile/scripts/fedpunk-theme-set"
    if test -x "$script"
        exec $script $theme_name
    else
        printf "Error: fedpunk-theme-set script not found in profile\n" >&2
        return 1
    end
end

function list --description "List available themes"
    if contains -- "$argv[1]" --help -h
        printf "List all available themes\n"
        printf "\n"
        printf "Usage: fedpunk theme list\n"
        return 0
    end

    # Get active profile
    set -l active_config "$FEDPUNK_USER/.active-config"
    if not test -L "$active_config"
        printf "Error: No active profile set\n" >&2
        return 1
    end

    set -l active_profile (readlink -f "$active_config")
    set -l script "$active_profile/scripts/fedpunk-theme-list"

    if test -x "$script"
        exec $script
    else
        # Fallback: just list theme directories
        set -l themes_dir "$active_profile/themes"
        if test -d "$themes_dir"
            for theme_dir in $themes_dir/*/
                if test -d "$theme_dir"
                    basename "$theme_dir"
                end
            end
        else
            printf "Error: No themes directory in profile\n" >&2
            return 1
        end
    end
end

function current --description "Show current theme"
    if contains -- "$argv[1]" --help -h
        printf "Show the currently active theme\n"
        printf "\n"
        printf "Usage: fedpunk theme current\n"
        return 0
    end

    # Get active profile
    set -l active_config "$FEDPUNK_USER/.active-config"
    if not test -L "$active_config"
        printf "Error: No active profile set\n" >&2
        return 1
    end

    set -l active_profile (readlink -f "$active_config")
    set -l script "$active_profile/scripts/fedpunk-theme-current"

    if test -x "$script"
        exec $script
    else
        # Fallback: check for theme state file
        set -l theme_state "$HOME/.local/state/fedpunk/current-theme"
        if test -f "$theme_state"
            cat "$theme_state"
        else
            printf "No theme set\n" >&2
            return 1
        end
    end
end

function select --description "Interactive theme selector"
    if contains -- "$argv[1]" --help -h
        printf "Interactive theme selector using fzf\n"
        printf "\n"
        printf "Usage: fedpunk theme select\n"
        return 0
    end

    # Get active profile
    set -l active_config "$FEDPUNK_USER/.active-config"
    if not test -L "$active_config"
        printf "Error: No active profile set\n" >&2
        return 1
    end

    set -l active_profile (readlink -f "$active_config")
    set -l script "$active_profile/scripts/fedpunk-theme-select-cli"

    if test -x "$script"
        exec $script
    else
        # Fallback to 'use' command which has TUI selector
        use
    end
end

function next --description "Switch to next theme"
    if contains -- "$argv[1]" --help -h
        printf "Switch to the next theme in the list\n"
        printf "\n"
        printf "Usage: fedpunk theme next\n"
        return 0
    end

    # Get active profile
    set -l active_config "$FEDPUNK_USER/.active-config"
    if not test -L "$active_config"
        printf "Error: No active profile set\n" >&2
        return 1
    end

    set -l active_profile (readlink -f "$active_config")
    set -l script "$active_profile/scripts/fedpunk-theme-next"

    if test -x "$script"
        exec $script
    else
        printf "Error: fedpunk-theme-next script not found in profile\n" >&2
        return 1
    end
end

function prev --description "Switch to previous theme"
    if contains -- "$argv[1]" --help -h
        printf "Switch to the previous theme in the list\n"
        printf "\n"
        printf "Usage: fedpunk theme prev\n"
        return 0
    end

    # Get active profile
    set -l active_config "$FEDPUNK_USER/.active-config"
    if not test -L "$active_config"
        printf "Error: No active profile set\n" >&2
        return 1
    end

    set -l active_profile (readlink -f "$active_config")
    set -l script "$active_profile/scripts/fedpunk-theme-prev"

    if test -x "$script"
        exec $script
    else
        printf "Error: fedpunk-theme-prev script not found in profile\n" >&2
        return 1
    end
end

function refresh --description "Refresh current theme"
    if contains -- "$argv[1]" --help -h
        printf "Refresh the current theme (reapply all colors)\n"
        printf "\n"
        printf "Usage: fedpunk theme refresh\n"
        return 0
    end

    # Get active profile
    set -l active_config "$FEDPUNK_USER/.active-config"
    if not test -L "$active_config"
        printf "Error: No active profile set\n" >&2
        return 1
    end

    set -l active_profile (readlink -f "$active_config")
    set -l script "$active_profile/scripts/fedpunk-theme-refresh"

    if test -x "$script"
        exec $script
    else
        printf "Error: fedpunk-theme-refresh script not found in profile\n" >&2
        return 1
    end
end
