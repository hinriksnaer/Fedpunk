# Init setup wizard command

function init --description "Interactive setup wizard"
    if contains -- "$argv[1]" --help -h
        printf "Interactive setup wizard for Fedpunk\n"
        printf "\n"
        printf "Usage: fedpunk init\n"
        printf "\n"
        printf "This TUI wizard helps you:\n"
        printf "  - Create a new profile\n"
        printf "  - Activate an existing profile\n"
        printf "  - Configure git settings\n"
        printf "\n"
        printf "Requires: gum\n"
        return 0
    end

    if not command -v gum >/dev/null 2>&1
        printf "Error: gum is required for TUI mode\n" >&2
        printf "Install with: sudo dnf install gum\n" >&2
        return 1
    end

    printf "\n"
    gum style --border rounded --padding "1 2" --border-foreground 33 "Fedpunk Setup Wizard"
    printf "\n"

    # Main menu
    set -l choice (gum choose --header "What would you like to do?" \
        "Create a new profile" \
        "Activate an existing profile" \
        "Configure git settings" \
        "Exit")

    switch $choice
        case "Create a new profile"
            # Delegate to profile create
            source "$FEDPUNK_ROOT/cli/profile/profile.fish"
            create

        case "Activate an existing profile"
            # Delegate to profile select
            source "$FEDPUNK_ROOT/cli/profile/profile.fish"
            select

        case "Configure git settings"
            _configure_git

        case "Exit"
            printf "Goodbye!\n"
            return 0
    end
end

function _configure_git
    printf "\n"
    printf "Git Configuration\n"
    printf "━━━━━━━━━━━━━━━━━\n"
    printf "\n"

    # Get current git config if it exists
    set -l current_name (git config --global user.name 2>/dev/null; or echo "")
    set -l current_email (git config --global user.email 2>/dev/null; or echo "")

    set -l git_name (gum input --placeholder "Your name" --value "$current_name")
    set -l git_email (gum input --placeholder "Your email" --value "$current_email")

    if test -n "$git_name"
        git config --global user.name "$git_name"
        printf "✓ Set git user.name = %s\n" "$git_name"
    end

    if test -n "$git_email"
        git config --global user.email "$git_email"
        printf "✓ Set git user.email = %s\n" "$git_email"
    end

    printf "\n"
    printf "Git configuration updated!\n"
end
