# Apply configuration command

function apply --description "Apply current configuration"
    if contains -- "$argv[1]" --help -h
        printf "Apply current configuration without git pull\n"
        printf "\n"
        printf "Usage: fedpunk apply\n"
        printf "\n"
        printf "This applies local configuration changes using chezmoi.\n"
        printf "Use 'fedpunk sync' to pull from git first.\n"
        return 0
    end

    printf "Applying Fedpunk configuration...\n"
    printf "\n"

    printf "→ Applying configuration changes...\n"
    if command -v chezmoi >/dev/null 2>&1
        if chezmoi apply
            printf "✓ Configuration applied\n"
        else
            printf "✗ Chezmoi apply failed\n" >&2
            return 1
        end
    else
        printf "✗ Chezmoi not installed\n" >&2
        printf "  Install with: sudo dnf install chezmoi\n" >&2
        return 1
    end

    printf "\n"
    printf "✓ Apply complete!\n"
    printf "\n"
    printf "Note: This only applies local changes.\n"
    printf "Run 'fedpunk sync' to pull from git first.\n"
end
