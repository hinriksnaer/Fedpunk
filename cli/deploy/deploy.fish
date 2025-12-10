# Deploy command - deploy profiles and modules

function deploy --description "Deploy profiles and modules"
    if contains -- "$argv[1]" --help -h
        printf "Deploy profiles, modules, or current configuration\n"
        printf "\n"
        printf "Usage:\n"
        printf "  fedpunk deploy                    # Deploy from config file\n"
        printf "  fedpunk deploy profile [name]     # Deploy profile\n"
        printf "  fedpunk deploy module <name>      # Deploy single module\n"
        printf "\n"
        printf "Examples:\n"
        printf "  fedpunk deploy profile default --mode container\n"
        printf "  fedpunk deploy module fish\n"
        printf "  fedpunk deploy module git@github.com:user/module.git\n"
        return 0
    end

    # Source deployer library
    if not functions -q deployer-deploy-from-config
        source "$FEDPUNK_SYSTEM/lib/fish/deployer.fish"
    end

    set -l subcommand $argv[1]

    if test -z "$subcommand"
        # No subcommand: deploy from config
        deployer-deploy-from-config
        return $status
    end

    switch $subcommand
        case profile
            deployer-deploy-profile $argv[2..-1]
        case module
            if test (count $argv) -lt 2
                printf "Error: module name or URL required\n" >&2
                printf "Usage: fedpunk deploy module <name-or-url>\n" >&2
                return 1
            end
            deployer-deploy-module $argv[2..-1]
        case '*'
            printf "Unknown subcommand: $subcommand\n" >&2
            printf "Run 'fedpunk deploy --help' for usage\n" >&2
            return 1
    end
end
