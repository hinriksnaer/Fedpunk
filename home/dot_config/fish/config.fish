# Fedpunk Fish Configuration

# ============================================================================
# PATH Management
# ============================================================================
fish_add_path -g $HOME/.local/bin

# Add active profile scripts to PATH if directory exists
set -l active_config "$HOME/.local/share/fedpunk/.active-config"
if test -L "$active_config"; and test -d "$active_config/scripts"
    fish_add_path -g "$active_config/scripts"
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
# Tool Integrations
# ============================================================================
# lsd aliases (only set if lsd is installed)
if command -v lsd >/dev/null 2>&1
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

# Default terminal for GUI applications
if command -v kitty >/dev/null 2>&1
    set -gx TERMINAL kitty
end

# ============================================================================
# Profile System Integration
# ============================================================================
# Source virtual environment if it exists
if test -f ~/.venv/bin/activate.fish
    source ~/.venv/bin/activate.fish
end

# Source active profile's Fish configuration if it exists
if test -L "$active_config"; and test -f "$active_config/config.fish"
    source "$active_config/config.fish"
end
