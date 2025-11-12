#!/usr/bin/env fish
# Restore saved layout preference
# Called after Hyprland reload or theme changes

set preference_file "$HOME/.config/hypr/layout-preference"
set general_conf "$HOME/.config/hypr/conf.d/general.conf"

# If preference file exists, apply the saved layout
if test -f $preference_file
    set preferred_layout (cat $preference_file | string trim)

    # Validate layout name
    if test "$preferred_layout" = "master"; or test "$preferred_layout" = "dwindle"
        # Update general.conf so future reloads preserve the layout
        sed -i "s/^    layout = .*/    layout = $preferred_layout/" $general_conf

        # Apply to runtime
        hyprctl keyword general:layout $preferred_layout
    end
end
