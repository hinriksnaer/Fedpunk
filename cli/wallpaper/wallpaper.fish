# Wallpaper management commands

function wallpaper --description "Wallpaper management"
    if contains -- "$argv[1]" --help -h
        printf "Wallpaper management for Fedpunk\n"
        printf "\n"
        printf "Control wallpapers in desktop mode.\n"
        return 0
    end
    _show_command_help wallpaper
end

function use --description "Set wallpaper from theme"
    if contains -- "$argv[1]" --help -h
        printf "Set wallpaper based on a theme\n"
        printf "\n"
        printf "Usage: fedpunk wallpaper use <theme>\n"
        printf "\n"
        printf "Examples:\n"
        printf "  fedpunk wallpaper use nord\n"
        return 0
    end

    set -l theme_name $argv[1]
    if test -z "$theme_name"
        printf "Error: Theme name required\n" >&2
        printf "Usage: fedpunk wallpaper use <theme>\n" >&2
        return 1
    end

    set -l script "$HOME/.local/bin/fedpunk-wallpaper-set"
    if test -x "$script"
        exec $script $theme_name
    else
        printf "Error: fedpunk-wallpaper-set not found\n" >&2
        return 1
    end
end

function next --description "Switch to next wallpaper"
    if contains -- "$argv[1]" --help -h
        printf "Switch to the next wallpaper\n"
        printf "\n"
        printf "Usage: fedpunk wallpaper next\n"
        return 0
    end

    set -l script "$HOME/.local/bin/fedpunk-wallpaper-next"
    if test -x "$script"
        exec $script
    else
        printf "Error: fedpunk-wallpaper-next not found\n" >&2
        return 1
    end
end
