# Environment variables
set -gx PATH $HOME/.local/bin $PATH
set -gx PATH $HOME/.cargo/bin $PATH

# History
set -g fish_history_size 10000

# Vi mode
fish_vi_key_bindings

# lsd aliases
alias ls='lsd'
alias l='ls -l'
alias la='ls -a'
alias lla='ls -la'
alias lt='ls --tree'

# fzf integration
fzf --fish | source

# Starship prompt
starship init fish | source

# Activate virtual environment (optional)
# source $HOME/.venv/bin/activate.fish
