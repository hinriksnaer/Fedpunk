# lsd aliases (only set if lsd is installed)
if command -v lsd >/dev/null 2>&1
    alias ls='lsd'
    alias l='ls -l'
    alias la='ls -a'
    alias lla='ls -la'
    alias lt='ls --tree'
end
