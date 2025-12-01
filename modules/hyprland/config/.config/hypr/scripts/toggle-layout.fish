#!/usr/bin/env fish
# Toggle between dwindle and master layouts

# Ensure HOME is set properly
if not set -q HOME
    set HOME (eval echo ~)
end

set current_layout (hyprctl getoption general:layout -j | jq -r '.str')
set preference_file "$HOME/.config/hypr/layout-preference"
set general_conf "$HOME/.config/hypr/conf.d/general.conf"
set active_mode_file "$HOME/.config/hypr/active-mode.conf"

# Determine new layout
if test "$current_layout" = "dwindle"
    set new_layout "master"
    set message "Switched to Master (ultrawide mode)"
else
    set new_layout "dwindle"
    set message "Switched to Dwindle (conventional mode)"
end

# Update config files FIRST (before visual change) to avoid I/O during transition
echo $new_layout > $preference_file
sed -i "s/^    layout = .*/    layout = $new_layout/" $general_conf

# Update active mode configuration if it exists
if test -f $active_mode_file
    set mode_conf (grep "^source = " $active_mode_file | sed 's/^source = //')
    if test -f "$mode_conf"
        sed -i "s/^    layout = .*/    layout = $new_layout/" "$mode_conf"
    end
end

# Switch the layout with minimal visual disruption
# Disable blur temporarily for smoother transition
set blur_enabled (hyprctl getoption decoration:blur:enabled -j | jq -r '.int')
if test "$blur_enabled" = "1"
    hyprctl keyword decoration:blur:enabled false >/dev/null 2>&1
end

# Perform the layout switch
hyprctl keyword general:layout $new_layout >/dev/null 2>&1

# Re-enable blur after a brief moment
if test "$blur_enabled" = "1"
    sleep 0.1
    hyprctl keyword decoration:blur:enabled true >/dev/null 2>&1
end

# Show notification in background
notify-send "Layout" "$message" -t 2000 &
