#!/usr/bin/env fish
# Fedpunk Installation Script
#
# Usage: ./install.fish [OPTIONS]
#
# OPTIONS:
#   --terminal-only    Install only terminal components (skip desktop environment)
#   --non-interactive  Run without user prompts (for automated installations)
#   --verbose          Show real-time output from all installation steps
#
# For debugging installation issues, use: ./install.fish --verbose

# Exit immediately if a command exits with a non-zero status
set -e

# Parse command-line flags
set terminal_only false
set non_interactive false
set verbose false

for arg in $argv
    switch $arg
        case --terminal-only
            set terminal_only true
        case --non-interactive
            set non_interactive true
        case --verbose
            set verbose true
    end
end

# Define Fedpunk locations - prefer environment variable, fallback to script location
if not set -q FEDPUNK_PATH
    set script_dir (dirname (status -f))
    set -x FEDPUNK_PATH (realpath "$script_dir")
end
set -x FEDPUNK_INSTALL "$FEDPUNK_PATH/install"
set -x PATH "$FEDPUNK_PATH/bin" $PATH

# Set environment variables based on flags
if test "$terminal_only" = true
    set -x FEDPUNK_TERMINAL_ONLY true
end

if test "$non_interactive" = true
    set -x FEDPUNK_NON_INTERACTIVE true
end

if test "$verbose" = true
    set -x FEDPUNK_VERBOSE true
end

# Color codes
set C_RESET '\033[0m'
set C_GREEN '\033[0;32m'
set C_BLUE '\033[0;34m'
set C_GRAY '\033[0;90m'
set C_YELLOW '\033[0;33m'
set C_RED '\033[0;31m'

# Log file
set -x FEDPUNK_LOG_FILE "/tmp/fedpunk-install-"(date +%Y%m%d-%H%M%S)".log"
echo "Fedpunk Installation Log - "(date) > "$FEDPUNK_LOG_FILE"
echo "=================================" >> "$FEDPUNK_LOG_FILE"
echo "" >> "$FEDPUNK_LOG_FILE"

# Track installation steps
set -g INSTALL_STEPS
set -g STEP_COUNT 0

# Source helper functions (now that log file is set up)
source "$FEDPUNK_INSTALL/helpers/all.fish"

# Clear screen and show banner
clear
echo ""
echo -e "$C_BLUE███████╗███████╗██████╗ ██████╗ ██╗   ██╗███╗   ██╗██╗  ██╗$C_RESET"
echo -e "$C_BLUE██╔════╝██╔════╝██╔══██╗██╔══██╗██║   ██║████╗  ██║██║ ██╔╝$C_RESET"
echo -e "$C_BLUE█████╗  █████╗  ██║  ██║██████╔╝██║   ██║██╔██╗ ██║█████╔╝$C_RESET"
echo -e "$C_BLUE██╔══╝  ██╔══╝  ██║  ██║██╔═══╝ ██║   ██║██║╚██╗██║██╔═██╗$C_RESET"
echo -e "$C_BLUE██║     ███████╗██████╔╝██║     ╚██████╔╝██║ ╚████║██║  ██╗$C_RESET"
echo -e "$C_BLUE╚═╝     ╚══════╝╚═════╝ ╚═╝      ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═╝$C_RESET"
echo ""
info "Installation path: $FEDPUNK_PATH"
info "Log file: $FEDPUNK_LOG_FILE"
echo ""

# Check for existing installation and handle it
set final_path "$HOME/.local/share/fedpunk"
if test -d "$final_path" -a "$FEDPUNK_PATH" != "$final_path"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    warning "Existing Fedpunk installation found at $final_path"
    echo ""

    # Use gum directly
    set replace_choice (gum choose \
        --header "Existing installation found. What would you like to do?" \
        --cursor.foreground="212" \
        "Replace existing installation" \
        "Cancel installation" \
        </dev/tty)

    if test "$replace_choice" = "Cancel installation"
        echo ""
        error "Installation cancelled by user."
        # Clean up temp directory if we cloned there
        if test "$FEDPUNK_PATH" != "$final_path"
            rm -rf "$FEDPUNK_PATH"
        end
        exit 1
    end

    # Remove existing installation
    info "Removing existing installation..."
    rm -rf "$final_path"

    # Move from temp location if needed
    if test "$FEDPUNK_PATH" != "$final_path"
        mv "$FEDPUNK_PATH" "$final_path"
        set -gx FEDPUNK_PATH "$final_path"
    end

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
end

# Interactive prompts (if not already set via environment)
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Profile selection (FIRST - profiles contain modes)
if not set -q FEDPUNK_PROFILE
    echo ""
    set profile_choice (choose "Choose a profile:" \
        "dev (Development + Bitwarden)" \
        "example (Minimal template)" \
        "none (Skip profile)")

    if test -z "$profile_choice"
        error "No profile selected. Exiting."
        exit 1
    else if string match -q "*dev*" "$profile_choice"
        set -gx FEDPUNK_PROFILE "dev"
    else if string match -q "*example*" "$profile_choice"
        set -gx FEDPUNK_PROFILE "example"
    else
        set -gx FEDPUNK_PROFILE "none"
    end

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
end

# Initialize chezmoi and auto-detect mode
echo ""
info "Initializing chezmoi and auto-detecting mode..."

# Ensure chezmoi is available - install if needed
if not command -v chezmoi >/dev/null 2>&1
    info "Installing chezmoi (required for configuration management)..."
    if not contains "$HOME/.local/bin" $PATH
        set -gx PATH "$HOME/.local/bin" $PATH
    end
    sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin" >>$FEDPUNK_LOG_FILE 2>&1
    success "chezmoi installed"
end

# Initialize chezmoi with the source directory
cd "$FEDPUNK_PATH/home"
chezmoi init --source=. >>$FEDPUNK_LOG_FILE 2>&1
if test $status -ne 0
    error "Failed to initialize chezmoi"
    exit 1
end

# Query chezmoi for auto-detected mode and install configuration
set chezmoi_json (chezmoi data --format=json 2>&1)
if test $status -ne 0
    error "Failed to query chezmoi data"
    exit 1
end

# Extract mode and install flags using jq
set -gx FEDPUNK_MODE (echo $chezmoi_json | jq -r '.mode.name')
info "Auto-detected mode: $FEDPUNK_MODE"

# Set all FEDPUNK_INSTALL_* environment variables from chezmoi data
echo $chezmoi_json | jq -r '.install | to_entries[] | "set -gx FEDPUNK_INSTALL_\(.key | ascii_upcase) \(.value)"' | source

success "Mode configuration loaded from chezmoi"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Verify sudo credentials early (so we don't get interrupted later)
gum style --foreground 33 "→ Verifying sudo credentials..."
if not sudo -n true 2>/dev/null
    gum style --foreground 33 "→ Sudo privileges required. Please enter your password:"
    if not sudo true
        gum style --foreground 9 --bold "✗ Failed to obtain sudo privileges. Installation cannot continue."
        exit 1
    end
end
gum style --foreground 35 "✓ Sudo credentials verified"
echo ""

# Run each installation phase with proper logging
run_script "$FEDPUNK_INSTALL/preflight/all.fish" "Shared System Setup & Preflight"

# Desktop preflight (system upgrade, firmware, RPM Fusion, etc.)
# This is automatically set based on the detected mode in .chezmoi.toml.tmpl
if test "$FEDPUNK_INSTALL_DESKTOP_PREFLIGHT" = "true"
    run_script "$FEDPUNK_INSTALL/desktop/preflight/all.fish" "Desktop System Setup"
else
    info "Skipping desktop system setup"
    echo "[SKIPPED] Desktop system setup (FEDPUNK_INSTALL_DESKTOP_PREFLIGHT=false)" >> "$FEDPUNK_LOG_FILE"
end

run_script "$FEDPUNK_INSTALL/packaging/all.fish" "Package Installation"

# Deploy all configurations with chezmoi BEFORE running config scripts that depend on them
echo ""
info "Deploying all configurations with chezmoi"
cd "$FEDPUNK_PATH/home"

# Run chezmoi apply with real-time output and timeout to prevent hanging
# This will deploy configs AND run post-deployment scripts automatically
info "Running: chezmoi apply --force --verbose (timeout: 5 minutes)"
echo "Real-time output:"
if timeout 300 chezmoi apply --force --verbose 2>&1 | tee -a "$FEDPUNK_LOG_FILE"
    success "All configurations deployed successfully"
    success "Post-deployment setup completed (run_once scripts)"
else
    error "Failed to deploy configurations with chezmoi (exit code: $status)"
    error "Check the output above and log file: $FEDPUNK_LOG_FILE"
    exit 1
end

run_script "$FEDPUNK_INSTALL/post-install/all.fish" "Post-Installation Setup"

# Activate profile if selected
if set -q FEDPUNK_PROFILE; and test "$FEDPUNK_PROFILE" != "none"
    echo ""
    info "Activating profile: $FEDPUNK_PROFILE"
    if test -f "$HOME/.local/bin/fedpunk-activate-profile"
        if fish "$HOME/.local/bin/fedpunk-activate-profile" "$FEDPUNK_PROFILE"
            success "Profile '$FEDPUNK_PROFILE' activated successfully"
        else
            warning "Profile activation had some issues (check output above)"
        end
    else
        warning "fedpunk-activate-profile not found, skipping profile activation"
        echo "  You can activate it later with: fedpunk-activate-profile $FEDPUNK_PROFILE"
    end
else
    info "No profile selected, skipping profile activation"
end

echo ""
echo "========================================" >> "$FEDPUNK_LOG_FILE"
echo "INSTALLATION SUMMARY" >> "$FEDPUNK_LOG_FILE"
echo "Completed at: "(date) >> "$FEDPUNK_LOG_FILE"
echo "========================================" >> "$FEDPUNK_LOG_FILE"
echo "" >> "$FEDPUNK_LOG_FILE"
echo "Steps executed:" >> "$FEDPUNK_LOG_FILE"
for step in $INSTALL_STEPS
    echo "  $step" >> "$FEDPUNK_LOG_FILE"
end
echo "" >> "$FEDPUNK_LOG_FILE"

echo ""
echo -e "$C_GREEN━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$C_RESET"
echo -e "$C_GREEN🎉 Fedpunk installation complete!$C_RESET"
echo -e "$C_GREEN━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━$C_RESET"
echo ""
echo -e "$C_BLUE📋 Installation Summary:$C_RESET"
for step in $INSTALL_STEPS
    echo "  $step"
end
echo ""
echo -e "$C_BLUE🚀 Next steps:$C_RESET"
echo "  • Restart your terminal or run: exec fish"
echo "  • Log out and select 'Hyprland' from your display manager"
echo "  • Or run 'Hyprland' from a TTY"
echo ""
echo -e "$C_BLUE⌨️  Hyprland key bindings:$C_RESET"
echo "  Super+Return: Terminal    │  Super+Space: Launcher"
echo "  Super+Q: Close window     │  Super+Ctrl+T: Theme selector"
echo "  Super+1-9: Workspaces     │  Print: Screenshot"
echo ""
echo -e "$C_GRAY📄 Full installation log saved to: $FEDPUNK_LOG_FILE$C_RESET"
echo ""
