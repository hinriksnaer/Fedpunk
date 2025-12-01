#!/usr/bin/env fish
# Restore saved layout preference
# Called after Hyprland reload or theme changes

# Ensure HOME is set properly
if not set -q HOME
    set HOME (eval echo ~)
end

set preference_file "$HOME/.config/hypr/layout-preference"
set general_conf "$HOME/.config/hypr/conf.d/general.conf"
set active_mode_file "$HOME/.config/hypr/active-mode.conf"

# If preference file exists, apply the saved layout
if test -f $preference_file
    set preferred_layout (cat $preference_file | string trim)

    # Validate layout name
    if test "$preferred_layout" = "master"; or test "$preferred_layout" = "dwindle"
        # Update general.conf so future reloads preserve the layout
        sed -i "s/^    layout = .*/    layout = $preferred_layout/" $general_conf

        # Update active mode configuration if it exists
        if test -f $active_mode_file
            set mode_conf (grep "^source = " $active_mode_file | sed 's/^source = //')
            if test -f "$mode_conf"
                sed -i "s/^    layout = .*/    layout = $preferred_layout/" "$mode_conf"
            end
        end

        # Apply to runtime
        hyprctl keyword general:layout $preferred_layout
    end
end
