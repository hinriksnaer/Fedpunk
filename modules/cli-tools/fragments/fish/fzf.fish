# fzf integration (only load if fzf is installed)
if command -v fzf >/dev/null 2>&1
    fzf --fish | source
end
