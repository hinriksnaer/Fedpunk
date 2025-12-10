# Apply configuration command

function apply --description "Apply configuration changes"
    if contains -- "$argv[1]" --help -h
        printf "Apply Fedpunk configuration based on saved settings\n"
        printf "\n"
        printf "Usage: fedpunk apply\n"
        printf "\n"
        printf "Reads profile and mode from ~/.config/fedpunk/fedpunk.yaml\n"
        printf "and deploys the configured modules.\n"
        printf "\n"
        printf "Alias for: fedpunk deploy\n"
        return 0
    end

    # Source deployer library
    if not functions -q deployer-deploy-from-config
        source "$FEDPUNK_SYSTEM/lib/fish/deployer.fish"
    end

    printf "Applying Fedpunk configuration...\n"
    printf "\n"

    # Deploy from config
    if deployer-deploy-from-config
        printf "\n"
        printf "Apply complete!\n"
        printf "\n"
        printf "Run 'exec fish' to reload your shell if needed.\n"
    else
        printf "\n"
        printf "Error: Deploy failed\n" >&2
        return 1
    end
end
