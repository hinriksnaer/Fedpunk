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
    run_quiet "Installing git-lfs" sudo dnf install -qy git-lfs
    if not git lfs install >>$FEDPUNK_LOG_FILE 2>&1
        warning "git-lfs installation failed, continuing anyway"
    end
end

run_quiet "Syncing git submodules" git submodule sync --recursive
run_quiet "Updating git submodules" git submodule update --init --recursive

# Enable repositories
info "Enabling package repositories"

# Get Fedora version
set fedora_version (rpm -E %fedora)
set free_url "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$fedora_version.noarch.rpm"
set nonfree_url "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$fedora_version.noarch.rpm"

run_quiet "Enabling RPM Fusion repositories" sudo dnf install -qy $free_url $nonfree_url

# System upgrade (only once!)
info "Upgrading system packages"
run_quiet "Running system upgrade" sudo dnf upgrade --refresh -qy

# Core system utilities
info "Installing core system utilities"
set system_utils \
    curl \
    wget \
    which \
    dbus-devel \
    pkgconf-pkg-config \
    util-linux-user

run_quiet "Installing system utilities" sudo dnf install -qy $system_utils

# SELinux configuration
info "Checking SELinux configuration"
set selinux_status (getenforce 2>/dev/null || echo "Disabled")
info "SELinux status: $selinux_status"

if test "$selinux_status" = "Enforcing"
    # Enable user executable content in home directory
    run_quiet "Enabling user_exec_content" sudo setsebool -P user_exec_content on
    
    # Fix SELinux contexts for config directories
    set home_dir (eval echo ~)
    
    if test -d "$home_dir/.config"
        if not sudo restorecon -R "$home_dir/.config" >>$FEDPUNK_LOG_FILE 2>&1
            warning "Failed to restore SELinux context for .config"
        end
    end
    
    if test -d "$home_dir/.local"
        if not sudo restorecon -R "$home_dir/.local" >>$FEDPUNK_LOG_FILE 2>&1
            warning "Failed to restore SELinux context for .local"
        end
    end
    
    success "SELinux contexts configured"
else
    info "SELinux not enforcing, skipping SELinux setup"
end

# Setup user directories
info "Setting up user directories"
if command -v xdg-user-dirs-update >/dev/null 2>&1
    if not xdg-user-dirs-update >>$FEDPUNK_LOG_FILE 2>&1
        warning "xdg-user-dirs-update failed"
    end
    success "User directories configured"
else
    warning "xdg-user-dirs not available, will be installed with desktop components"
end

success "System setup complete"
