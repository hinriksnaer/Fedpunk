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
    set -x FEDPUNK_SKIP_DESKTOP true
end

if test "$non_interactive" = true
    set -x FEDPUNK_NON_INTERACTIVE true
end

if test "$verbose" = true
    set -x FEDPUNK_VERBOSE true
end

# If FEDPUNK_TERMINAL_ONLY is already set via environment, ensure FEDPUNK_SKIP_DESKTOP is also set
if set -q FEDPUNK_TERMINAL_ONLY; and test "$FEDPUNK_TERMINAL_ONLY" = "true"
    set -x FEDPUNK_SKIP_DESKTOP true
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

# Helper functions
function info
    echo -e "$C_BLUE→$C_RESET $argv"
    echo "[INFO] "(date '+%H:%M:%S')" $argv" >> "$FEDPUNK_LOG_FILE"
end

function success
    echo -e "$C_GREEN✓$C_RESET $argv"
    echo "[SUCCESS] "(date '+%H:%M:%S')" $argv" >> "$FEDPUNK_LOG_FILE"
end

function warning
    echo -e "$C_YELLOW⚠$C_RESET $argv"
    echo "[WARNING] "(date '+%H:%M:%S')" $argv" >> "$FEDPUNK_LOG_FILE"
end

function error
    echo -e "$C_RED✗$C_RESET $argv"
    echo "[ERROR] "(date '+%H:%M:%S')" $argv" >> "$FEDPUNK_LOG_FILE"
end

# Run a fish script with logging
function run_fish_script
    set script_name $argv[1]
    set description $argv[2]

    set -g STEP_COUNT (math $STEP_COUNT + 1)

    echo "" >> "$FEDPUNK_LOG_FILE"
    echo "========================================" >> "$FEDPUNK_LOG_FILE"
    echo "STEP $STEP_COUNT: $description" >> "$FEDPUNK_LOG_FILE"
    echo "Script: $script_name" >> "$FEDPUNK_LOG_FILE"
    echo "Time: "(date) >> "$FEDPUNK_LOG_FILE"
    echo "========================================" >> "$FEDPUNK_LOG_FILE"
    echo "" >> "$FEDPUNK_LOG_FILE"

    info "Step $STEP_COUNT: $description"
    
    # Show which script is running for transparency
    echo -e "$C_BLUE  → Running: $script_name$C_RESET"
    
    # Ensure cargo is in PATH before each step (may have been installed in earlier steps)
    # Always try to add cargo to PATH if it's not already there, regardless of directory existence
    # This handles cases where cargo gets installed during the process
    if not contains "$HOME/.cargo/bin" $PATH
        set -gx PATH "$HOME/.cargo/bin" $PATH
    end

    # Add verbose mode check - if FEDPUNK_VERBOSE is set, show real-time output
    if set -q FEDPUNK_VERBOSE
        echo "  Running with verbose output enabled..."
        source "$script_name" 2>&1 | tee -a "$FEDPUNK_LOG_FILE"
        set script_result $pipestatus[1]
    else
        source "$script_name"
        set script_result $status
    end
    
    if test $script_result -eq 0
        set -g INSTALL_STEPS $INSTALL_STEPS "✓ $description"
        success "Completed: $description"
        echo "" >> "$FEDPUNK_LOG_FILE"
        echo "[STEP $STEP_COUNT COMPLETED]" >> "$FEDPUNK_LOG_FILE"
        echo "" >> "$FEDPUNK_LOG_FILE"
        return 0
    else
        set exit_code $status
        set -g INSTALL_STEPS $INSTALL_STEPS "✗ $description (exit code: $exit_code)"
        error "Failed: $description (exit code: $exit_code)"
        echo "" >> "$FEDPUNK_LOG_FILE"
        echo "[STEP $STEP_COUNT FAILED - EXIT CODE: $exit_code]" >> "$FEDPUNK_LOG_FILE"
        echo "" >> "$FEDPUNK_LOG_FILE"
        return $exit_code
    end
end

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

# Interactive prompts (if not already set via environment)
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Installation mode selection
if not set -q FEDPUNK_TERMINAL_ONLY
    echo "Choose your installation mode:"
    echo ""

    # Check if headless
    if test -z "$DISPLAY" -a -z "$WAYLAND_DISPLAY" -a -z "$XDG_SESSION_TYPE"
        echo "⚠️  Note: No display server detected (headless environment)"
        echo "   Desktop mode can still be installed for later use"
        echo ""
    end

    # Try gum with timeout, fallback to bash select
    set install_mode ""
    gum choose --timeout=5s \
        "Desktop (Full: Hyprland + Terminal)" \
        "Terminal-only (Servers/Containers)" </dev/tty 2>/dev/null | read install_mode

    if test -z "$install_mode"
        # Fallback to bash select
        echo "Using text menu (select mode):"
        bash -c 'PS3="Enter number (1-2): "; select opt in "Desktop (Full: Hyprland + Terminal)" "Terminal-only (Servers/Containers)"; do echo $opt; break; done </dev/tty' | read install_mode
    end

    if test -z "$install_mode"
        error "No installation mode selected. Exiting."
        exit 1
    else if test "$install_mode" = "Terminal-only (Servers/Containers)"
        echo "📟 Installing: Terminal-only mode"
        set -gx FEDPUNK_TERMINAL_ONLY true
        set -gx FEDPUNK_SKIP_DESKTOP true
    else
        echo "🖥️  Installing: Full desktop environment"
    end

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
end

# Profile selection
if not set -q FEDPUNK_PROFILE
    echo "Choose a profile to activate:"
    echo ""

    # Try gum with timeout, fallback to bash select
    set profile_choice ""
    gum choose --timeout=5s \
        "dev (Development tools + Bitwarden)" \
        "example (Minimal template)" \
        "none (Skip profile activation)" </dev/tty 2>/dev/null | read profile_choice

    if test -z "$profile_choice"
        # Fallback to bash select
        echo "Using text menu (select mode):"
        bash -c 'PS3="Enter number (1-3): "; select opt in "dev (Development tools + Bitwarden)" "example (Minimal template)" "none (Skip profile activation)"; do echo $opt; break; done </dev/tty' | read profile_choice
    end

    if test -z "$profile_choice"
        error "No profile selected. Exiting."
        exit 1
    else if test "$profile_choice" = "dev (Development tools + Bitwarden)"
        echo "📦 Profile: dev"
        set -gx FEDPUNK_PROFILE "dev"
    else if test "$profile_choice" = "example (Minimal template)"
        echo "📦 Profile: example"
        set -gx FEDPUNK_PROFILE "example"
    else
        echo "⏭️  Skipping profile activation"
        set -gx FEDPUNK_PROFILE "none"
    end

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
end

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
run_fish_script "$FEDPUNK_INSTALL/preflight/all.fish" "Shared System Setup & Preflight"

# Desktop-specific preflight (conditional)
if not set -q FEDPUNK_SKIP_DESKTOP
    run_fish_script "$FEDPUNK_INSTALL/desktop/preflight/all.fish" "Desktop System Setup"
end

# Terminal components (always installed)
run_fish_script "$FEDPUNK_INSTALL/terminal/packaging/all.fish" "Terminal Package Installation"

# Deploy all configurations with chezmoi BEFORE running config scripts that depend on them
echo ""
info "Deploying all configurations with chezmoi"
cd "$FEDPUNK_PATH"

# Ensure chezmoi is available - add ~/.local/bin to PATH first
if not contains "$HOME/.local/bin" $PATH
    set -gx PATH "$HOME/.local/bin" $PATH
end

# Now verify chezmoi is available
if not command -v chezmoi >/dev/null 2>&1
    error "chezmoi not found. Expected at: $HOME/.local/bin/chezmoi"
    error "This should have been installed in the Fish setup phase."
    exit 1
end

# Run chezmoi apply with real-time output and timeout to prevent hanging
info "Running: chezmoi apply --force --verbose (timeout: 5 minutes)"
echo "Real-time output:"
if timeout 300 chezmoi apply --force --verbose 2>&1 | tee -a "$FEDPUNK_LOG_FILE"
    success "All configurations deployed successfully"
else
    error "Failed to deploy configurations with chezmoi (exit code: $status)"
    error "Check the output above and log file: $FEDPUNK_LOG_FILE"
    exit 1
end

# Now run terminal config scripts that may depend on deployed configs
run_fish_script "$FEDPUNK_INSTALL/terminal/config/all.fish" "Terminal Configuration Deployment"

# Desktop components (conditional)
if not set -q FEDPUNK_SKIP_DESKTOP
    run_fish_script "$FEDPUNK_INSTALL/desktop/packaging/all.fish" "Desktop Package Installation"
    run_fish_script "$FEDPUNK_INSTALL/desktop/config/all.fish" "Desktop Configuration Deployment"
else
    info "Skipping desktop components (terminal-only mode)"
    echo "[SKIPPED] Desktop installation (terminal-only mode)" >> "$FEDPUNK_LOG_FILE"
end

run_fish_script "$FEDPUNK_INSTALL/post-install/all.fish" "Post-Installation Setup"

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
