# Dev Profile - Fish Configuration
# Personal development environment customizations

# ============================================================================
# Git Shortcuts
# ============================================================================
alias gs='git status -sb'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline --graph --decorate'
alias gd='git diff'
alias gco='git checkout'
alias gb='git branch'

# ============================================================================
# Development Shortcuts
# ============================================================================
alias dev='cd ~/Development'
alias dots='cd ~/.local/share/fedpunk'
alias ..='cd ..'
alias ...='cd ../..'

# ============================================================================
# Better Defaults
# ============================================================================
alias rm='rm -i'      # Confirm before deleting
alias cp='cp -i'      # Confirm before overwriting
alias mv='mv -i'      # Confirm before overwriting

# ============================================================================
# Editor
# ============================================================================
set -gx EDITOR nvim
set -gx VISUAL nvim

# ============================================================================
# Development Paths
# ============================================================================
# Add cargo bin if it exists
if test -d ~/.cargo/bin
    set -gx PATH ~/.cargo/bin $PATH
end

# Add local bin
if test -d ~/bin
    set -gx PATH ~/bin $PATH
end

# ============================================================================
# Environment Variables
# ============================================================================
# Customize as needed
# set -gx BROWSER firefox
# set -gx PAGER less
