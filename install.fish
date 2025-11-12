#!/usr/bin/env fish

# Exit immediately if a command exits with a non-zero status
set -e

# Parse command-line flags
set terminal_only false
set non_interactive false

for arg in $argv
    switch $arg
        case --terminal-only
            set terminal_only true
        case --non-interactive
            set non_interactive true
    end
end

# Define Fedpunk locations - always derive from script location
set script_dir (dirname (status -f))
set -x FEDPUNK_PATH (realpath "$script_dir")
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

    if source "$script_name"
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
run_fish_script "$FEDPUNK_INSTALL/terminal/config/all.fish" "Terminal Configuration Deployment"

# Desktop components (conditional)
if not set -q FEDPUNK_SKIP_DESKTOP
    run_fish_script "$FEDPUNK_INSTALL/desktop/packaging/all.fish" "Desktop Package Installation"
    run_fish_script "$FEDPUNK_INSTALL/desktop/config/all.fish" "Desktop Configuration Deployment"
else
    info "Skipping desktop components (terminal-only mode)"
    echo "[SKIPPED] Desktop installation (terminal-only mode)" >> "$FEDPUNK_LOG_FILE"
end

# Link bin directory
echo ""
info "Linking bin scripts"
cd "$FEDPUNK_PATH"
if mkdir -p $HOME/.local/bin >> "$FEDPUNK_LOG_FILE" 2>&1
    success "Created bin directory"
else
    error "Failed to create bin directory"
end

if stow --restow -d $FEDPUNK_PATH -t $HOME/.local bin >> "$FEDPUNK_LOG_FILE" 2>&1
    success "Linked bin scripts"
else
    error "Failed to link bin scripts"
end

run_fish_script "$FEDPUNK_INSTALL/post-install/all.fish" "Post-Installation Setup"

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
