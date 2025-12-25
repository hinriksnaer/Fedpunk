#!/usr/bin/env fish
# Apply configuration command

function apply --description "Apply Fedpunk configuration"
    # Show help if --help
    if contains -- "$argv[1]" --help -h
        printf "Apply Fedpunk configuration from config file\n"
        printf "\n"
        printf "Usage: fedpunk apply\n"
        printf "\n"
        printf "Reads profile and mode from ~/.config/fedpunk/fedpunk.yaml\n"
        printf "and deploys the configured modules.\n"
        printf "\n"
        printf "Workflow:\n"
        printf "  1. fedpunk profile deploy <url> --mode <mode>  # Deploy a profile\n"
        printf "  2. fedpunk config edit                         # Customize modules\n"
        printf "  3. fedpunk apply                               # Apply changes\n"
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
        printf "✓ Configuration applied successfully!\n"
        printf "\n"
        printf "Run 'exec fish' to reload your shell if needed.\n"
    else
        printf "\n"
        printf "✗ Apply failed\n" >&2
        return 1
    end
end
