#!/usr/bin/env fish
# System-level setup: repositories, updates, submodules, SELinux
# Run this after bootstrap-fish.sh and before package installation

# Source helper functions
source "$FEDPUNK_INSTALL/helpers/all.fish"

section "System Setup"
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

# Enable repositories
echo ""
info "Enabling package repositories"

# Get Fedora version
set fedora_version (rpm -E %fedora)
set free_url "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$fedora_version.noarch.rpm"
set nonfree_url "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$fedora_version.noarch.rpm"

# Use line spinner for network download operations
gum spin --spinner line --title "Enabling RPM Fusion repositories..." -- fish -c '
    sudo dnf install -qy --skip-broken '$free_url' '$nonfree_url' >>'"$FEDPUNK_LOG_FILE"' 2>&1
' && success "RPM Fusion repositories enabled" || warning "RPM Fusion repositories may already be enabled"

# System upgrade (only once!)
echo ""
info "Upgrading system packages (this may take a while)"
gum spin --spinner meter --title "Running system upgrade..." -- fish -c '
    sudo dnf upgrade --refresh -qy --skip-broken >>'"$FEDPUNK_LOG_FILE"' 2>&1
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
set selinux_status (getenforce 2>/dev/null || echo "Disabled")
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

# Setup user directories
echo ""
info "Setting up user directories"
if command -v xdg-user-dirs-update >/dev/null 2>&1
    gum spin --spinner dot --title "Configuring user directories..." -- fish -c '
        xdg-user-dirs-update >>'"$FEDPUNK_LOG_FILE"' 2>&1
    ' && success "User directories configured" || warning "xdg-user-dirs-update failed"
else
    warning "xdg-user-dirs not available, will be installed with desktop components"
end

echo ""
box "System Setup Complete!" $GUM_SUCCESS
