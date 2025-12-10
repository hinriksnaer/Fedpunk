# Config command - manage Fedpunk configuration

function config --description "Manage Fedpunk configuration"
    if contains -- "$argv[1]" --help -h
        printf "Manage Fedpunk configuration\n"
        printf "\n"
        printf "Config file: ~/.config/fedpunk/fedpunk.yaml\n"
        printf "\n"
        printf "Usage:\n"
        printf "  fedpunk config show    # Show current configuration\n"
        printf "  fedpunk config edit    # Edit configuration file\n"
        printf "  fedpunk config path    # Show config file path\n"
        return 0
    end
    _show_command_help config
end

function show --description "Show current configuration"
    if contains -- "$argv[1]" --help -h
        printf "Show current configuration\n"
        printf "\n"
        printf "Usage: fedpunk config show\n"
        return 0
    end

    # Source config library
    if not functions -q fedpunk-config-path
        source "$FEDPUNK_SYSTEM/lib/fish/config.fish"
    end

    set -l config_file (fedpunk-config-path)

    if not test -f "$config_file"
        printf "No configuration file found\n"
        printf "Run 'fedpunk deploy profile' to create configuration\n"
        return 0
    end

    printf "Configuration: %s\n\n" "$config_file"
    cat "$config_file"
end

function edit --description "Edit configuration file"
    if contains -- "$argv[1]" --help -h
        printf "Edit configuration file\n"
        printf "\n"
        printf "Usage: fedpunk config edit\n"
        return 0
    end

    # Source config library
    if not functions -q fedpunk-config-path
        source "$FEDPUNK_SYSTEM/lib/fish/config.fish"
    end

    set -l config_file (fedpunk-config-path)

    if not test -f "$config_file"
        fedpunk-config-init
        printf "Created config file: %s\n\n" "$config_file"
    end

    set -l editor $EDITOR
    if test -z "$editor"
        set editor vi
    end

    $editor "$config_file"
end

function path --description "Show config file path"
    if contains -- "$argv[1]" --help -h
        printf "Show config file path\n"
        printf "\n"
        printf "Usage: fedpunk config path\n"
        return 0
    end

    # Source config library
    if not functions -q fedpunk-config-path
        source "$FEDPUNK_SYSTEM/lib/fish/config.fish"
    end

    fedpunk-config-path
end
