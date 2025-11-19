#!/usr/bin/env fish
# ============================================================================
# PACKAGES: Install packages based on mode configuration
# ============================================================================
# Purpose:
#   - Read .install.* flags from mode YAML
#   - Call package installation functions from lib/packages.fish
# Runs: Always (packages vary by mode)
# ============================================================================

source "$FEDPUNK_PROFILE_PATH/lib/helpers.fish"
source "$FEDPUNK_PROFILE_PATH/lib/packages.fish"

section "Package Installation (mode: $FEDPUNK_MODE)"

# Helper to conditionally run package install functions
# Usage: install_if_flag "FEDPUNK_INSTALL_TMUX" install_package_tmux
function install_if_flag
    set flag_name $argv[1]
    set func_name $argv[2]

    if set -q $flag_name; and test "$$flag_name" = "true"
        $func_name
    else
        info "Skipping $func_name (not enabled in mode)"
    end
end

# Terminal tools
echo ""
subsection "Terminal Tools"
install_if_flag FEDPUNK_INSTALL_TMUX install_package_tmux
install_if_flag FEDPUNK_INSTALL_NEOVIM install_package_neovim
install_if_flag FEDPUNK_INSTALL_YAZI install_package_yazi
install_if_flag FEDPUNK_INSTALL_BTOP install_package_btop
install_if_flag FEDPUNK_INSTALL_GH install_package_gh
install_if_flag FEDPUNK_INSTALL_CLAUDE install_package_claude
install_if_flag FEDPUNK_INSTALL_LAZYGIT install_package_lazygit
install_if_flag FEDPUNK_INSTALL_CLI_TOOLS install_package_cli_tools
install_if_flag FEDPUNK_INSTALL_LANGUAGES install_package_languages

# Desktop environment
echo ""
subsection "Desktop Environment"
install_if_flag FEDPUNK_INSTALL_KITTY install_package_kitty
install_if_flag FEDPUNK_INSTALL_HYPRLAND install_package_hyprland
install_if_flag FEDPUNK_INSTALL_ROFI install_package_rofi
install_if_flag FEDPUNK_INSTALL_FIREFOX install_package_firefox
install_if_flag FEDPUNK_INSTALL_FONTS install_package_fonts

# System components
echo ""
subsection "System Components"
install_if_flag FEDPUNK_INSTALL_AUDIO install_package_audio
install_if_flag FEDPUNK_INSTALL_MULTIMEDIA install_package_multimedia
install_if_flag FEDPUNK_INSTALL_BLUETOOTH install_package_bluetooth

# Extras
echo ""
subsection "Extra Applications"
install_if_flag FEDPUNK_INSTALL_EXTRA_APPS install_package_extra_apps

# GPU drivers (auto-detect)
echo ""
set gpu_type (detect_gpu)
if test "$gpu_type" = "nvidia"
    info "NVIDIA GPU detected"
    if confirm "Install NVIDIA proprietary drivers?" "yes"
        install_nvidia
    else
        info "Skipping NVIDIA drivers"
    end
else
    info "No NVIDIA GPU detected (type: $gpu_type)"
end

echo ""
box "Package Installation Complete!" $GUM_SUCCESS
