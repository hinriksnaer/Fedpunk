#!/usr/bin/env fish
# UI abstraction layer - wraps gum for easy refactoring
# All UI interactions should go through these functions

# Color scheme
set -g UI_SUCCESS 46   # Green
set -g UI_ERROR 196    # Red
set -g UI_WARNING 214  # Orange
set -g UI_INFO 39      # Blue
set -g UI_MUTED 245    # Gray

# Logging configuration
set -g UI_LOG_ENABLED true  # Enable logging during development
set -g UI_DEBUG_MODE false  # Extra verbose output (set true for deep debugging)
set -g UI_CAPTURE_OUTPUT true  # Capture all command output to log

# Initialize log files
if test "$UI_LOG_ENABLED" = "true"
    if not set -q UI_LOG_FILE
        set -l timestamp (date +%Y%m%d-%H%M%S)
        set -gx UI_LOG_FILE "/tmp/fedpunk-ui-$timestamp.log"
        set -gx UI_OUTPUT_LOG "/tmp/fedpunk-output-$timestamp.log"

        echo "=== Fedpunk UI Log ===" > "$UI_LOG_FILE"
        echo "Started: "(date) >> "$UI_LOG_FILE"
        echo "Output log: $UI_OUTPUT_LOG" >> "$UI_LOG_FILE"
        echo "" >> "$UI_LOG_FILE"

        echo "=== Fedpunk Full Output Log ===" > "$UI_OUTPUT_LOG"
        echo "Started: "(date) >> "$UI_OUTPUT_LOG"
        echo "" >> "$UI_OUTPUT_LOG"
    end
end

# Log a message to the UI log file
function ui-log
    set -l level $argv[1]
    set -l message $argv[2..]

    if test "$UI_LOG_ENABLED" = "true"
        echo "["(date +%H:%M:%S)"] [$level] $message" >> "$UI_LOG_FILE"
    end

    # If debug mode, also output to stderr
    if test "$UI_DEBUG_MODE" = "true"
        echo "[DEBUG][$level] $message" >&2
    end
end

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
    # Usage: ui-spin --title "Loading..." --tail 10 -- command args  (shows last 10 lines live)
    set -l title_arg ""
    set -l tail_lines 0
    set -l cmd_start 0

    # Parse arguments
    for i in (seq (count $argv))
        if test "$argv[$i]" = "--"
            set cmd_start (math $i + 1)
            break
        else if test "$argv[$i]" = "--title"
            set title_arg $argv[(math $i + 1)]
        else if test "$argv[$i]" = "--tail"
            set tail_lines $argv[(math $i + 1)]
        end
    end

    ui-log SPIN "Starting: $title_arg (tail=$tail_lines)"

    # If --tail specified, use tail mode - show last N lines updating in place
    if test "$tail_lines" != "0" -a "$tail_lines" != ""
        if test -n "$title_arg"
            printf "%s\n" "$title_arg"
        end

        if test $cmd_start -eq 0
            ui-log SPIN "No command provided"
            return 1
        end

        # Run command and tail output
        set -l tmp_out (mktemp)
        $argv[$cmd_start..] > "$tmp_out" 2>&1 &
        set -l cmd_pid $last_pid

        # Print empty lines to reserve space
        for i in (seq $tail_lines)
            printf "\n"
        end

        # Move cursor back up
        tput cuu $tail_lines 2>/dev/null; or printf '\033[%dA' $tail_lines

        # Save cursor position
        set -l start_row (tput lines 2>/dev/null; or echo 0)

        # Stream output while running
        while kill -0 $cmd_pid 2>/dev/null
            if test -f "$tmp_out" -a -s "$tmp_out"
                # Move to start position
                tput cuu $tail_lines 2>/dev/null; or printf '\033[%dA' $tail_lines

                # Get last N lines and display
                set -l lines_to_show (tail -n $tail_lines "$tmp_out" 2>/dev/null)
                set -l count 0
                for line in $lines_to_show
                    set count (math $count + 1)
                    # Clear line, print dimmed, truncated
                    printf '\033[2K\033[90m  %s\033[0m\n' (string sub -l 76 "$line")
                end

                # Pad remaining lines
                while test $count -lt $tail_lines
                    printf '\033[2K\n'
                    set count (math $count + 1)
                end
            end
            sleep 0.2
        end

        # Clear the output area
        tput cuu $tail_lines 2>/dev/null; or printf '\033[%dA' $tail_lines
        for i in (seq $tail_lines)
            printf '\033[2K\n'
        end
        tput cuu $tail_lines 2>/dev/null; or printf '\033[%dA' $tail_lines

        # Wait for command and get status
        wait $cmd_pid
        set -l status_code $status

        # Log full output
        if test "$UI_CAPTURE_OUTPUT" = "true" -a -n "$UI_OUTPUT_LOG"
            echo "=== $title_arg ===" >> "$UI_OUTPUT_LOG"
            cat "$tmp_out" >> "$UI_OUTPUT_LOG"
            echo "" >> "$UI_OUTPUT_LOG"
        end

        rm -f "$tmp_out"
        ui-log SPIN "Completed with status: $status_code"
        return $status_code
    end

    # Standard spinner mode (no --tail)
    if ui-has-gum
        # Build gum args without --tail
        set -l gum_args
        if test -n "$title_arg"
            set -a gum_args --title "$title_arg"
        end
        if test $cmd_start -gt 0
            set -a gum_args -- $argv[$cmd_start..]
        end
        gum spin $gum_args
    else
        if test -n "$title_arg"
            echo "$title_arg"
        end
        if test $cmd_start -gt 0
            eval $argv[$cmd_start..]
        end
    end

    set -l status_code $status
    ui-log SPIN "Completed with status: $status_code"
    return $status_code
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
    ui-log SUCCESS "$message"

    if ui-has-gum
        gum style --foreground $UI_SUCCESS "✓ $message"
    else
        echo "✓ $message"
    end
end

# Error message
function ui-error
    set -l message $argv[1]
    ui-log ERROR "$message"

    if ui-has-gum
        gum style --foreground $UI_ERROR "✗ $message"
    else
        echo "✗ $message" >&2
    end
end

# Warning message
function ui-warning
    set -l message $argv[1]
    ui-log WARNING "$message"

    if ui-has-gum
        gum style --foreground $UI_WARNING "⚠ $message"
    else
        echo "⚠ $message"
    end
end

# Info message
function ui-info
    set -l message $argv[1]
    ui-log INFO "$message"

    if ui-has-gum
        gum style --foreground $UI_INFO "→ $message"
    else
        echo "→ $message"
    end
end

# Section header
function ui-section
    set -l title $argv[1]
    ui-log SECTION "$title"

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
    ui-log SUBSECTION "$title"

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

    ui-log BOX "$message"

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
    set -l header ""
    set -l options

    # Parse arguments to extract header and options for logging
    for i in (seq (count $argv))
        if test "$argv[$i]" = "--header"
            set header $argv[(math $i + 1)]
        else if not string match -q -- "--*" $argv[$i]
            set -a options $argv[$i]
        end
    end

    ui-log CHOOSE "Presenting choice: $header | Options: $options"

    if ui-has-gum
        set -l choice (gum choose $argv)
        ui-log CHOOSE "User selected: $choice"
        echo $choice
    else
        # Fallback: use fish's read with prompt
        if test -n "$header"
            echo "$header"
        end

        for i in (seq (count $options))
            echo "  $i) $options[$i]"
        end

        read -l -P "Select number: " selection
        if test -n "$selection" -a $selection -le (count $options)
            set -l choice $options[$selection]
            ui-log CHOOSE "User selected: $choice (option $selection)"
            echo $choice
        else
            ui-log CHOOSE "Invalid selection: $selection"
        end
    end
end

# Confirm yes/no
function ui-confirm
    # Usage: ui-confirm "Are you sure?" (returns 0 for yes, 1 for no)
    set -l prompt $argv[1]
    ui-log CONFIRM "Asking: $prompt"

    if ui-has-gum
        if gum confirm "$prompt"
            ui-log CONFIRM "User answered: YES"
            return 0
        else
            ui-log CONFIRM "User answered: NO"
            return 1
        end
    else
        # Fallback: use fish's read
        read -l -P "$prompt (y/N) " response
        if string match -qi "y*" "$response"
            ui-log CONFIRM "User answered: YES ($response)"
            return 0
        else
            ui-log CONFIRM "User answered: NO ($response)"
            return 1
        end
    end
end

# Text input
function ui-input
    # Usage: ui-input --placeholder "Enter value"
    set -l placeholder ""

    for i in (seq (count $argv))
        if test "$argv[$i]" = "--placeholder"
            set placeholder $argv[(math $i + 1)]
        end
    end

    ui-log INPUT "Requesting input: $placeholder"

    if ui-has-gum
        set -l value (gum input $argv)
        ui-log INPUT "User entered: [redacted - length "(string length "$value)")"]"
        echo $value
    else
        # Fallback: use fish's read
        if test -n "$placeholder"
            read -l -P "$placeholder: " value
        else
            read -l value
        end

        ui-log INPUT "User entered: [redacted - length "(string length "$value)")"]"
        echo $value
    end
end

# Filter/search from list
function ui-filter
    # Usage: echo "item1\nitem2\nitem3" | ui-filter --placeholder "Search..."
    ui-log FILTER "Filtering list"

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

    ui-log STEP "Step $current/$total: $description"

    if ui-has-gum
        gum style --foreground $UI_INFO "[$current/$total] $description"
    else
        echo "[$current/$total] $description"
    end
end

# Log file location
function ui-log-location
    if test "$UI_LOG_ENABLED" = "true"
        echo $UI_LOG_FILE
    end
end

# Full output log location
function ui-output-log-location
    if test "$UI_CAPTURE_OUTPUT" = "true" -a -n "$UI_OUTPUT_LOG"
        echo $UI_OUTPUT_LOG
    end
end

# Show log locations
function ui-show-logs
    echo "Log files:"
    if test "$UI_LOG_ENABLED" = "true" -a -n "$UI_LOG_FILE"
        echo "  UI events: $UI_LOG_FILE"
    end
    if test "$UI_CAPTURE_OUTPUT" = "true" -a -n "$UI_OUTPUT_LOG"
        echo "  Full output: $UI_OUTPUT_LOG"
    end
end

# Smart select - TUI if interactive and no value, otherwise use provided value
# Usage: ui-select-smart --value "$user_value" --header "Pick one:" --options $items
# Returns: selected value via stdout, or returns 1 on error/cancel
function ui-select-smart
    set -l value ""
    set -l header ""
    set -l options

    # Parse arguments
    set -l i 1
    while test $i -le (count $argv)
        switch $argv[$i]
            case --value
                set i (math $i + 1)
                set value $argv[$i]
            case --header
                set i (math $i + 1)
                set header $argv[$i]
            case --options
                set i (math $i + 1)
                # Collect remaining as options
                while test $i -le (count $argv)
                    if string match -q -- "--*" $argv[$i]
                        set i (math $i - 1)
                        break
                    end
                    set -a options $argv[$i]
                    set i (math $i + 1)
                end
            case '*'
                # Unknown arg, might be an option
                if not string match -q -- "--*" $argv[$i]
                    set -a options $argv[$i]
                end
        end
        set i (math $i + 1)
    end

    ui-log SELECT-SMART "value='$value' header='$header' options="(count $options)

    # If value provided, validate and return it
    if test -n "$value"
        # Optional: validate against options if provided
        if test (count $options) -gt 0
            if not contains -- "$value" $options
                ui-log SELECT-SMART "Invalid value '$value' not in options"
                printf "Error: '%s' is not a valid option\n" "$value" >&2
                printf "Valid options: %s\n" (string join ", " $options) >&2
                return 1
            end
        end
        echo $value
        return 0
    end

    # No value - check if interactive
    if not ui-is-interactive
        ui-log SELECT-SMART "Not interactive, no value provided"
        printf "Error: No value provided and not running interactively\n" >&2
        if test -n "$header"
            printf "Usage requires: %s\n" (string replace ":" "" "$header") >&2
        end
        return 1
    end

    # Interactive mode - show TUI
    if test (count $options) -eq 0
        ui-log SELECT-SMART "No options provided for interactive selection"
        printf "Error: No options available for selection\n" >&2
        return 1
    end

    set -l selected (ui-choose --header "$header" $options)
    if test -z "$selected"
        ui-log SELECT-SMART "User cancelled selection"
        return 1
    end

    echo $selected
    return 0
end

# Smart input - TUI if interactive and no value, otherwise use provided value
# Usage: ui-input-smart --value "$user_value" --prompt "Enter name:" [--default "foo"] [--required]
function ui-input-smart
    set -l value ""
    set -l prompt ""
    set -l default_val ""
    set -l required false

    # Parse arguments
    set -l i 1
    while test $i -le (count $argv)
        switch $argv[$i]
            case --value
                set i (math $i + 1)
                set value $argv[$i]
            case --prompt
                set i (math $i + 1)
                set prompt $argv[$i]
            case --default
                set i (math $i + 1)
                set default_val $argv[$i]
            case --required
                set required true
        end
        set i (math $i + 1)
    end

    ui-log INPUT-SMART "value='$value' prompt='$prompt' required=$required"

    # If value provided, return it
    if test -n "$value"
        echo $value
        return 0
    end

    # No value - check if interactive
    if not ui-is-interactive
        # Use default if available
        if test -n "$default_val"
            echo $default_val
            return 0
        end

        if test "$required" = "true"
            ui-log INPUT-SMART "Not interactive, no value, required"
            printf "Error: No value provided and not running interactively\n" >&2
            return 1
        end

        return 0
    end

    # Interactive mode - show TUI input
    set -l input_args
    if test -n "$prompt"
        set -a input_args --placeholder "$prompt"
    end
    if test -n "$default_val"
        set -a input_args --value "$default_val"
    end

    set -l entered (ui-input $input_args)

    if test -z "$entered" -a "$required" = "true"
        ui-log INPUT-SMART "User entered empty value but required"
        printf "Error: Value is required\n" >&2
        return 1
    end

    echo $entered
    return 0
end

# Smart confirm - TUI if interactive, otherwise use default
# Usage: ui-confirm-smart --prompt "Continue?" [--default yes|no]
function ui-confirm-smart
    set -l prompt ""
    set -l default_val ""

    # Parse arguments
    set -l i 1
    while test $i -le (count $argv)
        switch $argv[$i]
            case --prompt
                set i (math $i + 1)
                set prompt $argv[$i]
            case --default
                set i (math $i + 1)
                set default_val $argv[$i]
        end
        set i (math $i + 1)
    end

    ui-log CONFIRM-SMART "prompt='$prompt' default='$default_val'"

    # Check if interactive
    if not ui-is-interactive
        # Use default
        if test "$default_val" = "yes"
            return 0
        else
            return 1
        end
    end

    # Interactive mode
    ui-confirm "$prompt"
    return $status
end
