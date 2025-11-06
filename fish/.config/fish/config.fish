# Environment variables
set -gx PATH $HOME/.local/bin $PATH
set -gx PATH $HOME/.cargo/bin $PATH
set -gx CLAUDE_CODE_USE_VERTEX 1
set -gx CLOUD_ML_REGION us-east5
set -gx ANTHROPIC_VERTEX_PROJECT_ID itpc-gcp-ai-eng-claude

# Add to PYTHONPATH
if set -q PYTHONPATH
    set -gx PYTHONPATH $PYTHONPATH:/root/workspace/pytorch
else
    set -gx PYTHONPATH /root/workspace/pytorch
end

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

# Activate virtual environment
source $HOME/.venv/bin/activate.fish
