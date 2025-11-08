#!/usr/bin/env fish
# Helper functions for Fedpunk installation (Fish version)

# Color codes
set -gx FEDPUNK_COLOR_RESET '\033[0m'
set -gx FEDPUNK_COLOR_GREEN '\033[0;32m'
set -gx FEDPUNK_COLOR_BLUE '\033[0;34m'
set -gx FEDPUNK_COLOR_YELLOW '\033[0;33m'
set -gx FEDPUNK_COLOR_RED '\033[0;31m'
set -gx FEDPUNK_COLOR_GRAY '\033[0;90m'

# Get log file from environment (set by bash helpers)
if not set -q FEDPUNK_LOG_FILE
    set -gx FEDPUNK_LOG_FILE "/tmp/fedpunk-install-"(date +%Y%m%d-%H%M%S)".log"
    echo "Fedpunk Installation Log - "(date) > $FEDPUNK_LOG_FILE
    echo "=================================" >> $FEDPUNK_LOG_FILE
    echo "" >> $FEDPUNK_LOG_FILE
end

# Print info message
function info
    echo -e "$FEDPUNK_COLOR_BLUE→$FEDPUNK_COLOR_RESET $argv"
    echo "[INFO] $argv" >> $FEDPUNK_LOG_FILE
end

# Print success message
function success
    echo -e "$FEDPUNK_COLOR_GREEN✓$FEDPUNK_COLOR_RESET $argv"
    echo "[SUCCESS] $argv" >> $FEDPUNK_LOG_FILE
end

# Print warning message
function warning
    echo -e "$FEDPUNK_COLOR_YELLOW⚠$FEDPUNK_COLOR_RESET $argv"
    echo "[WARNING] $argv" >> $FEDPUNK_LOG_FILE
end

# Print error message
function error
    echo -e "$FEDPUNK_COLOR_RED✗$FEDPUNK_COLOR_RESET $argv"
    echo "[ERROR] $argv" >> $FEDPUNK_LOG_FILE
end

# Print section header
function section
    echo ""
    echo -e "$FEDPUNK_COLOR_BLUE━━━ $argv ━━━$FEDPUNK_COLOR_RESET"
    echo "" >> $FEDPUNK_LOG_FILE
    echo "=== $argv ===" >> $FEDPUNK_LOG_FILE
    echo "" >> $FEDPUNK_LOG_FILE
end

# Run command quietly, show output only on failure
function run_quiet
    set description $argv[1]
    set cmd $argv[2..-1]
    set temp_output (mktemp)

    echo -n "  $description... "
    echo "Running: $cmd" >> $FEDPUNK_LOG_FILE

    if eval $cmd >$temp_output 2>&1
        echo -e "$FEDPUNK_COLOR_GREEN✓$FEDPUNK_COLOR_RESET"
        cat $temp_output >> $FEDPUNK_LOG_FILE
        rm -f $temp_output
        return 0
    else
        echo -e "$FEDPUNK_COLOR_RED✗$FEDPUNK_COLOR_RESET"
        echo ""
        echo -e "$FEDPUNK_COLOR_RED"Error output:"$FEDPUNK_COLOR_RESET"
        cat $temp_output
        cat $temp_output >> $FEDPUNK_LOG_FILE
        rm -f $temp_output
        echo ""
        echo -e "$FEDPUNK_COLOR_GRAY"Full logs: $FEDPUNK_LOG_FILE"$FEDPUNK_COLOR_RESET"
        return 1
    end
end
