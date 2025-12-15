#!/usr/bin/env fish
# Module management commands

# Main function - required for bin to discover this command
function module --description "Deploy modules"
    # No-op: bin handles subcommand routing
end

function deploy --description "Deploy a module"
    if contains -- "$argv[1]" --help -h
        printf "Deploy a module (install packages + config + lifecycle scripts)\n"
        printf "\n"
        printf "Usage: fedpunk module deploy <name|url>\n"
        printf "\n"
        printf "Modules are added to ~/.config/fedpunk/fedpunk.yaml\n"
        printf "Run 'fedpunk apply' to re-apply configuration.\n"
        printf "\n"
        printf "Examples:\n"
        printf "  fedpunk module deploy neovim\n"
        printf "  fedpunk module deploy https://github.com/user/module.git\n"
        return 0
    end

    set -l module_name $argv[1]

    if test -z "$module_name"
        printf "Error: Module name or URL required\n" >&2
        printf "Usage: fedpunk module deploy <name|url>\n" >&2
        printf "\n"
        printf "Examples:\n"
        printf "  fedpunk module deploy neovim\n"
        printf "  fedpunk module deploy https://github.com/user/module.git\n"
        return 1
    end

    # Source deployer library
    if not functions -q deployer-deploy-module
        source "$FEDPUNK_SYSTEM/lib/fish/deployer.fish"
    end

    # Use deployer to deploy and update config
    deployer-deploy-module $module_name
end
