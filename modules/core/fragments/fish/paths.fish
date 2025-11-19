# PATH management
fish_add_path -g $HOME/.local/bin

# Add active config scripts to PATH if directory exists
set -l active_config "$HOME/.local/share/fedpunk/.active-config"
if test -L "$active_config"; and test -d "$active_config/scripts"
    fish_add_path -g "$active_config/scripts"
end
