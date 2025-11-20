#!/usr/bin/env fish
# UI abstraction layer - wraps gum for easy refactoring
# All UI interactions should go through these functions

# Color scheme
set -g UI_SUCCESS 46   # Green
set -g UI_ERROR 196    # Red
set -g UI_WARNING 214  # Orange
set -g UI_INFO 39      # Blue
set -g UI_MUTED 245    # Gray

# Check if gum is available
function ui-has-gum
    command -v gum >/dev/null 2>&1
end

# Fallback for non-interactive environments
function ui-is-interactive
    test -t 0 -a -t 1
end

# Spinner/progress indicator
function ui-spin
    # Usage: ui-spin --title "Loading..." -- command args
    if ui-has-gum
        gum spin $argv
    else
        # Fallback: just run the command
        set -l title_arg ""
        set -l cmd_start 0

        for i in (seq (count $argv))
            if test "$argv[$i]" = "--"
                set cmd_start (math $i + 1)
                break
            else if test "$argv[$i]" = "--title"
                set title_arg $argv[(math $i + 1)]
            end
        end

        if test -n "$title_arg"
            echo "$title_arg"
        end

        if test $cmd_start -gt 0
            eval $argv[$cmd_start..]
        end
    end
end

# Styled text output
function ui-style
    # Usage: ui-style --foreground <color> "text"
    if ui-has-gum
        gum style $argv
    else
        # Fallback: just echo the last argument (the text)
        echo $argv[-1]
    end
end

# Success message
function ui-success
    set -l message $argv[1]
    if ui-has-gum
        gum style --foreground $UI_SUCCESS "✓ $message"
    else
        echo "✓ $message"
    end
end

# Error message
function ui-error
    set -l message $argv[1]
    if ui-has-gum
        gum style --foreground $UI_ERROR "✗ $message"
    else
        echo "✗ $message" >&2
    end
end

# Warning message
function ui-warning
    set -l message $argv[1]
    if ui-has-gum
        gum style --foreground $UI_WARNING "⚠ $message"
    else
        echo "⚠ $message"
    end
end

# Info message
function ui-info
    set -l message $argv[1]
    if ui-has-gum
        gum style --foreground $UI_INFO "→ $message"
    else
        echo "→ $message"
    end
end

# Section header
function ui-section
    set -l title $argv[1]
    if ui-has-gum
        echo ""
        gum style --border double --padding "1 2" --border-foreground $UI_INFO "$title"
        echo ""
    else
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "  $title"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
    end
end

# Subsection header
function ui-subsection
    set -l title $argv[1]
    if ui-has-gum
        echo ""
        gum style --foreground $UI_INFO --bold "$title"
    else
        echo ""
        echo "── $title"
    end
end

# Box around text
function ui-box
    set -l message $argv[1]
    set -l color $argv[2]

    if test -z "$color"
        set color $UI_SUCCESS
    end

    if ui-has-gum
        echo ""
        gum style --border rounded --padding "1 2" --border-foreground $color "$message"
        echo ""
    else
        echo ""
        echo "╭────────────────────────────────────────────────╮"
        echo "$message" | while read -l line
            echo "│ $line"
        end
        echo "╰────────────────────────────────────────────────╯"
        echo ""
    end
end

# Choose from list
function ui-choose
    # Usage: ui-choose --header "Select option" option1 option2 option3
    if ui-has-gum
        gum choose $argv
    else
        # Fallback: use fish's read with prompt
        set -l header ""
        set -l options

        for i in (seq (count $argv))
            if test "$argv[$i]" = "--header"
                set header $argv[(math $i + 1)]
            else if not string match -q -- "--*" $argv[$i]
                set -a options $argv[$i]
            end
        end

        if test -n "$header"
            echo "$header"
        end

        for i in (seq (count $options))
            echo "  $i) $options[$i]"
        end

        read -l -P "Select number: " selection
        if test -n "$selection" -a $selection -le (count $options)
            echo $options[$selection]
        end
    end
end

# Confirm yes/no
function ui-confirm
    # Usage: ui-confirm "Are you sure?" (returns 0 for yes, 1 for no)
    set -l prompt $argv[1]

    if ui-has-gum
        gum confirm "$prompt"
    else
        # Fallback: use fish's read
        read -l -P "$prompt (y/N) " response
        string match -qi "y*" "$response"
    end
end

# Text input
function ui-input
    # Usage: ui-input --placeholder "Enter value"
    if ui-has-gum
        gum input $argv
    else
        # Fallback: use fish's read
        set -l placeholder ""

        for i in (seq (count $argv))
            if test "$argv[$i]" = "--placeholder"
                set placeholder $argv[(math $i + 1)]
            end
        end

        if test -n "$placeholder"
            read -l -P "$placeholder: " value
        else
            read -l value
        end

        echo $value
    end
end

# Filter/search from list
function ui-filter
    # Usage: echo "item1\nitem2\nitem3" | ui-filter --placeholder "Search..."
    if ui-has-gum
        gum filter $argv
    else
        # Fallback: just pass through (or use basic grep)
        cat
    end
end

# Progress bar
function ui-progress
    # Usage: for i in (seq 100); ui-progress --value $i; end
    if ui-has-gum
        # Note: gum progress might need special handling
        # For now, just pass through
        gum style --foreground $UI_INFO "Progress: $argv"
    else
        # Fallback: simple percentage
        echo "Progress: $argv"
    end
end

# Step indicator (for multi-step processes)
function ui-step
    set -l current $argv[1]
    set -l total $argv[2]
    set -l description $argv[3]

    if ui-has-gum
        gum style --foreground $UI_INFO "[$current/$total] $description"
    else
        echo "[$current/$total] $description"
    end
end
