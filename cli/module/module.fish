# Module management commands

function module --description "Module management"
    if contains -- "$argv[1]" --help -h
        printf "Module management for Fedpunk\n"
        printf "\n"
        printf "Modules are self-contained packages of configuration, packages, and scripts.\n"
        return 0
    end
    _show_command_help module
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
        printf "Usage: fedpunk module deploy <name>\n"
        printf "\n"
        printf "Examples:\n"
        printf "  fedpunk module deploy hyprland\n"
        printf "  fedpunk module deploy neovim\n"
        return 0
    end

    set -l module_name $argv[1]
    if test -z "$module_name"
        printf "Error: Module name required\n" >&2
        printf "Usage: fedpunk module deploy <name>\n" >&2
        return 1
    end

    _ensure_module_lib
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
