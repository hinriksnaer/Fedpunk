#!/usr/bin/env fish
# Shared system setup: git submodules, system upgrade, core utilities, SELinux
# This runs for both terminal and desktop setups

# Source helper functions
source "$FEDPUNK_INSTALL/helpers/all.fish"

section "System Setup"

# Verify FEDPUNK_PATH exists before changing to it
if not test -d "$FEDPUNK_PATH"
    error "FEDPUNK_PATH not set or directory doesn't exist: $FEDPUNK_PATH"
    error "This script must be run from install.fish with FEDPUNK_PATH set"
    exit 1
end

cd "$FEDPUNK_PATH"

# Git submodules
info "Initializing git submodules"

# Check if any submodules use git-lfs
if git submodule foreach --quiet 'git lfs ls-files -s' 2>/dev/null | grep -q .
    step "Installing git-lfs" "sudo dnf install -qy git-lfs"
    if not git lfs install >>$FEDPUNK_LOG_FILE 2>&1
        warning "git-lfs installation failed, continuing anyway"
    end
end

# Use custom spinners for git operations
gum spin --spinner dot --title "Syncing git submodules..." -- fish -c '
    git submodule sync --recursive >>'"$FEDPUNK_LOG_FILE"' 2>&1
' && gum style --foreground $GUM_SUCCESS "✓ Syncing git submodules" || gum style --foreground $GUM_ERROR "✗ Syncing git submodules failed"

gum spin --spinner dot --title "Updating git submodules..." -- fish -c '
    git submodule update --init --recursive >>'"$FEDPUNK_LOG_FILE"' 2>&1
' && gum style --foreground $GUM_SUCCESS "✓ Updating git submodules" || gum style --foreground $GUM_ERROR "✗ Updating git submodules failed"

# System upgrade (only once!)
echo ""
info "Upgrading system packages (this may take a while)"
gum spin --spinner meter --title "Running system upgrade..." -- fish -c '
    sudo dnf upgrade --refresh -qy >>'"$FEDPUNK_LOG_FILE"' 2>&1
' && success "System packages upgraded" || warning "System upgrade completed with issues (may be already up-to-date)"

# Core system utilities
echo ""
info "Installing core system utilities"
set system_utils \
    curl \
    wget \
    which \
    dbus-devel \
    pkgconf-pkg-config \
    util-linux-user

gum spin --spinner points --title "Installing system utilities..." -- fish -c '
    sudo dnf install -qy --skip-broken '$system_utils' >>'"$FEDPUNK_LOG_FILE"' 2>&1
' && success "System utilities installed" || warning "Some system utilities may already be installed"

# SELinux configuration
echo ""
info "Checking SELinux configuration"

# Check if getenforce command exists
if command -v getenforce >/dev/null 2>&1
    set selinux_status (getenforce 2>/dev/null || echo "Disabled")
else
    set selinux_status "Not Available"
end

info "SELinux status: $selinux_status"

if test "$selinux_status" = "Enforcing"
    # Enable user executable content in home directory
    gum spin --spinner dot --title "Enabling user_exec_content..." -- fish -c '
        sudo setsebool -P user_exec_content on >>'"$FEDPUNK_LOG_FILE"' 2>&1
    ' && success "user_exec_content enabled" || warning "Failed to enable user_exec_content"

    # Fix SELinux contexts for config directories
    set home_dir (eval echo ~)

    if test -d "$home_dir/.config"
        gum spin --spinner dot --title "Restoring SELinux context for .config..." -- fish -c '
            sudo restorecon -R "'$home_dir'/.config" >>'"$FEDPUNK_LOG_FILE"' 2>&1
        ' && success "SELinux context restored for .config" || warning "Failed to restore SELinux context for .config"
    end

    if test -d "$home_dir/.local"
        gum spin --spinner dot --title "Restoring SELinux context for .local..." -- fish -c '
            sudo restorecon -R "'$home_dir'/.local" >>'"$FEDPUNK_LOG_FILE"' 2>&1
        ' && success "SELinux context restored for .local" || warning "Failed to restore SELinux context for .local"
    end

    success "SELinux configuration complete"
else
    info "SELinux not enforcing, skipping SELinux setup"
end

echo ""
box "Shared System Setup Complete!" $GUM_SUCCESS
