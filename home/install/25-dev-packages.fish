#!/usr/bin/env fish
# ============================================================================
# DEV PACKAGES: Install development-specific packages
# ============================================================================
# Purpose:
#   - Install podman and container tools for development
# Runs: Before apply (development profile only)
# ============================================================================

source "$FEDPUNK_PATH/lib/helpers.fish"

section "Development Packages"

# Install podman and container tools (skip when already in a container)
if test "$FEDPUNK_MODE" = "container"
    info "Skipping container tools (already running in container)"
else
    subsection "Installing container tools"
    install_packages podman podman-compose podman-docker
end

echo ""
box "Development Packages Installed!" $GUM_SUCCESS
