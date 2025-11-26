# Doctor command for system diagnostics and dispatcher verification

function doctor --description "System diagnostics and health checks"
    # Group function - called when no subcommand given
    if contains -- "$argv[1]" --help -h
        printf "System diagnostics and health checks\n"
        printf "\n"
        printf "Run fedpunk doctor <subcommand> to diagnose issues.\n"
        return 0
    end
    # Default: show help
    _show_command_help doctor
end

function ping --description "Echo back arguments"
    if contains -- "$argv[1]" --help -h
        printf "Echo back all provided arguments\n"
        printf "\n"
        printf "Usage: fedpunk doctor ping [args...]\n"
        return 0
    end
    printf "Ping: %s\n" "$argv"
end

function greet --description "Greet a user"
    if contains -- "$argv[1]" --help -h
        printf "Greet a user by name\n"
        printf "\n"
        printf "Usage: fedpunk doctor greet [name]\n"
        return 0
    end
    set -l name $argv[1]
    if test -z "$name"
        set name "punk"
    end
    printf "Hey %s, welcome to fedpunk!\n" "$name"
end

function fail --description "Exit with error code"
    if contains -- "$argv[1]" --help -h
        printf "Exit with a specified error code\n"
        printf "\n"
        printf "Usage: fedpunk doctor fail [code]\n"
        return 0
    end
    set -l code $argv[1]
    if test -z "$code"
        set code 1
    end
    printf "Failing with code %s\n" "$code"
    return $code
end

function args --description "Show argument parsing"
    if contains -- "$argv[1]" --help -h
        printf "Display how arguments are parsed\n"
        printf "\n"
        printf "Usage: fedpunk doctor args [args...]\n"
        return 0
    end
    printf "Argument count: %d\n" (count $argv)
    set -l i 1
    for arg in $argv
        printf "  [%d]: %s\n" $i "$arg"
        set i (math $i + 1)
    end
end

# Private helper - should NOT be exposed as subcommand
function _secret
    printf "This should never be callable via dispatcher\n"
end
