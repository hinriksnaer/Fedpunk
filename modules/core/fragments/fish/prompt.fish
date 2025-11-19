# Starship prompt (only load if starship is installed)
if command -v starship >/dev/null 2>&1
    starship init fish | source
end
