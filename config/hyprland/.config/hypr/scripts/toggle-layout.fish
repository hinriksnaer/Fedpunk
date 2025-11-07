#!/usr/bin/env fish
# Toggle between dwindle and master layouts

set current_layout (hyprctl getoption general:layout -j | jq -r '.str')

if test "$current_layout" = "dwindle"
    hyprctl keyword general:layout master
    notify-send "Layout" "Switched to Master (ultrawide mode)" -t 2000
else
    hyprctl keyword general:layout dwindle
    notify-send "Layout" "Switched to Dwindle (conventional mode)" -t 2000
end
