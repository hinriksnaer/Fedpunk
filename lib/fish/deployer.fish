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

    # Add module to config (creates config if needed)
    fedpunk-config-add-module "$module_ref"

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

function deployer-deploy-profile
    # Deploy a profile with all its modules
    # Usage: deployer-deploy-profile [profile-name-or-url] [--mode MODE]
    # Examples:
    #   deployer-deploy-profile              # Interactive (uses config or prompts)
    #   deployer-deploy-profile default      # Deploy 'default' profile
    #   deployer-deploy-profile --mode desktop  # Use saved profile with desktop mode
    #   deployer-deploy-profile default --mode container
    #   deployer-deploy-profile https://github.com/user/profile.git --mode desktop

    # Parse arguments
    set -l profile_arg ""
    set -l mode_arg ""
    set -l i 1
    while test $i -le (count $argv)
        if test "$argv[$i]" = "--mode"
            set i (math $i + 1)
            set mode_arg $argv[$i]
        else
            set profile_arg $argv[$i]
        end
        set i (math $i + 1)
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

    # TODO: Handle git URL profiles (future enhancement)
    # For now, only local profiles supported

    # Get mode (priority: arg > config > prompt)
    set -l mode_name ""
    if test -n "$mode_arg"
        set mode_name "$mode_arg"
    else if set -l saved_mode (fedpunk-config-get "mode")
        set mode_name "$saved_mode"
        ui-info "Using saved mode: $mode_name"
    else
        set mode_name (deployer-prompt-mode "$profile_name")
        or return 1
    end

    # Save selections to config
    fedpunk-config-set "profile" "$profile_name"
    fedpunk-config-set "mode" "$mode_name"

    ui-info "Deploying profile: $profile_name (mode: $mode_name)"

    # Find profile directory
    set -l profile_dir (profile-find-path "$profile_name")
    if test -z "$profile_dir"
        ui-error "Profile not found: $profile_name"
        return 1
    end

    # Load modules from mode.yaml
    set -l mode_file "$profile_dir/modes/$mode_name/mode.yaml"
    if not test -f "$mode_file"
        ui-error "Mode file not found: $mode_file"
        return 1
    end

    set -l modules (yaml-get-value "$mode_file" "modules")
    if test -z "$modules"
        ui-error "No modules defined in mode: $mode_name"
        return 1
    end

    ui-info "Modules to deploy: $modules"

    # Generate parameter configuration
    param-generate-fish-config "$mode_file"

    # Deploy each module (fetching happens automatically when needed)
    for module_name in (string split " " -- $modules)
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
