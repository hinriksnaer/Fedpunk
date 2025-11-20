#!/usr/bin/env fish
# Fedpunk installer orchestrator
# Handles profile/mode selection and module deployment

# Source dependencies
set -l lib_dir (dirname (status -f))
source "$lib_dir/ui.fish"
source "$lib_dir/yaml-parser.fish"
source "$lib_dir/fedpunk-module.fish"

function installer-select-profile
    # Select profile interactively or from flag
    set -l profiles_dir "$FEDPUNK_ROOT/profiles"

    if not test -d "$profiles_dir"
        ui-error "No profiles directory found"
        return 1
    end

    # List available profiles
    set -l available_profiles
    for profile_dir in $profiles_dir/*
        if test -d "$profile_dir"
            set -a available_profiles (basename "$profile_dir")
        end
    end

    if test (count $available_profiles) -eq 0
        ui-error "No profiles found in $profiles_dir"
        return 1
    end

    # If only one profile, use it
    if test (count $available_profiles) -eq 1
        echo $available_profiles[1]
        return 0
    end

    # Interactive selection
    ui-info "Available profiles:" >&2
    for profile in $available_profiles
        set -l profile_yaml "$profiles_dir/$profile/fedpunk.yaml"
        if test -f "$profile_yaml"
            set -l description (yaml-get-value "$profile_yaml" "profile" "description")
            echo "  • $profile - $description" >&2
        else
            echo "  • $profile" >&2
        end
    end

    echo "" >&2
    set -l selected (ui-choose --header "Select profile:" $available_profiles)

    if test -z "$selected"
        ui-error "No profile selected"
        return 1
    end

    echo $selected
end

function installer-select-mode
    # Select mode interactively or from flag
    set -l profile $argv[1]
    set -l modes_dir "$FEDPUNK_ROOT/profiles/$profile/modes"

    if not test -d "$modes_dir"
        ui-error "No modes directory found for profile: $profile"
        return 1
    end

    # List available modes
    set -l available_modes
    for mode_file in $modes_dir/*.yaml
        if test -f "$mode_file"
            set -l mode_name (basename "$mode_file" .yaml)
            set -a available_modes $mode_name
        end
    end

    if test (count $available_modes) -eq 0
        ui-error "No modes found for profile: $profile"
        return 1
    end

    # If only one mode, use it
    if test (count $available_modes) -eq 1
        echo $available_modes[1]
        return 0
    end

    # Interactive selection
    ui-info "Available modes for profile '$profile':" >&2
    for mode in $available_modes
        set -l mode_file "$modes_dir/$mode.yaml"
        set -l description (yaml-get-value "$mode_file" "mode" "description")
        if test -n "$description"
            echo "  • $mode - $description" >&2
        else
            echo "  • $mode" >&2
        end
    end

    echo "" >&2
    set -l selected (ui-choose --header "Select mode:" $available_modes)

    if test -z "$selected"
        ui-error "No mode selected"
        return 1
    end

    echo $selected
end

function installer-load-modules
    # Load module list from mode configuration
    set -l profile $argv[1]
    set -l mode $argv[2]
    set -l mode_file "$FEDPUNK_ROOT/profiles/$profile/modes/$mode.yaml"

    if not test -f "$mode_file"
        ui-error "Mode file not found: $mode_file"
        return 1
    end

    yaml-get-array "$mode_file" ".modules[]"
end

function installer-deploy-modules
    # Deploy modules in order
    set -l modules $argv

    if test (count $modules) -eq 0
        ui-warning "No modules to deploy"
        return 0
    end

    set -l total (count $modules)
    set -l current 0

    for module in $modules
        set current (math $current + 1)

        ui-section "[$current/$total] Deploying: $module"

        # Deploy module (fail fast on error)
        fedpunk-module deploy $module
        or begin
            ui-error "Failed to deploy module: $module"
            ui-error "Installation aborted"
            return 1
        end

        ui-success "Module $module deployed successfully"
    end

    return 0
end

function installer-run
    # Main installer flow
    set -l profile ""
    set -l mode ""
    set -l non_interactive false

    # Parse arguments
    set -l i 1
    while test $i -le (count $argv)
        switch $argv[$i]
            case --profile
                set i (math $i + 1)
                set profile $argv[$i]
            case --mode
                set i (math $i + 1)
                set mode $argv[$i]
            case --non-interactive
                set non_interactive true
            case --help -h
                echo "Usage: install.fish [options]"
                echo ""
                echo "Options:"
                echo "  --profile <name>      Use specific profile"
                echo "  --mode <name>         Use specific mode"
                echo "  --non-interactive     Skip interactive prompts"
                echo "  --help, -h            Show this help"
                return 0
            case '*'
                ui-error "Unknown option: $argv[$i]"
                return 1
        end
        set i (math $i + 1)
    end

    # Welcome - ASCII art
    echo ""
    echo "███████╗███████╗██████╗ ██████╗ ██╗   ██╗███╗   ██╗██╗  ██╗"
    echo "██╔════╝██╔════╝██╔══██╗██╔══██╗██║   ██║████╗  ██║██║ ██╔╝"
    echo "█████╗  █████╗  ██║  ██║██████╔╝██║   ██║██╔██╗ ██║█████╔╝"
    echo "██╔══╝  ██╔══╝  ██║  ██║██╔═══╝ ██║   ██║██║╚██╗██║██╔═██╗"
    echo "██║     ███████╗██████╔╝██║     ╚██████╔╝██║ ╚████║██║  ██╗"
    echo "╚═╝     ╚══════╝╚═════╝ ╚═╝      ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═╝"
    echo ""
    ui-info "Modern, modular Fedora development environment"
    ui-info "with Hyprland compositor and Fish shell"
    echo ""

    # Select profile
    if test -z "$profile"
        if test "$non_interactive" = "true"
            set profile "dev"  # Default
            ui-info "Using default profile: $profile"
        else
            set profile (installer-select-profile)
            or return 1
        end
    end

    ui-success "Profile selected: $profile"

    # Select mode
    if test -z "$mode"
        if test "$non_interactive" = "true"
            # Auto-detect: container if no display, desktop otherwise
            if test -z "$DISPLAY" -a -z "$WAYLAND_DISPLAY"
                set mode "container"
            else
                set mode "desktop"
            end
            ui-info "Auto-detected mode: $mode"
        else
            set mode (installer-select-mode $profile)
            or return 1
        end
    end

    ui-success "Mode selected: $mode"

    # Load modules
    echo ""
    ui-info "Loading module configuration..."
    set -l modules (installer-load-modules $profile $mode)
    set -l load_status $status

    if test $load_status -ne 0
        ui-error "Failed to load module configuration"
        return 1
    end

    if test (count $modules) -eq 0
        ui-error "No modules found in $profile/$mode configuration"
        return 1
    end

    ui-info "Modules to deploy: "(count $modules)
    for module in $modules
        echo "  • $module"
    end

    # Confirm before proceeding
    echo ""
    if not test "$non_interactive" = "true"
        if not ui-confirm "Proceed with installation?"
            ui-warning "Installation cancelled"
            return 1
        end
    end

    # Deploy modules
    echo ""
    installer-deploy-modules $modules

    if test $status -eq 0
        set -l log_location (ui-log-location)
        ui-box "Installation Complete! 🎉

Profile: $profile
Mode: $mode
Modules deployed: "(count $modules)"

Restart your shell or run: exec fish

Log file: $log_location" $UI_SUCCESS
        return 0
    else
        set -l log_location (ui-log-location)
        ui-box "Installation Failed

Some modules failed to deploy.
Check the output above for details.

Log file: $log_location" $UI_ERROR
        return 1
    end
end
