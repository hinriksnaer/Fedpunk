# Fedpunk Fish Configuration

# ============================================================================
# PATH Management
# ============================================================================
fish_add_path -g $HOME/.local/bin

# Add fedpunk scripts to PATH
set -l fedpunk_scripts "$HOME/.local/share/fedpunk/scripts"
if test -d "$fedpunk_scripts"
    fish_add_path -g "$fedpunk_scripts"
end

# ============================================================================
# Environment Variables
# ============================================================================
# Default editor
set -gx EDITOR nvim
set -gx VISUAL nvim

# Browser
set -gx BROWSER firefox

# Default terminal for GUI applications
if command -v kitty >/dev/null 2>&1
    set -gx TERMINAL kitty
end

# ============================================================================
# Shell Configuration
# ============================================================================
# History
set -g fish_history_size 10000

# Vi mode
fish_vi_key_bindings

# ============================================================================
# Prompt
# ============================================================================
# Starship prompt (only load if starship is installed)
if command -v starship >/dev/null 2>&1
    starship init fish | source
end

# ============================================================================
# SSH Agent
# ============================================================================
if test -z "$SSH_AUTH_SOCK"
    eval (ssh-agent -c) > /dev/null
    set -gx SSH_AGENT_PID (pgrep -u $USER ssh-agent)
end

# ============================================================================
# Git Aliases
# ============================================================================
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

# ============================================================================
# Development Shortcuts
# ============================================================================
# Password manager - Bitwarden
if command -v bw >/dev/null
    alias bwl='bw list items'
    alias bwgen='bw generate'
end

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

# Quick navigation
alias dev='cd ~/Development'
alias dots='cd ~/.local/share/fedpunk'
alias proj='cd ~/Projects'

# Neovim shortcuts
alias v='nvim'
alias vi='nvim'
alias vim='nvim'

# Quick file navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# ============================================================================
# Tool Integrations
# ============================================================================
# Better ls with eza or lsd (prefer eza)
if command -v eza >/dev/null
    alias ls='eza --icons --group-directories-first'
    alias ll='eza -l --icons --group-directories-first'
    alias la='eza -la --icons --group-directories-first'
    alias lt='eza --tree --icons --group-directories-first'
else if command -v lsd >/dev/null 2>&1
    alias ls='lsd'
    alias l='ls -l'
    alias la='ls -a'
    alias lla='ls -la'
    alias lt='ls --tree'
end

# fzf integration (only load if fzf is installed)
if command -v fzf >/dev/null 2>&1
    fzf --fish | source
end

# ============================================================================
# Language-Specific Settings
# ============================================================================
# Rust
if test -d "$HOME/.cargo/bin"
    fish_add_path -g "$HOME/.cargo/bin"
end

# Go
if test -d "$HOME/go/bin"
    set -gx GOPATH "$HOME/go"
    fish_add_path -g "$GOPATH/bin"
end

# Node.js (fnm)
if test -d "$HOME/.local/share/fnm"
    fish_add_path -g "$HOME/.local/share/fnm"
end

# Python
if test -d "$HOME/.local/bin"
    set -gx PYTHONUSERBASE "$HOME/.local"
end

# ============================================================================
# Custom Functions
# ============================================================================
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

# ============================================================================
# Bitwarden Integration
# ============================================================================
# Check Bitwarden status in background (non-blocking)
if status is-interactive; and command -v bw >/dev/null 2>&1
    fish -c '
        set bw_status (bw status 2>/dev/null | grep -o "\"status\":\"[^\"]*\"" | cut -d"\"" -f4)
        if test "$bw_status" = "locked"
            echo "🔒 Bitwarden vault is locked. Run '\''bw unlock'\'' to unlock." >&2
        else if test "$bw_status" = "unauthenticated"
            echo "🔒 Bitwarden not logged in. Run '\''bw login'\'' to login." >&2
        end
    ' &
    disown
end

# ============================================================================
# SSH Agent Persistence
# ============================================================================
if status is-interactive
    # Check if SSH agent is running
    if not set -q SSH_AGENT_PID; or not ps -p $SSH_AGENT_PID >/dev/null 2>&1
        set -l ssh_env ~/.ssh/agent.env

        if test -f $ssh_env
            source $ssh_env >/dev/null
        end

        # Verify agent is actually running
        if not ps -p $SSH_AGENT_PID >/dev/null 2>&1
            eval (ssh-agent -c) >/dev/null
            echo "set -gx SSH_AUTH_SOCK $SSH_AUTH_SOCK;" > $ssh_env
            echo "set -gx SSH_AGENT_PID $SSH_AGENT_PID;" >> $ssh_env
        end
    end
end

# ============================================================================
# Virtual Environment
# ============================================================================
# Source virtual environment if it exists
if test -f ~/.venv/bin/activate.fish
    source ~/.venv/bin/activate.fish
end
