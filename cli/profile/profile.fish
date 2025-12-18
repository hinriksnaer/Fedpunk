#!/usr/bin/env fish
# Profile management commands

# Main function - required for bin to discover this command
function profile --description "Manage profiles"
    # No-op: bin handles subcommand routing
end

function list --description "List available profiles"
    if contains -- "$argv[1]" --help -h
        printf "List all available profiles\n"
        printf "\n"
        printf "Usage: fedpunk profile list\n"
        return 0
    end

    # Source profile-discovery library
    if not functions -q profile-list-all
        source "$FEDPUNK_SYSTEM/lib/fish/profile-discovery.fish"
    end

    # Source config library for active profile
    if not functions -q fedpunk-config-get
        source "$FEDPUNK_SYSTEM/lib/fish/config.fish"
    end

    set -l active_profile (fedpunk-config-get "profile" 2>/dev/null)

    printf "Available profiles:\n"
    for line in (profile-list-all)
        set -l parts (string split "|" -- $line)
        set -l name $parts[1]
        set -l source $parts[3]
        set -l active_marker ""

        if test "$name" = "$active_profile"
            set active_marker " (active)"
        end

        printf "  • %s [%s]%s\n" "$name" "$source" "$active_marker"
    end
end

function current --description "Show active profile"
    if contains -- "$argv[1]" --help -h
        printf "Show the currently active profile\n"
        printf "\n"
        printf "Usage: fedpunk profile current\n"
        return 0
    end

    if test -L "$FEDPUNK_ROOT/.active-config"
        set -l active_profile (basename (readlink "$FEDPUNK_ROOT/.active-config"))
        printf "Active profile: %s\n" "$active_profile"
    else
        printf "No active profile (no .active-config symlink)\n" >&2
        return 1
    end
end

function deploy --description "Deploy a profile"
    if contains -- "$argv[1]" --help -h
        printf "Deploy a profile and its modules\n"
        printf "\n"
        printf "Usage: fedpunk profile deploy <name> [options]\n"
        printf "\n"
        printf "Examples:\n"
        printf "  fedpunk profile deploy default\n"
        printf "  fedpunk profile deploy default --mode container\n"
        return 0
    end

    # Source deployer library
    if not functions -q deployer-deploy-profile
        source "$FEDPUNK_SYSTEM/lib/fish/deployer.fish"
    end

    # Deploy profile with all arguments
    deployer-deploy-profile $argv
end

function select --description "Select profile interactively"
    if contains -- "$argv[1]" --help -h
        printf "Interactive profile selector using TUI\n"
        printf "\n"
        printf "Usage: fedpunk profile select\n"
        printf "\n"
        printf "Note: Fedpunk unstable uses external profiles.\n"
        printf "This command helps you select from previously cached profiles.\n"
        printf "\n"
        printf "To deploy a new profile:\n"
        printf "  fedpunk profile deploy <git-url> --mode <mode>\n"
        printf "\n"
        printf "Requires: gum\n"
        return 0
    end

    if not command -v gum >/dev/null 2>&1
        printf "Error: gum is required for TUI mode\n" >&2
        printf "Install with: sudo dnf install gum\n" >&2
        return 1
    end

    # Check for cached external profiles
    set -l cache_dir "$FEDPUNK_USER/cache/external"
    set -l user_profiles_dir "$HOME/.config/fedpunk/profiles"

    set -l profiles
    set -l profile_paths

    # Find cached external profiles
    if test -d "$cache_dir"
        for profile_dir in $cache_dir/*/*/*/*
            if test -d "$profile_dir/modes"
                set -l profile_name (string replace "$cache_dir/" "" "$profile_dir")
                set -a profiles "$profile_name (cached)"
                set -a profile_paths "$profile_dir"
            end
        end
    end

    # Find user-created profiles
    if test -d "$user_profiles_dir"
        for profile_dir in $user_profiles_dir/*/
            if test -d "$profile_dir/modes"
                set -l profile_name (basename "$profile_dir")
                set -a profiles "$profile_name (local)"
                set -a profile_paths "$profile_dir"
            end
        end
    end

    if test (count $profiles) -eq 0
        printf "No profiles found\n" >&2
        printf "\n"
        printf "Deploy a profile first:\n"
        printf "  fedpunk profile deploy https://github.com/hinriksnaer/hyprpunk.git\n"
        printf "\n"
        printf "Or create a custom profile:\n"
        printf "  fedpunk profile create myprofile\n"
        return 1
    end

    # Show interactive selector
    set -l selected (gum choose --header "Select a profile:" $profiles)

    if test -z "$selected"
        printf "No profile selected\n"
        return 0
    end

    # Find the corresponding path
    set -l selected_index 1
    for i in (seq 1 (count $profiles))
        if test "$profiles[$i]" = "$selected"
            set selected_index $i
            break
        end
    end

    set -l profile_path $profile_paths[$selected_index]

    # Deploy the selected profile
    deploy $profile_path
end

function create --description "Create new custom profile"
    if contains -- "$argv[1]" --help -h
        printf "Create a new custom profile in ~/.config/fedpunk/profiles/\n"
        printf "\n"
        printf "Usage: fedpunk profile create [name]\n"
        printf "\n"
        printf "Creates a minimal profile structure that you can customize.\n"
        printf "Profiles are git repositories containing modes/ and optionally plugins/\n"
        printf "\n"
        printf "After creating, you can:\n"
        printf "  1. Edit modes/<mode>/mode.yaml to define module lists\n"
        printf "  2. Add custom modules in plugins/\n"
        printf "  3. Deploy with: fedpunk profile deploy ~/.config/fedpunk/profiles/<name>\n"
        printf "\n"
        printf "Or publish to GitHub and deploy via URL:\n"
        printf "  fedpunk profile deploy https://github.com/user/profile.git\n"
        return 0
    end

    if not command -v gum >/dev/null 2>&1
        printf "Error: gum is required for TUI mode\n" >&2
        printf "Install with: sudo dnf install gum\n" >&2
        return 1
    end

    # Get profile name
    set -l new_profile_name $argv[1]
    if test -z "$new_profile_name"
        set new_profile_name (gum input --placeholder "Enter new profile name (e.g., myprofile)")
    end

    if test -z "$new_profile_name"
        printf "Profile name is required\n" >&2
        return 1
    end

    set -l profiles_dir "$HOME/.config/fedpunk/profiles"
    set -l new_profile_path "$profiles_dir/$new_profile_name"

    # Check if profile already exists
    if test -d "$new_profile_path"
        printf "Error: Profile '%s' already exists at %s\n" "$new_profile_name" "$new_profile_path" >&2
        return 1
    end

    # Create profile structure
    printf "Creating profile '%s'...\n" "$new_profile_name"
    mkdir -p "$new_profile_path/modes/desktop"
    mkdir -p "$new_profile_path/modes/container"
    mkdir -p "$new_profile_path/plugins"

    # Create README
    echo "# $new_profile_name" > "$new_profile_path/README.md"
    echo "" >> "$new_profile_path/README.md"
    echo "Custom Fedpunk profile." >> "$new_profile_path/README.md"
    echo "" >> "$new_profile_path/README.md"
    echo "## Usage" >> "$new_profile_path/README.md"
    echo "" >> "$new_profile_path/README.md"
    echo "Deploy this profile:" >> "$new_profile_path/README.md"
    echo '```bash' >> "$new_profile_path/README.md"
    echo "fedpunk profile deploy $new_profile_path --mode desktop" >> "$new_profile_path/README.md"
    echo '```' >> "$new_profile_path/README.md"
    echo "" >> "$new_profile_path/README.md"
    echo "Or publish to GitHub:" >> "$new_profile_path/README.md"
    echo '```bash' >> "$new_profile_path/README.md"
    echo "cd $new_profile_path" >> "$new_profile_path/README.md"
    echo "git init" >> "$new_profile_path/README.md"
    echo "git add ." >> "$new_profile_path/README.md"
    echo 'git commit -m "Initial commit"' >> "$new_profile_path/README.md"
    echo "gh repo create $new_profile_name --public --source=. --push" >> "$new_profile_path/README.md"
    echo "fedpunk profile deploy https://github.com/\$(whoami)/$new_profile_name.git" >> "$new_profile_path/README.md"
    echo '```' >> "$new_profile_path/README.md"

    # Create desktop mode
    echo "mode:" > "$new_profile_path/modes/desktop/mode.yaml"
    echo "  name: desktop" >> "$new_profile_path/modes/desktop/mode.yaml"
    echo "  description: Desktop environment" >> "$new_profile_path/modes/desktop/mode.yaml"
    echo "" >> "$new_profile_path/modes/desktop/mode.yaml"
    echo "modules:" >> "$new_profile_path/modes/desktop/mode.yaml"
    echo "  - essentials" >> "$new_profile_path/modes/desktop/mode.yaml"
    echo "  - ssh" >> "$new_profile_path/modes/desktop/mode.yaml"
    echo "  # Add more modules here" >> "$new_profile_path/modes/desktop/mode.yaml"

    # Create container mode
    echo "mode:" > "$new_profile_path/modes/container/mode.yaml"
    echo "  name: container" >> "$new_profile_path/modes/container/mode.yaml"
    echo "  description: Container/server environment" >> "$new_profile_path/modes/container/mode.yaml"
    echo "" >> "$new_profile_path/modes/container/mode.yaml"
    echo "modules:" >> "$new_profile_path/modes/container/mode.yaml"
    echo "  - essentials" >> "$new_profile_path/modes/container/mode.yaml"
    echo "  - ssh" >> "$new_profile_path/modes/container/mode.yaml"
    echo "  # Add more modules here" >> "$new_profile_path/modes/container/mode.yaml"

    # Create .gitignore
    echo "# Temporary files" > "$new_profile_path/.gitignore"
    echo "*.swp" >> "$new_profile_path/.gitignore"
    echo "*.swo" >> "$new_profile_path/.gitignore"
    echo "*~" >> "$new_profile_path/.gitignore"
    echo ".DS_Store" >> "$new_profile_path/.gitignore"

    printf "✓ Profile created: %s\n" "$new_profile_path"
    printf "\n"
    printf "Next steps:\n"
    printf "  1. cd %s\n" "$new_profile_path"
    printf "  2. Edit modes/desktop/mode.yaml to customize modules\n"
    printf "  3. Deploy: fedpunk profile deploy %s --mode desktop\n" "$new_profile_path"
    printf "\n"
    printf "To publish to GitHub:\n"
    printf "  git init && git add . && git commit -m 'Initial commit'\n"
    printf "  gh repo create $new_profile_name --public --source=. --push\n"
end
