#!/usr/bin/env fish
# Helper functions for Fedpunk installation (Fish version)
# Provides consistent gum-based interface for all installation scripts

# Color codes (fallback for non-gum scenarios)
set -gx FEDPUNK_COLOR_RESET '\033[0m'
set -gx FEDPUNK_COLOR_GREEN '\033[0;32m'
set -gx FEDPUNK_COLOR_BLUE '\033[0;34m'
set -gx FEDPUNK_COLOR_YELLOW '\033[0;33m'
set -gx FEDPUNK_COLOR_RED '\033[0;31m'
set -gx FEDPUNK_COLOR_GRAY '\033[0;90m'

# Gum color numbers (256-color palette)
set -gx GUM_INFO 33      # Blue
set -gx GUM_SUCCESS 35   # Green/Cyan
set -gx GUM_WARNING 214  # Orange
set -gx GUM_ERROR 9      # Red

# Get log file from environment (set by bash install.sh)
# This should ALWAYS be set by the main install.sh script
if not set -q FEDPUNK_LOG_FILE
    # Fallback: create new log file (shouldn't normally happen)
    set -gx FEDPUNK_LOG_FILE "/tmp/fedpunk-install-"(date +%Y%m%d-%H%M%S)".log"
    echo "Fedpunk Installation Log - "(date) > $FEDPUNK_LOG_FILE
    echo "=================================" >> $FEDPUNK_LOG_FILE
    echo "" >> $FEDPUNK_LOG_FILE
    echo "[WARNING] Log file not inherited from parent script - creating new one" >> $FEDPUNK_LOG_FILE
    echo "" >> $FEDPUNK_LOG_FILE
else
    # Log that we're using the inherited log file
    echo "" >> $FEDPUNK_LOG_FILE
    echo "[INFO] "(date +%H:%M:%S)" Using log file: $FEDPUNK_LOG_FILE" >> $FEDPUNK_LOG_FILE
end

# Print info message using gum
function info
    gum style --foreground $GUM_INFO "→ $argv"
    echo "[INFO] "(date +%H:%M:%S)" $argv" >> $FEDPUNK_LOG_FILE
end

# Print success message using gum
function success
    gum style --foreground $GUM_SUCCESS "✓ $argv"
    echo "[SUCCESS] "(date +%H:%M:%S)" $argv" >> $FEDPUNK_LOG_FILE
end

# Print warning message using gum
function warning
    gum style --foreground $GUM_WARNING --bold "⚠ $argv"
    echo "[WARNING] "(date +%H:%M:%S)" $argv" >> $FEDPUNK_LOG_FILE
end

# Print error message using gum
function error
    gum style --foreground $GUM_ERROR --bold "✗ $argv"
    echo "[ERROR] "(date +%H:%M:%S)" $argv" >> $FEDPUNK_LOG_FILE
end

# Print section header using gum
function section
    echo ""
    gum style \
        --foreground $GUM_INFO \
        --border double \
        --border-foreground $GUM_INFO \
        --padding "0 2" \
        --margin "0 2" \
        "$argv"
    echo ""
    echo "" >> $FEDPUNK_LOG_FILE
    echo "========================================" >> $FEDPUNK_LOG_FILE
    echo "=== $argv ===" >> $FEDPUNK_LOG_FILE
    echo "Time: "(date) >> $FEDPUNK_LOG_FILE
    echo "========================================" >> $FEDPUNK_LOG_FILE
    echo "" >> $FEDPUNK_LOG_FILE
end

# Run command with gum spinner, show output only on failure
function run_quiet
    set description $argv[1]
    set cmd $argv[2..-1]
    set temp_output (mktemp)

    echo "" >> $FEDPUNK_LOG_FILE
    echo "[RUN] "(date +%H:%M:%S)" $description" >> $FEDPUNK_LOG_FILE
    echo "Command: $cmd" >> $FEDPUNK_LOG_FILE

    # Run with spinner visible to user, capture command output to temp file
    set -l full_cmd "begin; $cmd; end >>'"$temp_output"' 2>&1"
    if gum spin --spinner dot --title "$description..." -- fish -c "$full_cmd"
        cat $temp_output >> $FEDPUNK_LOG_FILE
        success "$description"
        rm -f $temp_output
        return 0
    else
        set exit_code $status
        echo "Exit code: $exit_code" >> $FEDPUNK_LOG_FILE
        cat $temp_output >> $FEDPUNK_LOG_FILE
        error "$description failed (exit code: $exit_code)"
        echo ""

        # Show last 10 lines of error output
        gum style --foreground $GUM_ERROR --bold "Error details (last 10 lines):"
        tail -10 $temp_output | sed 's/^/  /'

        echo ""
        gum style --foreground $FEDPUNK_COLOR_GRAY "→ Full logs: $FEDPUNK_LOG_FILE"
        gum style --foreground $FEDPUNK_COLOR_GRAY "→ View with: tail -50 $FEDPUNK_LOG_FILE"

        rm -f $temp_output
        return $exit_code
    end
end

# Run command with gum spinner (simple version - always show result)
function step
    set description $argv[1]
    set cmd $argv[2..-1]
    set temp_output (mktemp)

    echo "" >> $FEDPUNK_LOG_FILE
    echo "[STEP] "(date +%H:%M:%S)" $description" >> $FEDPUNK_LOG_FILE
    echo "Command: $cmd" >> $FEDPUNK_LOG_FILE

    # Run with spinner visible to user, capture command output to temp file
    set -l full_cmd "begin; $cmd; end >>'"$temp_output"' 2>&1"
    if gum spin --spinner dot --title "$description..." -- fish -c "$full_cmd"
        cat $temp_output >> $FEDPUNK_LOG_FILE
        # Move to start of line and print success (overwrites spinner line)
        printf "\r"
        gum style --foreground $GUM_SUCCESS "✓ $description"
        echo "[SUCCESS] "(date +%H:%M:%S)" $description" >> $FEDPUNK_LOG_FILE
        rm -f $temp_output
        return 0
    else
        set exit_code $status
        echo "Exit code: $exit_code" >> $FEDPUNK_LOG_FILE
        cat $temp_output >> $FEDPUNK_LOG_FILE
        # Move to start of line and print error (overwrites spinner line)
        printf "\r"
        gum style --foreground $GUM_ERROR --bold "✗ $description failed (exit: $exit_code)"
        echo "[ERROR] "(date +%H:%M:%S)" $description failed (exit: $exit_code)" >> $FEDPUNK_LOG_FILE

        # Show error details
        echo ""
        gum style --foreground $GUM_ERROR "Error details:"
        tail -5 $temp_output | sed 's/^/  /'
        echo ""
        gum style --foreground $FEDPUNK_COLOR_GRAY "→ Full logs: $FEDPUNK_LOG_FILE"

        rm -f $temp_output
        return $exit_code
    end
end

# Yes/No confirmation prompt using gum
function confirm
    set prompt $argv[1]

    echo "" >> $FEDPUNK_LOG_FILE
    echo "[PROMPT] "(date +%H:%M:%S)" $prompt" >> $FEDPUNK_LOG_FILE

    if gum confirm "$prompt"
        echo "[RESPONSE] "(date +%H:%M:%S)" Yes" >> $FEDPUNK_LOG_FILE
        return 0
    else
        echo "[RESPONSE] "(date +%H:%M:%S)" No" >> $FEDPUNK_LOG_FILE
        return 1
    end
end

# Display a styled box message
function box
    set message $argv[1]
    set color $argv[2]

    if test -z "$color"
        set color $GUM_INFO
    end

    gum style \
        --foreground $color \
        --border rounded \
        --border-foreground $color \
        --padding "0 1" \
        --margin "0 0" \
        "$message"
end

# Display progress indicator
function progress
    set current $argv[1]
    set total $argv[2]
    set description $argv[3]

    gum style --foreground $GUM_INFO "[$current/$total] $description"
end
