# Sync configuration command

function sync --description "Pull latest changes and apply"
    if contains -- "$argv[1]" --help -h
        printf "Sync dotfiles from git and apply changes\n"
        printf "\n"
        printf "Usage: fedpunk sync\n"
        printf "\n"
        printf "This will:\n"
        printf "  1. Check for uncommitted local changes\n"
        printf "  2. Pull latest from git origin\n"
        printf "  3. Apply configuration using chezmoi\n"
        return 0
    end

    printf "Syncing Fedpunk configuration...\n"
    printf "\n"

    # Check if we're in a git repo
    if not test -d "$FEDPUNK_ROOT/.git"
        printf "Error: Not a git repository\n" >&2
        return 1
    end

    set -l original_dir (pwd)
    cd "$FEDPUNK_ROOT"

    # Check for uncommitted changes
    if not git diff-index --quiet HEAD -- 2>/dev/null
        printf "⚠️  Warning: You have uncommitted local changes\n"
        printf "\n"
        git status --short
        printf "\n"
        read -P "Continue with sync anyway? [y/N] " -n 1 confirm
        printf "\n"
        if test "$confirm" != "y" -a "$confirm" != "Y"
            printf "Sync cancelled\n"
            cd "$original_dir"
            return 0
        end
    end

    # Pull latest changes
    printf "→ Pulling latest changes from origin...\n"
    if git pull
        printf "✓ Git pull successful\n"
    else
        printf "✗ Git pull failed\n" >&2
        cd "$original_dir"
        return 1
    end

    printf "\n"

    # Apply chezmoi changes
    printf "→ Applying configuration changes...\n"
    if command -v chezmoi >/dev/null 2>&1
        if chezmoi apply
            printf "✓ Configuration applied\n"
        else
            printf "✗ Chezmoi apply failed\n" >&2
            cd "$original_dir"
            return 1
        end
    else
        printf "⚠️  Chezmoi not installed, skipping config apply\n"
    end

    cd "$original_dir"

    printf "\n"
    printf "✓ Sync complete!\n"
    printf "\n"
    printf "Note: Profile and theme changes are already active.\n"
    printf "Run 'exec fish' to reload your shell if needed.\n"
end
