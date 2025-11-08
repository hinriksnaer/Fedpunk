#!/usr/bin/env fish
# Preflight checks and prerequisites

# Source helper functions
source "$FEDPUNK_INSTALL/helpers/all.fish"

section "Prerequisites"

info "Setting up system prerequisites"
fish "$FEDPUNK_INSTALL/preflight/init.fish"

info "Checking SELinux configuration"
fish "$FEDPUNK_INSTALL/preflight/selinux-check.fish"

success "Prerequisites complete"
