#!/usr/bin/env fish
# Dev Profile - Fish Shell Configuration
# This file is sourced by ~/.config/fish/config.fish when this profile is active

# ================================
# Development Environment
# ================================

# Default editor
set -gx EDITOR nvim
set -gx VISUAL nvim

# Browser
set -gx BROWSER firefox

# ================================
# Git Aliases
# ================================

# Status and info
alias gs='git status'
alias gl='git log --oneline --graph --decorate --all'
alias gd='git diff'
alias gds='git diff --staged'

# Basic operations
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit'
alias gcm='git commit -m'
alias gca='git commit --amend'

# Push/Pull
alias gp='git push'
alias gpl='git pull'
alias gf='git fetch'

# Branch operations
alias gb='git branch'
alias gba='git branch -a'
alias gco='git checkout'
alias gcb='git checkout -b'

# Advanced
alias gst='git stash'
alias gstp='git stash pop'
alias grh='git reset --hard'
alias grs='git reset --soft HEAD~1'

# ================================
# Development Shortcuts
# ================================

# Container management
alias dc='docker'
alias dcp='docker ps'
alias dci='docker images'
alias dcr='docker run'
alias dce='docker exec -it'

# Podman (Docker-compatible)
alias pc='podman'
alias pcp='podman ps'
alias pci='podman images'
alias pcr='podman run'
alias pce='podman exec -it'

# Quick navigation to common directories
alias dev='cd ~/Development'
alias dots='cd ~/.local/share/fedpunk'
alias proj='cd ~/Projects'

# ================================
# Development Tools
# ================================

# Neovim shortcuts
alias v='nvim'
alias vi='nvim'
alias vim='nvim'

# Quick file navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Better ls with eza (if available)
if command -v eza >/dev/null
    alias ls='eza --icons --group-directories-first'
    alias ll='eza -l --icons --group-directories-first'
    alias la='eza -la --icons --group-directories-first'
    alias lt='eza --tree --icons --group-directories-first'
end

# ================================
# Language-Specific Settings
# ================================

# Rust
if test -d "$HOME/.cargo/bin"
    fish_add_path -g "$HOME/.cargo/bin"
end

# Go
if test -d "$HOME/go/bin"
    set -gx GOPATH "$HOME/go"
    fish_add_path -g "$GOPATH/bin"
end

# Node.js (nvm/fnm)
if test -d "$HOME/.local/share/fnm"
    fish_add_path -g "$HOME/.local/share/fnm"
end

# Python
if test -d "$HOME/.local/bin"
    # Already in PATH from base config, but ensure Python user packages work
    set -gx PYTHONUSERBASE "$HOME/.local"
end

# ================================
# Custom Functions
# ================================

# Quick project creation
function mkproj
    set proj_name $argv[1]
    if test -z "$proj_name"
        echo "Usage: mkproj <project-name>"
        return 1
    end
    mkdir -p ~/Projects/$proj_name
    cd ~/Projects/$proj_name
    git init
    echo "# $proj_name" > README.md
    echo "Created project: $proj_name"
end

# Quick git commit and push
function gcp
    if test (count $argv) -eq 0
        echo "Usage: gcp <commit message>"
        return 1
    end
    git add .
    git commit -m "$argv"
    git push
end

# Start development container
function devcon
    if test -f .devcontainer/devcontainer.json
        devcontainer up --workspace-folder .
    else
        echo "No .devcontainer/devcontainer.json found"
        return 1
    end
end

# ================================
# Profile Information
# ================================

# Optional: Display profile info on shell start
# Uncomment if you want to see which profile is active
# echo "🚀 Dev profile active"
