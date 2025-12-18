#!/usr/bin/env fish
# Module utility functions for fedpunk module system

function module-get-root
    # Get fedpunk root directory
    if test -n "$FEDPUNK_ROOT"
        echo $FEDPUNK_ROOT
    else if test -L ~/.local/share/fedpunk
        readlink -f ~/.local/share/fedpunk
    else
        echo ~/.local/share/fedpunk
    end
end

function module-get-modules-dir
    echo (module-get-root)/modules
end

function module-exists
    set -l module_name $argv[1]
    test -d (module-get-modules-dir)/$module_name
end

# TOML functions removed - all modules now use YAML (module.yaml)

function module-has-script
    # Check if module has a lifecycle script file
    set -l module_name $argv[1]
    set -l hook $argv[2]
    test -f (module-get-modules-dir)/$module_name/scripts/$hook
end

function module-list-all
    # List all available modules
    set -l modules_dir (module-get-modules-dir)
    if test -d $modules_dir
        for module in $modules_dir/*
            if test -d $module
                basename $module
            end
        end
    end
end

# module-is-enabled removed - managed by deployer.fish now via YAML config

# module-list-enabled removed - managed by deployer.fish now via YAML config

# module-resolve-dependencies removed - handled by fedpunk-module.fish now via YAML

function module-run-script
    # Run a module lifecycle script
    # Usage: module-run-script <module> <hook>
    set -l module_name $argv[1]
    set -l hook $argv[2]
    set -l script (module-get-modules-dir)/$module_name/scripts/$hook

    if not test -f $script
        return 0
    end

    if not test -x $script
        chmod +x $script
    end

    # Set up environment
    set -lx MODULE_NAME $module_name
    set -lx MODULE_DIR (module-get-modules-dir)/$module_name
    set -lx FEDPUNK_ROOT (module-get-root)
    set -lx STOW_TARGET $HOME

    if test -L (module-get-root)/.active-config
        set -lx PROFILE (basename (readlink -f (module-get-root)/.active-config))
    end

    # Execute script
    echo "  → Running $hook hook for $module_name..."
    $script
end

function module-stow
    # Stow a module's config
    # Usage: module-stow <module>
    set -l module_name $argv[1]
    set -l modules_dir (module-get-modules-dir)
    set -l module_dir $modules_dir/$module_name

    if not test -d $module_dir/config
        echo "  → No config directory for $module_name, skipping stow"
        return 0
    end

    echo "  → Stowing $module_name..."

    # Use stow to create symlinks
    stow -d $modules_dir/$module_name -t $HOME config 2>&1 | while read -l line
        if string match -q "*conflict*" $line
            echo "    Warning: $line"
        end
    end
end

function module-unstow
    # Remove a module's symlinks
    # Usage: module-unstow <module>
    set -l module_name $argv[1]
    set -l modules_dir (module-get-modules-dir)
    set -l module_dir $modules_dir/$module_name

    if not test -d $module_dir/config
        echo "  → No config directory for $module_name, skipping unstow"
        return 0
    end

    echo "  → Unstowing $module_name..."
    stow -D -d $modules_dir/$module_name -t $HOME config
end
