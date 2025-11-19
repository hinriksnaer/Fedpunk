#!/usr/bin/env fish
# ============================================================================
# TMUX MODULE: Install tmux
# ============================================================================

source "$FEDPUNK_LIB_PATH/helpers.fish"

subsection "Installing tmux"

install_if_missing tmux tmux

success "tmux installed"
