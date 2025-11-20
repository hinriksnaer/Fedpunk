#!/usr/bin/env fish
# Helper functions for Fedpunk installation (Fish version)
# Provides consistent gum-based interface for all installation scripts

# Detect if we need sudo (not needed if running as root)
if test (id -u) -eq 0
    set -gx SUDO_CMD ""
else
    set -gx SUDO_CMD "sudo"
end

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

# Get log file from environment (set by boot script or install.fish)
# This should ALWAYS be set by the main installation script
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

# Require TTY access for interactive prompts
# Usage: require_tty "Component Name" "ENV_VAR1=value1|value2" "ENV_VAR2=value"
# Checks if TTY is available for interactive prompts. If not, displays error
# with instructions on which environment variables can be set instead.
# Exits with error code 1 if TTY is not available.
function require_tty
    # Check if /dev/tty exists and is accessible
    if test -e /dev/tty
        return 0
    end

    # No TTY available - print error and exit
    set component_name $argv[1]
    set env_vars $argv[2..-1]

    echo "" >> $FEDPUNK_LOG_FILE
    echo "[ERROR] "(date +%H:%M:%S)" No TTY available for $component_name" >> $FEDPUNK_LOG_FILE

    echo ""
    error "No TTY available for interactive prompts"
    echo ""
    gum style --foreground $GUM_ERROR "The $component_name requires user input, but no terminal is available."
    echo ""

    if test (count $env_vars) -gt 0
        gum style --foreground $GUM_INFO "To run non-interactively, set these environment variables:"
        echo ""
        for var in $env_vars
            gum style --foreground $GUM_SUCCESS "  export $var"
        end
        echo ""
        echo "[ERROR] Missing environment variables: "(string join ", " $env_vars) >> $FEDPUNK_LOG_FILE
    else
        gum style --foreground $GUM_WARNING "This component has no environment variable override."
        gum style --foreground $GUM_WARNING "It must be run with a TTY attached."
        echo ""
        echo "[ERROR] No environment variable override available" >> $FEDPUNK_LOG_FILE
    end

    echo "For more information, see the Fedpunk documentation."
    echo ""

    exit 1
end

# Yes/No confirmation prompt using gum
# Usage: confirm "prompt text"
# Prompts user for yes/no confirmation. Requires TTY access.
function confirm
    set prompt $argv[1]

    echo "" >> $FEDPUNK_LOG_FILE
    echo "[PROMPT] "(date +%H:%M:%S)" $prompt" >> $FEDPUNK_LOG_FILE

    # Prompt user (requires TTY)
    # Redirect from /dev/tty for piped execution (curl | bash)
    if gum confirm "$prompt" </dev/tty
        echo "[RESPONSE] "(date +%H:%M:%S)" Yes" >> $FEDPUNK_LOG_FILE
        return 0
    else
        echo "[RESPONSE] "(date +%H:%M:%S)" No" >> $FEDPUNK_LOG_FILE
        return 1
    end
end

# Multiple choice selection using gum
# Usage: choose "header text" "option1" "option2" ...
# Returns selected option via stdout, empty string if cancelled. Requires TTY access.
function choose
    set -l header $argv[1]
    set -l options $argv[2..-1]

    echo "" >> $FEDPUNK_LOG_FILE
    echo "[CHOOSE] "(date +%H:%M:%S)" $header" >> $FEDPUNK_LOG_FILE
    echo "Options: "(string join ", " $options) >> $FEDPUNK_LOG_FILE

    # Prompt user (requires TTY)
    set selected (gum choose \
        --header "$header" \
        --cursor.foreground="212" \
        $options \
        </dev/tty)

    if test -z "$selected"
        echo "[RESPONSE] "(date +%H:%M:%S)" Cancelled" >> $FEDPUNK_LOG_FILE
        echo ""
        return 1
    else
        echo "[RESPONSE] "(date +%H:%M:%S)" Selected: $selected" >> $FEDPUNK_LOG_FILE
        echo "$selected"
        return 0
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

# Subsection header (smaller than section)
function subsection
    set title $argv[1]
    echo ""
    info "$title"
end

# Optional component wrapper
# Returns 0 (true) if user opts in, 1 (false) if user opts out
# Handles logging of skipped components automatically
# Usage: if opt_in "Install X?" "default"; then ... end
function opt_in
    set description $argv[1]
    set default $argv[2]

    # Default to "no" if not specified
    if test -z "$default"
        set default "no"
    end

    echo ""
    if confirm "$description" "$default"
        return 0
    else
        info "Skipping: "(string replace -r '\?' '' "$description")
        echo "[SKIPPED] $description - declined by user" >> $FEDPUNK_LOG_FILE
        return 1
    end
end

# Conditional installation wrapper with environment variable support
# Checks env var set by mode, otherwise prompts user
# Usage: install_if_enabled "FEDPUNK_INSTALL_YAZI" "Install Yazi file manager?" "$FEDPUNK_INSTALL/terminal/packaging/yazi.fish" "yes"
function install_if_enabled
    set env_var $argv[1]         # Environment variable name
    set prompt_text $argv[2]
    set script_path $argv[3]
    set default $argv[4]

    # Default to "yes" if not specified
    if test -z "$default"
        set default "yes"
    end

    # Check if environment variable is set by mode
    echo ""
    if not set -q $env_var
        # Not set by mode - prompt user
        if confirm "$prompt_text" "$default"
            set -gx $env_var true
        else
            set -gx $env_var false
        end
    else
        # Flag set by mode - log it
        info "$prompt_text [mode: $$env_var]"
    end

    # Install if enabled
    if test "$$env_var" = "true"
        source "$script_path"
    else
        set component_name (string replace -r '\?' '' "$prompt_text" | string trim)
        info "Skipping $component_name"
        echo "[SKIPPED] $component_name ($env_var=false)" >> $FEDPUNK_LOG_FILE
    end
end

# Run a fish script with logging and step tracking
# Usage: run_script script_path description
function run_script
    set script_name $argv[1]
    set description $argv[2]

    # Track step count (global variable set by install.fish)
    if set -q STEP_COUNT
        set -g STEP_COUNT (math $STEP_COUNT + 1)
    else
        set -g STEP_COUNT 1
    end

    echo "" >> "$FEDPUNK_LOG_FILE"
    echo "========================================" >> "$FEDPUNK_LOG_FILE"
    echo "STEP $STEP_COUNT: $description" >> "$FEDPUNK_LOG_FILE"
    echo "Script: $script_name" >> "$FEDPUNK_LOG_FILE"
    echo "Time: "(date) >> "$FEDPUNK_LOG_FILE"
    echo "========================================" >> "$FEDPUNK_LOG_FILE"
    echo "" >> "$FEDPUNK_LOG_FILE"

    info "Step $STEP_COUNT: $description"
    gum style --foreground $FEDPUNK_COLOR_GRAY "  → Running: $script_name"

    # Ensure cargo and local bin are in PATH
    if not contains "$HOME/.cargo/bin" $PATH
        set -gx PATH "$HOME/.cargo/bin" $PATH
    end
    if not contains "$HOME/.local/bin" $PATH
        set -gx PATH "$HOME/.local/bin" $PATH
    end

    # Run script with verbose mode check
    if set -q FEDPUNK_VERBOSE
        echo "  Running with verbose output enabled..."
        source "$script_name" 2>&1 | tee -a "$FEDPUNK_LOG_FILE"
        set script_result $pipestatus[1]
    else
        source "$script_name"
        set script_result $status
    end

    if test $script_result -eq 0
        # Track in global INSTALL_STEPS if it exists
        if set -q INSTALL_STEPS
            set -g INSTALL_STEPS $INSTALL_STEPS "✓ $description"
        end
        success "Completed: $description"
        echo "" >> "$FEDPUNK_LOG_FILE"
        echo "[STEP $STEP_COUNT COMPLETED]" >> "$FEDPUNK_LOG_FILE"
        echo "" >> "$FEDPUNK_LOG_FILE"
        return 0
    else
        set exit_code $script_result
        if set -q INSTALL_STEPS
            set -g INSTALL_STEPS $INSTALL_STEPS "✗ $description (exit code: $exit_code)"
        end
        error "Failed: $description (exit code: $exit_code)"
        echo "" >> "$FEDPUNK_LOG_FILE"
        echo "[STEP $STEP_COUNT FAILED - EXIT CODE: $exit_code]" >> "$FEDPUNK_LOG_FILE"
        echo "" >> "$FEDPUNK_LOG_FILE"
        return $exit_code
    end
end

# Install a single package with standard pattern
# Usage: install_package package_name
function install_package
    set package_name $argv[1]

    # Check if already installed
    if rpm -q $package_name >/dev/null 2>&1
        success "$package_name already installed"
        return 0
    end

    step "Installing $package_name" "sudo dnf install -qy $package_name"
end

# Install multiple packages at once
# Usage: install_packages pkg1 pkg2 pkg3 ...
function install_packages
    set packages $argv

    # Check which packages are already installed
    set packages_to_install
    for pkg in $packages
        if not rpm -q $pkg >/dev/null 2>&1
            set -a packages_to_install $pkg
        end
    end

    # If all packages are installed, just report success
    if test (count $packages_to_install) -eq 0
        success "All packages already installed: "(string join ", " $packages)
        return 0
    end

    # Install only missing packages
    step "Installing packages: "(string join ", " $packages_to_install) "sudo dnf install -qy $packages_to_install"
end

# Enable a COPR repository
# Usage: install_copr repo_name
function install_copr
    set repo_name $argv[1]
    step "Enabling COPR repository: $repo_name" "sudo dnf copr enable -qy $repo_name"
end

# Download and extract archive
# Usage: download_and_extract URL dest_dir [archive_type]
# archive_type: auto (default), tar, tar.gz, tar.xz, zip
function download_and_extract
    set url $argv[1]
    set dest_dir $argv[2]
    set archive_type $argv[3]

    # Auto-detect archive type if not specified
    if test -z "$archive_type"
        if string match -q "*.tar.xz" "$url"
            set archive_type "tar.xz"
        else if string match -q "*.tar.gz" "$url"
            set archive_type "tar.gz"
        else if string match -q "*.zip" "$url"
            set archive_type "zip"
        else if string match -q "*.tar" "$url"
            set archive_type "tar"
        else
            set archive_type "auto"
        end
    end

    set temp_file (mktemp)

    # Download
    gum spin --spinner line --title "Downloading "(basename $url)"..." -- fish -c '
        curl -fL --retry 2 -o "'$temp_file'" "'$url'" >>'"$FEDPUNK_LOG_FILE"' 2>&1
    '

    if test $status -ne 0
        error "Failed to download "(basename $url)
        rm -f $temp_file
        return 1
    end

    # Extract based on type
    mkdir -p "$dest_dir"
    switch $archive_type
        case "tar.xz"
            gum spin --spinner dot --title "Extracting archive..." -- fish -c '
                tar -xJf "'$temp_file'" -C "'$dest_dir'" >>'"$FEDPUNK_LOG_FILE"' 2>&1
            '
        case "tar.gz"
            gum spin --spinner dot --title "Extracting archive..." -- fish -c '
                tar -xzf "'$temp_file'" -C "'$dest_dir'" >>'"$FEDPUNK_LOG_FILE"' 2>&1
            '
        case "tar"
            gum spin --spinner dot --title "Extracting archive..." -- fish -c '
                tar -xf "'$temp_file'" -C "'$dest_dir'" >>'"$FEDPUNK_LOG_FILE"' 2>&1
            '
        case "zip"
            gum spin --spinner dot --title "Extracting archive..." -- fish -c '
                unzip -o -q "'$temp_file'" -d "'$dest_dir'" >>'"$FEDPUNK_LOG_FILE"' 2>&1
            '
        case "*"
            error "Unknown archive type: $archive_type"
            rm -f $temp_file
            return 1
    end

    set extract_result $status
    rm -f $temp_file

    if test $extract_result -eq 0
        success "Extracted to $dest_dir"
        return 0
    else
        error "Failed to extract archive"
        return 1
    end
end

# Ensure FEDPUNK environment variables are set
# Usage: ensure_fedpunk_env
function ensure_fedpunk_env
    if not set -q FEDPUNK_PATH
        set -gx FEDPUNK_PATH "$HOME/.local/share/fedpunk"
    end
    if not set -q FEDPUNK_INSTALL
        set -gx FEDPUNK_INSTALL "$FEDPUNK_PATH/install"
    end
    if not set -q FEDPUNK_LOG_FILE
        set -gx FEDPUNK_LOG_FILE "/tmp/fedpunk-install-"(date +%Y%m%d-%H%M%S)".log"
        echo "Fedpunk Installation Log - "(date) > $FEDPUNK_LOG_FILE
        echo "=================================" >> $FEDPUNK_LOG_FILE
        echo "" >> $FEDPUNK_LOG_FILE
    end
end

# Install a command if it's not already available
# Usage: install_if_missing command_name package_name [install_method]
# install_method: "dnf" (default), "cargo", "script"
function install_if_missing
    set cmd_name $argv[1]
    set pkg_name $argv[2]
    set install_method $argv[3]

    if test -z "$install_method"
        set install_method "dnf"
    end

    if command -v $cmd_name >/dev/null 2>&1
        success "$cmd_name already installed"
        return 0
    end

    switch $install_method
        case "dnf"
            step "Installing $pkg_name" "$SUDO_CMD dnf install -qy $pkg_name"
        case "cargo"
            step "Installing $pkg_name via Cargo" "cargo install $pkg_name"
        case "*"
            error "Unknown install method: $install_method"
            return 1
    end
end

# Detect GPU type
# Usage: set gpu_type (detect_gpu)
# Returns: nvidia, amd, intel, or other
function detect_gpu
    # Check if lspci command exists (not available in containers)
    if not command -v lspci >/dev/null 2>&1
        echo "other"
        return 0
    end

    if lspci 2>/dev/null | grep -i nvidia >/dev/null 2>&1
        echo "nvidia"
        return 0
    else if lspci 2>/dev/null | grep -i amd >/dev/null 2>&1
        echo "amd"
        return 0
    else if lspci 2>/dev/null | grep -i intel.*graphics >/dev/null 2>&1
        echo "intel"
        return 0
    else
        echo "other"
        return 0
    end
end

# Get number of CPU cores for parallel builds
# Usage: set cores (get_cpu_cores)
function get_cpu_cores
    if command -v nproc >/dev/null 2>&1
        nproc
    else
        echo "4"  # Reasonable default
    end
end

# Load mode configuration from YAML file
# Usage: load_mode_config
# Sets FEDPUNK_INSTALL_* environment variables from modes/$FEDPUNK_MODE.yaml
function load_mode_config
    if not set -q FEDPUNK_MODE
        warning "FEDPUNK_MODE not set, cannot load mode configuration"
        return 1
    end

    if not set -q FEDPUNK_REPO_ROOT
        error "FEDPUNK_REPO_ROOT not set, cannot load mode configuration"
        return 1
    end

    set mode_file "$FEDPUNK_REPO_ROOT/modes/$FEDPUNK_MODE.yaml"
    if not test -f "$mode_file"
        warning "Mode file not found: $mode_file"
        return 1
    end

    # Parse YAML and set environment variables
    # Format: key: value → set -gx FEDPUNK_INSTALL_KEY value
    for line in (cat "$mode_file")
        # Skip empty lines, comments, and section headers
        if string match -qr '^\s*$|^\s*#|^mode:|^description:|^install:' "$line"
            continue
        end

        # Parse key: value pairs
        if string match -qr '^\s+(\w+):\s+(true|false)' "$line"
            set key (string replace -r '^\s+(\w+):.*' '$1' "$line")
            set value (string replace -r '.*:\s+(\w+).*' '$1' "$line")

            # Convert to environment variable name (uppercase with FEDPUNK_INSTALL_ prefix)
            set var_name (string upper "FEDPUNK_INSTALL_$key")
            set -gx $var_name "$value"
        end
    end
end
