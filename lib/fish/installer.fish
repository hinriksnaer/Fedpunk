#!/usr/bin/env fish
# Fedpunk installer orchestrator
# Handles profile/mode selection and module deployment

# Source dependencies
set -l lib_dir (dirname (status -f))
source "$lib_dir/ui.fish"
source "$lib_dir/yaml-parser.fish"
source "$lib_dir/fedpunk-module.fish"
source "$lib_dir/module-ref-parser.fish"
source "$lib_dir/external-modules.fish"
source "$lib_dir/param-injector.fish"

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

    # List available modes (look for mode.yaml in subdirectories)
    set -l available_modes
    for mode_dir in $modes_dir/*/
        if test -f "$mode_dir/mode.yaml"
            set -l mode_name (basename "$mode_dir")
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
        set -l mode_file "$modes_dir/$mode/mode.yaml"
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
    # Returns just the module references (for display), not params
    set -l profile $argv[1]
    set -l mode $argv[2]
    set -l mode_file "$FEDPUNK_ROOT/profiles/$profile/modes/$mode/mode.yaml"

    if not test -f "$mode_file"
        ui-error "Mode file not found: $mode_file"
        return 1
    end

    # Use new parser to get module references
    module-ref-list-all "$mode_file"
end

function installer-fetch-external-modules
    # Fetch all external modules from mode configuration
    set -l mode_file $argv[1]

    if not test -f "$mode_file"
        ui-error "Mode file not found: $mode_file"
        return 1
    end

    ui-info "Checking for external modules..."

    set -l modules (module-ref-list-all "$mode_file")
    set -l external_count 0

    for module_ref in $modules
        if module-ref-is-url "$module_ref"
            set external_count (math $external_count + 1)
            ui-info "Fetching: $module_ref"
            external-module-fetch "$module_ref"
            or return 1
        end
    end

    if test $external_count -eq 0
        ui-info "No external modules to fetch"
    else
        ui-success "Fetched $external_count external module(s)"
    end

    return 0
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

    # Show log locations
    set -l output_log (ui-output-log-location)
    if test -n "$output_log"
        ui-info "Full output being captured to: $output_log"
        echo ""
    end

    # Enable auto-tail for all ui-spin calls during install
    set -gx FEDPUNK_AUTO_TAIL 5

    # Initial system update
    ui-section "System Update"
    ui-info "Updating system packages before installation"
    # DNF progress output is complex, disable tail mode for clean spinner
    set -l FEDPUNK_AUTO_TAIL_BACKUP $FEDPUNK_AUTO_TAIL
    set -e FEDPUNK_AUTO_TAIL
    ui-spin --title "Running DNF update..." -- sudo dnf update -y -q --color=never
    set -gx FEDPUNK_AUTO_TAIL $FEDPUNK_AUTO_TAIL_BACKUP

    if test $status -eq 0
        ui-success "System updated successfully"
    else
        ui-warning "System update completed with warnings"
    end
    echo ""
    echo ""
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

    # Set up active profile symlink BEFORE deploying modules (plugins need this)
    echo ""
    ui-info "Setting up active profile..."
    set -l active_config "$FEDPUNK_ROOT/.active-config"
    rm -f "$active_config"
    ln -s "$FEDPUNK_ROOT/profiles/$profile" "$active_config"
    ui-success "Active profile: $profile"

    # Fetch external modules
    echo ""
    ui-section "External Modules"
    set -l mode_file "$FEDPUNK_ROOT/profiles/$profile/modes/$mode/mode.yaml"
    installer-fetch-external-modules "$mode_file"
    or begin
        ui-error "Failed to fetch external modules"
        return 1
    end

    # Generate parameter configuration
    echo ""
    ui-section "Module Parameters"
    ui-info "Generating parameter configuration..."
    param-generate-fish-config "$mode_file"
    or begin
        ui-error "Failed to generate parameter configuration"
        return 1
    end
    ui-success "Parameters configured"

    # Deploy modules
    echo ""
    installer-deploy-modules $modules

    if test $status -eq 0
        # Set up mode configuration
        echo ""
        ui-info "Setting up mode configuration..."

        # Create active mode configuration for Hyprland (if hypr.conf exists)
        set -l mode_hypr_conf "$FEDPUNK_ROOT/profiles/$profile/modes/$mode/hypr.conf"
        if test -f "$mode_hypr_conf"
            set -l active_mode_conf "$HOME/.config/hypr/active-mode.conf"
            echo "# Active Mode Configuration (runtime-generated)" > "$active_mode_conf"
            echo "# Sources mode-specific Hyprland overrides" >> "$active_mode_conf"
            echo "# Mode: $mode" >> "$active_mode_conf"
            echo "" >> "$active_mode_conf"
            echo "source = $FEDPUNK_ROOT/profiles/$profile/modes/$mode/hypr.conf" >> "$active_mode_conf"
            ui-success "Active mode configured: $mode"

            # Reload Hyprland if it's running
            if hyprctl version >/dev/null 2>&1
                hyprctl reload >/dev/null 2>&1
                ui-success "Hyprland configuration reloaded"
            end
        end

        # Final system update after all modules
        echo ""
        ui-section "Final System Update"
        ui-info "Updating all packages after module installation"
        ui-spin --title "Running final DNF update..." --tail 10 -- sudo dnf update -y -q --color=never

        if test $status -eq 0
            ui-success "Final system update completed"
        else
            ui-warning "Final update completed with warnings"
        end
        echo ""

        # Success message
        set -l log_location (ui-log-location)
        set -l output_log (ui-output-log-location)

        set -l log_info "UI log: $log_location"
        if test -n "$output_log"
            set log_info "$log_info
Full output: $output_log"
        end

        ui-box "Installation Complete! 🎉

Profile: $profile
Mode: $mode
Modules deployed: "(count $modules)"

Restart your shell or run: exec fish

$log_info" $UI_SUCCESS
        return 0
    else
        set -l log_location (ui-log-location)
        set -l output_log (ui-output-log-location)

        set -l log_info "UI log: $log_location"
        if test -n "$output_log"
            set log_info "$log_info
Full output: $output_log"
        end

        ui-box "Installation Failed

Some modules failed to deploy.
Check the output above for details.

$log_info" $UI_ERROR
        return 1
    end
end
