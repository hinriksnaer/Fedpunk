# Theme management commands

function theme --description "Theme management"
    if contains -- "$argv[1]" --help -h
        printf "Theme management for Fedpunk\n"
        printf "\n"
        printf "Themes control colors across Hyprland, Kitty, Neovim, Waybar, and more.\n"
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

    # Get available themes
    set -l themes_dir "$FEDPUNK_ROOT/themes"
    set -l themes
    if test -d "$themes_dir"
        for theme_dir in $themes_dir/*/
            if test -d "$theme_dir"
                set -a themes (basename "$theme_dir")
            end
        end
    end

    # Smart select: TUI if no arg + interactive, otherwise validate arg
    set -l theme_name (ui-select-smart \
        --value "$argv[1]" \
        --header "Select theme:" \
        --options $themes)
    or return 1

    # Execute
    set -l script "$HOME/.local/bin/fedpunk-theme-set"
    if test -x "$script"
        exec $script $theme_name
    else
        printf "Error: fedpunk-theme-set not found\n" >&2
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

    set -l script "$HOME/.local/bin/fedpunk-theme-list"
    if test -x "$script"
        exec $script
    else
        printf "Error: fedpunk-theme-list not found\n" >&2
        return 1
    end
end

function current --description "Show current theme"
    if contains -- "$argv[1]" --help -h
        printf "Show the currently active theme\n"
        printf "\n"
        printf "Usage: fedpunk theme current\n"
        return 0
    end

    set -l script "$HOME/.local/bin/fedpunk-theme-current"
    if test -x "$script"
        exec $script
    else
        printf "Error: fedpunk-theme-current not found\n" >&2
        return 1
    end
end

function select --description "Interactive theme selector"
    if contains -- "$argv[1]" --help -h
        printf "Interactive theme selector using fzf\n"
        printf "\n"
        printf "Usage: fedpunk theme select\n"
        return 0
    end

    set -l script "$HOME/.local/bin/fedpunk-theme-select-cli"
    if test -x "$script"
        exec $script
    else
        printf "Error: fedpunk-theme-select-cli not found\n" >&2
        return 1
    end
end

function next --description "Switch to next theme"
    if contains -- "$argv[1]" --help -h
        printf "Switch to the next theme in the list\n"
        printf "\n"
        printf "Usage: fedpunk theme next\n"
        return 0
    end

    set -l script "$HOME/.local/bin/fedpunk-theme-next"
    if test -x "$script"
        exec $script
    else
        printf "Error: fedpunk-theme-next not found\n" >&2
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

    set -l script "$HOME/.local/bin/fedpunk-theme-prev"
    if test -x "$script"
        exec $script
    else
        printf "Error: fedpunk-theme-prev not found\n" >&2
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

    set -l script "$HOME/.local/bin/fedpunk-theme-refresh"
    if test -x "$script"
        exec $script
    else
        printf "Error: fedpunk-theme-refresh not found\n" >&2
        return 1
    end
end
