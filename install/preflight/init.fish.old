#!/usr/bin/env fish
# Initialize system prerequisites and submodules

# Source helper functions
source "$FEDPUNK_INSTALL/helpers/all.fish"

cd "$FEDPUNK_PATH"

# Check if git-lfs is needed for submodules
if git submodule status | grep -q "lfs"
    run_quiet "Installing git-lfs" sudo dnf install -qy git-lfs
    git lfs install >>$FEDPUNK_LOG_FILE 2>&1
end

run_quiet "Syncing git submodules" git submodule sync --recursive
run_quiet "Updating git submodules" git submodule update --init --recursive

# Essential packages
set packages \
    stow \
    nodejs \
    npm \
    curl \
    wget \
    which \
    dbus-devel \
    pkgconf-pkg-config

# Enable RPM Fusion repositories for additional packages
run_quiet "Enabling RPM Fusion repositories" sh -c "sudo dnf install -qy \
    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-\$(rpm -E %fedora).noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-\$(rpm -E %fedora).noarch.rpm"

run_quiet "Upgrading system packages" sudo dnf upgrade --refresh -qy
run_quiet "Installing essential packages" sudo dnf install -qy $packages

# Verify Node.js version is compatible (>= 16)
set node_version (node --version | sed 's/v//' | cut -d. -f1)
if test $node_version -lt 16
    warning "Node.js version $node_version detected. Some components may require Node.js 16+."
end
