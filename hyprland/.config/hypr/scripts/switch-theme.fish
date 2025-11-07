#!/usr/bin/env fish
# Multi-Application Theme Switcher for Fedpunk
# Switches themes across Hyprland, Foot, Walker, btop, and more
# Usage: switch-theme.fish [theme-name]
# If no theme provided, cycles through available themes

set themes_dir "$HOME/Fedpunk/themes"
set hyprland_conf "$HOME/.config/hypr/hyprland.conf"

# Theme file mappings: source -> destination (symlinks)
# Format: primary_file|fallback_file:destination_path
set -l theme_mappings \
    ".fedpunk-foot.ini|foot.ini:$HOME/.config/foot/theme.ini" \
    "walker.css:$HOME/.config/walker/theme.css" \
    "btop.theme:$HOME/.config/btop/themes/active.theme"

# Get all available themes
set available_themes (ls -d $themes_dir/*/ 2>/dev/null | xargs -n 1 basename)

if test (count $available_themes) -eq 0
    notify-send "Theme Error" "No themes found in $themes_dir" -t 3000 -u critical
    exit 1
end

# If theme name provided, use it
if test (count $argv) -ge 1
    set theme_name $argv[1]

    # Check if theme exists
    if not test -d "$themes_dir/$theme_name"
        notify-send "Theme Error" "Theme '$theme_name' not found" -t 3000 -u critical
        echo "Available themes:"
        for theme in $available_themes
            echo "  - $theme"
        end
        exit 1
    end
else
    # Cycle to next theme
    # Extract current theme from hyprland.conf
    set current_line (grep "source.*themes.*hyprland.conf" $hyprland_conf)
    set current_theme (echo $current_line | sed 's|.*themes/\([^/]*\)/.*|\1|')

    # If can't determine current, use first theme
    if test -z "$current_theme"
        set current_theme $available_themes[1]
    end

    # Find current theme index
    set current_index 0
    for i in (seq (count $available_themes))
        if test "$available_themes[$i]" = "$current_theme"
            set current_index $i
            break
        end
    end

    # Get next theme (wrap around)
    set next_index (math $current_index + 1)
    if test $next_index -gt (count $available_themes)
        set next_index 1
    end

    set theme_name $available_themes[$next_index]
end

set theme_path "$themes_dir/$theme_name"

# Update Hyprland config to source the theme's hyprland.conf
if test -f "$theme_path/hyprland.conf"
    # Replace the source line in hyprland.conf
    sed -i "s|^source = \$HOME/Fedpunk/themes/.*/hyprland.conf|source = \$HOME/Fedpunk/themes/$theme_name/hyprland.conf|" $hyprland_conf
    echo "✓ Updated Hyprland theme source"
    set applied_count 1
    set skipped_count 0
else
    echo "⊘ Skipped hyprland.conf (not found in theme)"
    set applied_count 0
    set skipped_count 1
end

# Apply other theme files (symlinks)
echo ""

for mapping in $theme_mappings
    set parts (string split ":" $mapping)
    set source_files $parts[1]
    set dest_path $parts[2]

    # Check for primary file first, then fallback(s)
    set source_path ""
    set used_file ""
    for candidate in (string split "|" $source_files)
        if test -f "$theme_path/$candidate"
            set source_path "$theme_path/$candidate"
            set used_file $candidate
            break
        end
    end

    if test -n "$source_path"
        # Create destination directory if needed
        set dest_dir (dirname $dest_path)
        mkdir -p $dest_dir 2>/dev/null

        # Create symlink
        ln -sf $source_path $dest_path
        set applied_count (math $applied_count + 1)
        echo "✓ Applied $used_file"
    else
        set skipped_count (math $skipped_count + 1)
        set first_candidate (string split "|" $source_files)[1]
        echo "⊘ Skipped $first_candidate (not found in theme)"
    end
end

# Reload applications
echo ""
echo "Reloading applications..."

# Reload Hyprland
hyprctl reload >/dev/null 2>&1
and echo "✓ Hyprland reloaded"
or echo "✗ Hyprland reload failed"

# Note: Foot, Walker, and btop will pick up changes on next launch
echo "⟳ Foot, Walker, btop will update on next launch"

# Send notification
notify-send "Theme Changed" "Switched to: $theme_name\n$applied_count files applied, $skipped_count skipped" -t 3000

echo ""
echo "Theme switched to: $theme_name"
echo "Applied $applied_count file(s), skipped $skipped_count"
