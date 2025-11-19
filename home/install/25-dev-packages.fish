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

# Install podman and container tools
subsection "Installing container tools"
install_packages podman podman-compose podman-docker

echo ""
box "Development Packages Installed!" $GUM_SUCCESS
