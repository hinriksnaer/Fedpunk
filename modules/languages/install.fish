#!/usr/bin/env fish
# ============================================================================
# LANGUAGES MODULE: Install programming language toolchains
# ============================================================================

source "$FEDPUNK_LIB_PATH/helpers.fish"

subsection "Installing language toolchains"

set packages

# Get module parameters
set -q FEDPUNK_MODULE_LANGUAGES_INSTALL_NODEJS; or set FEDPUNK_MODULE_LANGUAGES_INSTALL_NODEJS "true"
set -q FEDPUNK_MODULE_LANGUAGES_INSTALL_PYTHON; or set FEDPUNK_MODULE_LANGUAGES_INSTALL_PYTHON "true"
set -q FEDPUNK_MODULE_LANGUAGES_INSTALL_GO; or set FEDPUNK_MODULE_LANGUAGES_INSTALL_GO "true"

if test "$FEDPUNK_MODULE_LANGUAGES_INSTALL_NODEJS" = "true"
    set packages $packages "nodejs"
end

if test "$FEDPUNK_MODULE_LANGUAGES_INSTALL_PYTHON" = "true"
    set packages $packages "python3" "python3-pip"
end

if test "$FEDPUNK_MODULE_LANGUAGES_INSTALL_GO" = "true"
    set packages $packages "golang"
end

if test (count $packages) -gt 0
    install_packages $packages
else
    info "No languages selected for installation"
end

success "Language toolchains installed"
