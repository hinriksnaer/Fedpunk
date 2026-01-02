#!/usr/bin/env fish
# Fedpunk deployment orchestration
# Separate handlers for module and profile deployment

# Source dependencies
set -l lib_dir (dirname (status -f))
source "$lib_dir/config.fish"
source "$lib_dir/profile-discovery.fish"
source "$lib_dir/ui.fish"
source "$lib_dir/yaml-parser.fish"
source "$lib_dir/fedpunk-module.fish"
source "$lib_dir/module-ref-parser.fish"
source "$lib_dir/external-modules.fish"
source "$lib_dir/param-injector.fish"

#
# MODULE DEPLOYMENT (Independent handler)
#

function deployer-deploy-module
    # Deploy a single module and add it to config
    # Usage: deployer-deploy-module <name-or-git-url>
    # Supports: local module names, git URLs
    # Examples:
    #   deployer-deploy-module fish
    #   deployer-deploy-module git@github.com:user/custom-module.git

    set -l module_ref $argv[1]

    if test -z "$module_ref"
        ui-error "Module name or URL required"
        return 1
    end

    ui-info "Deploying module: $module_ref"

    # Ensure config exists
    if not functions -q fedpunk-config-exists
        source "$FEDPUNK_SYSTEM/lib/fish/config.fish"
    end

    if not fedpunk-config-exists
        fedpunk-config-init
    end

    # Normalize git URLs to module names for consistent config storage
    # git@gitlab.com:org/thinkpad-fans.git -> thinkpad-fans
    set -l module_name "$module_ref"
    if module-ref-is-url "$module_ref"
        # Extract repo name from URL (same logic as external-module-get-storage-path)
        set module_name (string replace -r '\.git$' '' "$module_ref")
        set module_name (string replace -r '^.*[/:]' '' "$module_name")
    end

    # Add normalized module name to config
    fedpunk-config-add-module "$module_name"

    # Use existing fedpunk-module deploy (already handles local + git)
    if fedpunk-module deploy "$module_ref"
        ui-info "Module added to configuration"
        return 0
    else
        return 1
    end
end

#
# PROFILE DEPLOYMENT (Independent handler)
#

function deployer-prompt-profile
    # Interactive profile selection with gum
    # Saves selection to config
    # Returns: profile name

    set -l profiles_output (profile-list-all)

    if test -z "$profiles_output"
        ui-error "No profiles found"
        return 1
    end

    # Build selection list with source labels
    set -l profile_choices
    set -l profile_names
    for line in $profiles_output
        set -l parts (string split "|" -- $line)
        set -l name $parts[1]
        set -l source $parts[3]
        set -a profile_choices "$name ($source)"
        set -a profile_names $name
    end

    ui-info "Available profiles:" >&2
    set -l selected (ui-choose --header "Select profile:" $profile_choices)

    if test -z "$selected"
        ui-error "No profile selected"
        return 1
    end

    # Extract profile name (remove source label)
    set -l profile_name (string replace -r ' \(.*\)$' '' -- "$selected")

    # Save to config
    fedpunk-config-set "profile" "$profile_name"

    echo $profile_name
end

function deployer-prompt-mode
    # Interactive mode selection for a profile
    # Saves selection to config
    # Usage: deployer-prompt-mode <profile-name>
    # Returns: mode name

    set -l profile_name $argv[1]

    if test -z "$profile_name"
        ui-error "Profile name required"
        return 1
    end

    set -l modes (profile-list-modes "$profile_name")

    if test -z "$modes"
        ui-error "No modes found for profile: $profile_name"
        return 1
    end

    # If only one mode, use it
    if test (count $modes) -eq 1
        set -l mode $modes[1]
        fedpunk-config-set "mode" "$mode"
        echo $mode
        return 0
    end

    ui-info "Available modes for $profile_name:" >&2
    set -l selected (ui-choose --header "Select mode:" $modes)

    if test -z "$selected"
        ui-error "No mode selected"
        return 1
    end

    # Save to config
    fedpunk-config-set "mode" "$selected"

    echo $selected
end

function deployer-extract-repo-name
    # Extract repository name from a git URL
    # Usage: deployer-extract-repo-name <url>
    # Returns: repository name (e.g., "hyprpunk" from "git@github.com:user/hyprpunk.git")
    # Examples:
    #   git@github.com:hinriksnaer/hyprpunk.git -> hyprpunk
    #   https://github.com/user/my-profile.git -> my-profile
    #   https://github.com/user/profile -> profile

    set -l url $argv[1]

    # Remove protocol and .git suffix
    set -l normalized (string replace -r '^https?://' '' "$url")
    set normalized (string replace -r '^git@' '' "$normalized")
    set normalized (string replace -r '^ssh://' '' "$normalized")
    set normalized (string replace -r '^file://' '' "$normalized")
    set normalized (string replace -r '\.git$' '' "$normalized")

    # Extract the last component (repo name)
    # github.com:user/repo -> repo
    # github.com/user/repo -> repo
    set -l repo_name (basename "$normalized")

    echo "$repo_name"
end

function deployer-fetch-external-profile
    # Fetch an external profile from a git URL
    # Usage: deployer-fetch-external-profile <url>
    # Returns: path to the cloned profile directory and profile name (space-separated)
    # Clones to: ~/.config/fedpunk/profiles/<repo-name>/
    # This differs from external modules which are cached as dependencies

    set -l url $argv[1]

    # Extract repository name
    set -l repo_name (deployer-extract-repo-name "$url")
    set -l profiles_base "$HOME/.config/fedpunk/profiles"
    set -l profile_path "$profiles_base/$repo_name"

    # Create profiles directory if it doesn't exist
    if not test -d "$profiles_base"
        mkdir -p "$profiles_base"
    end

    if test -d "$profile_path"
        # Directory exists - check if it's a git repository
        if test -d "$profile_path/.git"
            # It's a git repo - check if it's the same remote
            pushd "$profile_path" >/dev/null
            set -l current_remote (git remote get-url origin 2>/dev/null)

            # Normalize URLs for comparison (remove .git suffix and protocol differences)
            set -l normalized_current (string replace -r '\.git$' '' "$current_remote")
            set -l normalized_new (string replace -r '\.git$' '' "$url")
            set normalized_current (string replace -r '^https://github\.com/' 'git@github.com:' "$normalized_current")
            set normalized_new (string replace -r '^https://github\.com/' 'git@github.com:' "$normalized_new")

            if test "$normalized_current" = "$normalized_new"
                # Same repo - pull latest
                ui-info "Updating profile: $repo_name" >&2
                git pull --quiet
                or begin
                    popd >/dev/null
                    ui-error "Failed to update profile: $repo_name"
                    return 1
                end
                popd >/dev/null
            else
                popd >/dev/null
                ui-error "Profile name conflict: '$repo_name' already exists but points to different repository"
                ui-error "Existing: $current_remote"
                ui-error "Requested: $url"
                ui-info "Remove the existing profile or use a different name"
                return 1
            end
        else
            # Directory exists but is not a git repo
            ui-error "Profile name conflict: '$repo_name' exists but is not a git repository"
            ui-info "Path: $profile_path"
            ui-info "Remove the directory or use a different name"
            return 1
        end
    else
        # Clone the repository
        ui-info "Cloning profile: $repo_name from $url" >&2
        git clone --quiet "$url" "$profile_path"
        or begin
            ui-error "Failed to clone profile from: $url"
            return 1
        end
    end

    # Verify modes directory exists
    if not test -d "$profile_path/modes"
        ui-error "Invalid profile: modes/ directory not found in $url"
        return 1
    end

    echo "$profile_path $repo_name"
    return 0
end

function deployer-deploy-profile
    # Deploy a profile with all its modules
    # Usage: deployer-deploy-profile [profile-name-or-url] [--mode MODE] [--conflict MODE]
    # Examples:
    #   deployer-deploy-profile              # Interactive (uses config or prompts)
    #   deployer-deploy-profile default      # Deploy 'default' profile
    #   deployer-deploy-profile --mode desktop  # Use saved profile with desktop mode
    #   deployer-deploy-profile default --mode container
    #   deployer-deploy-profile https://github.com/user/profile.git --mode desktop
    #   deployer-deploy-profile default --conflict overwrite  # Auto-replace conflicts
    #   deployer-deploy-profile default --conflict skip       # Auto-skip conflicts
    #
    # --conflict options:
    #   interactive (default) - Prompt for each conflict
    #   overwrite - Automatically replace conflicting files (with backup)
    #   skip - Automatically keep existing files

    # Parse arguments
    set -l profile_arg ""
    set -l mode_arg ""
    set -l conflict_arg ""
    set -l i 1
    while test $i -le (count $argv)
        if test "$argv[$i]" = "--mode"
            set i (math $i + 1)
            set mode_arg $argv[$i]
        else if test "$argv[$i]" = "--conflict"
            set i (math $i + 1)
            set conflict_arg $argv[$i]
        else
            set profile_arg $argv[$i]
        end
        set i (math $i + 1)
    end

    # Set conflict mode environment variable if specified
    if test -n "$conflict_arg"
        set -gx FEDPUNK_CONFLICT_MODE "$conflict_arg"
    end

    # Get profile (priority: arg > config > prompt)
    set -l profile_name ""
    if test -n "$profile_arg"
        set profile_name "$profile_arg"
    else if set -l saved_profile (fedpunk-config-get "profile")
        set profile_name "$saved_profile"
        ui-info "Using saved profile: $profile_name"
    else
        set profile_name (deployer-prompt-profile)
        or return 1
    end

    # Check if profile_name is a git URL or local path
    set -l profile_dir ""
    set -l profile_to_save "$profile_name"  # By default, save what was provided

    if string match -qr '^https?://|^git@|^ssh://|^file://' "$profile_name"
        # It's a git URL - fetch it
        ui-info "Fetching external profile: $profile_name"
        set -l fetch_result (deployer-fetch-external-profile "$profile_name")
        or begin
            ui-error "Failed to fetch external profile: $profile_name"
            return 1
        end

        # Parse the result (path and repo name)
        set -l parts (string split " " -- $fetch_result)
        set profile_dir $parts[1]
        set profile_to_save $parts[2]  # Save the repo name, not the URL

    else if string match -q '/*' "$profile_name"
        # It's an absolute path
        if test -d "$profile_name"
            set profile_dir "$profile_name"
        else
            ui-error "Profile directory not found: $profile_name"
            return 1
        end
    else if string match -q '~/*' "$profile_name"; or string match -q './*' "$profile_name"; or string match -q '../*' "$profile_name"
        # It's a relative path - expand it
        set -l expanded_path (eval echo "$profile_name")
        if test -d "$expanded_path"
            set profile_dir "$expanded_path"
        else
            ui-error "Profile directory not found: $expanded_path"
            return 1
        end
    else
        # It's a local profile name - use profile discovery
        set profile_dir (profile-find-path "$profile_name")
        if test -z "$profile_dir"
            ui-error "Profile not found: $profile_name"
            return 1
        end
    end

    # Get mode (priority: arg > config > prompt)
    set -l mode_name ""
    if test -n "$mode_arg"
        set mode_name "$mode_arg"
    else if set -l saved_mode (fedpunk-config-get "mode")
        set mode_name "$saved_mode"
        ui-info "Using saved mode: $mode_name"
    else
        # Determine available modes from profile directory
        set -l modes_dir "$profile_dir/modes"
        if not test -d "$modes_dir"
            ui-error "No modes directory found in profile"
            return 1
        end

        set -l modes
        for mode_dir in $modes_dir/*
            if test -d "$mode_dir"
                set -a modes (basename "$mode_dir")
            end
        end

        if test (count $modes) -eq 0
            ui-error "No modes found in profile"
            return 1
        else if test (count $modes) -eq 1
            set mode_name $modes[1]
        else
            ui-info "Available modes:" >&2
            set mode_name (ui-choose --header "Select mode:" $modes)
            or begin
                ui-error "No mode selected"
                return 1
            end
        end
    end

    # Save selections to config
    fedpunk-config-set "profile" "$profile_to_save"
    fedpunk-config-set "mode" "$mode_name"

    # Create .active-config symlink for plugin discovery
    set -l active_config_link "$FEDPUNK_USER/.active-config"
    set -l user_dir (dirname "$active_config_link")

    # Ensure user directory exists
    if not test -d "$user_dir"
        mkdir -p "$user_dir"
    end

    # Remove old symlink if it exists
    if test -L "$active_config_link"; or test -e "$active_config_link"
        rm -f "$active_config_link"
    end

    # Create new symlink to profile directory
    # Ensure profile_dir is an absolute path (resolve relative paths)
    set -l absolute_profile_dir (realpath "$profile_dir")
    ln -sf "$absolute_profile_dir" "$active_config_link"

    ui-info "Deploying profile: $profile_to_save (mode: $mode_name)"

    # Load modules from mode.yaml
    set -l mode_file "$profile_dir/modes/$mode_name/mode.yaml"
    if not test -f "$mode_file"
        ui-error "Mode file not found: $mode_file"
        return 1
    end

    # Get modules array from YAML (modules is a top-level array)
    set -l modules (yq '.modules[]' "$mode_file" 2>/dev/null)
    if test -z "$modules"
        ui-error "No modules defined in mode: $mode_name"
        return 1
    end

    ui-info "Modules to deploy: "(count $modules)" module(s)"

    # Generate parameter configuration
    param-generate-fish-config "$mode_file"

    # Deploy each module (fetching happens automatically when needed)
    for module_name in $modules
        ui-info "Deploying module: $module_name"
        fedpunk-module deploy "$module_name"
        or begin
            ui-error "Failed to deploy module: $module_name"
            return 1
        end
    end

    # Update metadata
    fedpunk-config-update-metadata

    ui-success "Profile deployed successfully!"
    return 0
end

function deployer-deploy-from-config
    # Deploy based on saved configuration in ~/.config/fedpunk/fedpunk.yaml
    # Usage: deployer-deploy-from-config
    #
    # Supports three workflows:
    # 1. Profile + mode only (deploys profile's modules)
    # 2. Modules only (deploys individual modules from modules.enabled)
    # 3. Both (deploys profile + additional modules)

    if not fedpunk-config-exists
        ui-error "No configuration file found"
        ui-info "Run 'fedpunk profile deploy <name>' or 'fedpunk module deploy <name>' first"
        return 1
    end

    set -l profile (fedpunk-config-get "profile")
    set -l mode (fedpunk-config-get "mode")

    # Check what's available in the config
    set -l has_profile (test -n "$profile" -a "$profile" != "null"; and echo true; or echo false)
    set -l has_mode (test -n "$mode" -a "$mode" != "null"; and echo true; or echo false)
    set -l has_modules (fedpunk-config-list-enabled-modules >/dev/null 2>&1; and echo true; or echo false)

    # Workflow 1: Profile + mode (may also have additional modules)
    if test "$has_profile" = true -a "$has_mode" = true
        ui-info "Deploying from profile configuration..."
        ui-info "Profile: $profile"
        ui-info "Mode: $mode"

        # Deploy the profile
        deployer-deploy-profile "$profile" --mode "$mode"
        or return 1

        # If there are also additional modules, deploy them
        if test "$has_modules" = true
            ui-info ""
            ui-info "Deploying additional modules from configuration..."

            # Generate parameter config for modules (if not already done)
            param-generate-fish-config
            or ui-warn "Failed to generate parameter configuration"

            # Deploy each additional module
            set -l module_refs (fedpunk-config-list-enabled-modules)
            for module_ref in $module_refs
                ui-info "Deploying: $module_ref"
                if not fedpunk-module deploy "$module_ref"
                    ui-error "Failed to deploy: $module_ref"
                    return 1
                end
            end
        end

        # Update metadata
        fedpunk-config-update-metadata

        ui-success "Configuration applied successfully!"
        return 0
    end

    # Workflow 2: Modules only (no profile)
    if test "$has_modules" = true
        ui-info "Deploying from module configuration..."

        # Generate parameter configuration from fedpunk.yaml
        param-generate-fish-config
        or ui-warn "Failed to generate parameter configuration"

        # Deploy each module (fetching happens automatically in fedpunk-module deploy)
        set -l module_refs (fedpunk-config-list-enabled-modules)

        if test -z "$module_refs"
            ui-warn "No enabled modules found in configuration"
            return 0
        end

        ui-info "Deploying "(count $module_refs)" module(s)..."

        for module_ref in $module_refs
            ui-info "Deploying: $module_ref"
            if not fedpunk-module deploy "$module_ref"
                ui-error "Failed to deploy: $module_ref"
                return 1
            end
        end

        # Update metadata
        fedpunk-config-update-metadata

        ui-success "Modules deployed successfully!"
        return 0
    end

    # Workflow 3: Nothing configured
    ui-error "No valid configuration found"
    ui-info "Configuration must have either:"
    ui-info "  • profile + mode (for profile-based deployment)"
    ui-info "  • modules.enabled (for module-based deployment)"
    ui-info "  • both (for profile + additional modules)"
    ui-info ""
    ui-info "Run 'fedpunk profile deploy <name>' or 'fedpunk module deploy <name>'"
    return 1
end
