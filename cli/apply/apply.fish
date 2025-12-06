# Apply configuration command

function apply --description "Apply configuration changes"
    if contains -- "$argv[1]" --help -h
        printf "Apply Fedpunk configuration changes\n"
        printf "\n"
        printf "Usage: fedpunk apply\n"
        printf "\n"
        printf "This will re-run the installer to deploy/update modules.\n"
        printf "\n"
        printf "Note: Configs are already live via stow symlinks.\n"
        printf "This updates packages and runs module lifecycle hooks.\n"
        printf "\n"
        printf "Use 'fedpunk sync' to pull from git first.\n"
        return 0
    end

    printf "Applying Fedpunk configuration...\n"
    printf "\n"

    # Check if install.fish exists
    if not test -x "$FEDPUNK_ROOT/install.fish"
        printf "Error: install.fish not found or not executable\n" >&2
        return 1
    end

    # Run installer
    if fish "$FEDPUNK_ROOT/install.fish"
        printf "\n"
        printf "Apply complete!\n"
        printf "\n"
        printf "Run 'exec fish' to reload your shell if needed.\n"
    else
        printf "\n"
        printf "Error: Installer failed\n" >&2
        return 1
    end
end
