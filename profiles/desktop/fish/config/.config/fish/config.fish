# Environment variables
fish_add_path -g $HOME/.local/bin
fish_add_path -g $HOME/go/bin
# Note: Rust/Cargo PATH is managed in conf.d/installer-managed.fish
# Note: Claude Code auth is managed in active profile's claude-vertex.fish (if enabled)

# Add active config scripts to PATH if directory exists
set -l active_config "$HOME/.local/share/fedpunk/.active-config"
if test -L "$active_config"; and test -d "$active_config/scripts"
    fish_add_path -g "$active_config/scripts"
end

# History
set -g fish_history_size 10000

# Vi mode
fish_vi_key_bindings

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

# Starship prompt (only load if starship is installed)
if command -v starship >/dev/null 2>&1
    starship init fish | source
end

# Note: NVIDIA Wayland env vars are managed in conf.d/installer-managed.fish

# Default terminal for GUI applications
set -gx TERMINAL kitty

# SSH Agent
# Only set up if not already configured (e.g., from systemd, forwarded agent, etc.)
if test -z "$SSH_AUTH_SOCK"
    # Try to find existing agent socket
    set -l agent_sockets (find /tmp -type s -name "agent.*" -user $USER 2>/dev/null)

    if test (count $agent_sockets) -gt 0
        # Use first available agent socket
        set -gx SSH_AUTH_SOCK $agent_sockets[1]
        set -gx SSH_AGENT_PID (pgrep -u $USER ssh-agent | head -1)
    else
        # No existing agent, start a new one
        eval (ssh-agent -c) > /dev/null
        set -gx SSH_AGENT_PID (pgrep -u $USER ssh-agent)
    end
end

# Source virtual environment if it exists
if test -f ~/.venv/bin/activate.fish
    source ~/.venv/bin/activate.fish
end

# Source active config's Fish configuration if it exists
set -l active_config "$HOME/.local/share/fedpunk/.active-config"
if test -L "$active_config"; and test -f "$active_config/config.fish"
    source "$active_config/config.fish"
end


