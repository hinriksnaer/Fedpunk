#!/usr/bin/env fish
# Module management commands

function module --description "Module management"
    # Show help if no args or --help
    if test (count $argv) -eq 0; or contains -- "$argv[1]" --help -h
        printf "Module management for Fedpunk\n"
        printf "\n"
        printf "Modules are self-contained packages of configuration, packages, and scripts.\n"
        printf "\n"
        printf "Usage: fedpunk module <subcommand> [options]\n"
        printf "\n"
        printf "Subcommands:\n"
        printf "  list       List available modules\n"
        printf "  info       Show module information\n"
        printf "  deploy     Deploy a module\n"
        printf "  remove     Remove a module\n"
        printf "  state      Show deployed modules\n"
        printf "\n"
        printf "Run 'fedpunk module <subcommand> --help' for more information.\n"
        return 0
    end

    # Dispatch to subcommand
    set -l subcommand $argv[1]

    switch $subcommand
        case list
            list $argv[2..-1]
        case info
            info $argv[2..-1]
        case deploy
            deploy $argv[2..-1]
        case remove
            remove $argv[2..-1]
        case state
            state $argv[2..-1]
        case '*'
            printf "Unknown subcommand: $subcommand\n" >&2
            printf "Run 'fedpunk module --help' for available subcommands.\n" >&2
            return 1
    end
end

# Source the module library
function _ensure_module_lib
    if not functions -q fedpunk-module
        source "$FEDPUNK_ROOT/lib/fish/fedpunk-module.fish"
    end
end

function list --description "List available modules"
    if contains -- "$argv[1]" --help -h
        printf "List all available modules\n"
        printf "\n"
        printf "Usage: fedpunk module list\n"
        return 0
    end

    _ensure_module_lib
    fedpunk-module list
end

function info --description "Show module information"
    if contains -- "$argv[1]" --help -h
        printf "Show detailed information about a module\n"
        printf "\n"
        printf "Usage: fedpunk module info <name>\n"
        printf "\n"
        printf "Examples:\n"
        printf "  fedpunk module info fish\n"
        printf "  fedpunk module info hyprland\n"
        return 0
    end

    set -l module_name $argv[1]
    if test -z "$module_name"
        printf "Error: Module name required\n" >&2
        printf "Usage: fedpunk module info <name>\n" >&2
        return 1
    end

    _ensure_module_lib
    fedpunk-module info $module_name
end

function deploy --description "Deploy a module"
    if contains -- "$argv[1]" --help -h
        printf "Deploy a module (install packages + config + lifecycle scripts)\n"
        printf "\n"
        printf "Usage: fedpunk module deploy [name]\n"
        printf "\n"
        printf "If no name provided, shows interactive selector.\n"
        printf "\n"
        printf "Examples:\n"
        printf "  fedpunk module deploy           # Interactive\n"
        printf "  fedpunk module deploy hyprland\n"
        printf "  fedpunk module deploy neovim\n"
        return 0
    end

    _ensure_module_lib

    set -l module_name $argv[1]

    # If no module specified, show TUI selector
    if test -z "$module_name"
        # Build list of modules
        set -l modules_dir "$FEDPUNK_ROOT/modules"
        set -l module_list

        for module_dir in $modules_dir/*
            if test -d "$module_dir" -a -f "$module_dir/module.yaml"
                set -a module_list (basename "$module_dir")
            end
        end

        # Add profile plugins
        set -l active_config "$FEDPUNK_ROOT/.active-config"
        if test -L "$active_config"
            set -l profile_dir (readlink -f "$active_config")
            set -l plugins_dir "$profile_dir/plugins"

            if test -d "$plugins_dir"
                for plugin_dir in $plugins_dir/*
                    if test -d "$plugin_dir" -a -f "$plugin_dir/module.yaml"
                        set -a module_list "plugins/"(basename "$plugin_dir")
                    end
                end
            end
        end

        if test -z "$module_list"
            printf "Error: No modules found\n" >&2
            return 1
        end

        # Use gum directly for interactive selection
        if command -v gum >/dev/null 2>&1
            set module_name (printf "%s\n" $module_list | gum filter --placeholder "Search modules...")
        else
            # Fallback to simple choose
            set module_name (ui-choose --header "Select module to deploy:" $module_list)
        end

        if test -z "$module_name"
            printf "Cancelled\n"
            return 1
        end
    end

    fedpunk-module deploy $module_name
end

function remove --description "Remove a module"
    if contains -- "$argv[1]" --help -h
        printf "Remove a module (unstow config files)\n"
        printf "\n"
        printf "Usage: fedpunk module remove <name>\n"
        printf "\n"
        printf "Note: This does not uninstall packages.\n"
        return 0
    end

    set -l module_name $argv[1]
    if test -z "$module_name"
        printf "Error: Module name required\n" >&2
        printf "Usage: fedpunk module remove <name>\n" >&2
        return 1
    end

    _ensure_module_lib
    fedpunk-module unstow $module_name
end

function state --description "Show deployed modules"
    if contains -- "$argv[1]" --help -h
        printf "Show deployment state of modules\n"
        printf "\n"
        printf "Usage: fedpunk module state\n"
        return 0
    end

    if test -f "$FEDPUNK_ROOT/.linker-state.json"
        source "$FEDPUNK_ROOT/lib/fish/linker.fish"
        linker-status
    else
        printf "No deployment state found\n"
        printf "Module state tracking requires the linker\n"
    end
end

# Execute the command
module $argv
