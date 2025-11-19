#!/usr/bin/env fish
# Toggle between dwindle and master layouts

set current_layout (hyprctl getoption general:layout -j | jq -r '.str')
set preference_file "$HOME/.config/hypr/layout-preference"
set general_conf "$HOME/.config/hypr/conf.d/general.conf"

if test "$current_layout" = "dwindle"
    # Switch to master
    set new_layout "master"
    hyprctl keyword general:layout master
    notify-send "Layout" "Switched to Master (ultrawide mode)" -t 2000
else
    # Switch to dwindle
    set new_layout "dwindle"
    hyprctl keyword general:layout dwindle
    notify-send "Layout" "Switched to Dwindle (conventional mode)" -t 2000
end

# Save preference for restore script
echo $new_layout > $preference_file

# Update general.conf so reloads preserve the layout
sed -i "s/^    layout = .*/    layout = $new_layout/" $general_conf
