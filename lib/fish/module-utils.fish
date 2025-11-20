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

function module-has-toml
    set -l module_name $argv[1]
    test -f (module-get-modules-dir)/$module_name/module.toml
end

function module-get-toml-value
    # Parse TOML value using simple grep/sed
    # Usage: module-get-toml-value <module> <section> <key>
    set -l module_name $argv[1]
    set -l section $argv[2]
    set -l key $argv[3]
    set -l toml_file (module-get-modules-dir)/$module_name/module.toml

    if not test -f $toml_file
        return 1
    end

    # Extract value from TOML (simple implementation)
    # This is a basic parser - for production, consider using dasel or yj
    awk -v section="$section" -v key="$key" '
        /^\[.*\]/ {
            current_section = $0
            gsub(/[\[\]]/, "", current_section)
        }
        current_section == section && $1 == key {
            gsub(/^[^=]*= */, "")
            gsub(/^"/, "")
            gsub(/"$/, "")
            print
        }
    ' $toml_file
end

function module-get-toml-array
    # Get array values from TOML
    # Usage: module-get-toml-array <module> <section> <key>
    set -l module_name $argv[1]
    set -l section $argv[2]
    set -l key $argv[3]
    set -l toml_file (module-get-modules-dir)/$module_name/module.toml

    if not test -f $toml_file
        return 1
    end

    # Extract array from TOML
    awk -v section="$section" -v key="$key" '
        /^\[.*\]/ {
            current_section = $0
            gsub(/[\[\]]/, "", current_section)
        }
        current_section == section && $1 == key {
            gsub(/^[^=]*= *\[/, "")
            gsub(/\].*$/, "")
            gsub(/"/, "")
            gsub(/, */, "\n")
            print
        }
    ' $toml_file
end

function module-get-dependencies
    # Get module dependencies
    set -l module_name $argv[1]
    module-get-toml-array $module_name "module" "dependencies"
end

function module-get-priority
    # Get module priority (default: 50)
    set -l module_name $argv[1]
    set -l priority (module-get-toml-value $module_name "module" "priority")
    if test -z "$priority"
        echo 50
    else
        echo $priority
    end
end

function module-has-lifecycle
    # Check if module has a lifecycle hook
    # Usage: module-has-lifecycle <module> <hook>
    set -l module_name $argv[1]
    set -l hook $argv[2]
    set -l value (module-get-toml-value $module_name "lifecycle" $hook)
    test "$value" = "true"
end

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

function module-is-enabled
    # Check if module is enabled in current profile
    set -l module_name $argv[1]
    set -l profile_dir (module-get-root)/.active-config

    if not test -L $profile_dir
        # No active profile, assume enabled
        return 0
    end

    set -l modules_toml (readlink -f $profile_dir)/modules.toml
    if not test -f $modules_toml
        # No modules.toml, assume enabled
        return 0
    end

    set -l enabled (module-get-toml-value-file $modules_toml "modules" $module_name)
    test "$enabled" = "true"
end

function module-get-toml-value-file
    # Parse TOML value from specific file
    # Usage: module-get-toml-value-file <file> <section> <key>
    set -l toml_file $argv[1]
    set -l section $argv[2]
    set -l key $argv[3]

    if not test -f $toml_file
        return 1
    end

    awk -v section="$section" -v key="$key" '
        /^\[.*\]/ {
            current_section = $0
            gsub(/[\[\]]/, "", current_section)
        }
        current_section == section && $1 == key {
            gsub(/^[^=]*= */, "")
            gsub(/^"/, "")
            gsub(/"$/, "")
            print
        }
    ' $toml_file
end

function module-list-enabled
    # List enabled modules in current profile
    for module in (module-list-all)
        if module-is-enabled $module
            echo $module
        end
    end
end

function module-resolve-dependencies
    # Topologically sort modules by dependencies
    # Returns modules in execution order
    set -l modules $argv

    # Simple implementation: repeatedly output modules with satisfied deps
    set -l result
    set -l remaining $modules
    set -l max_iterations (count $modules)
    set -l iteration 0

    while test (count $remaining) -gt 0 -a $iteration -lt $max_iterations
        set iteration (math $iteration + 1)
        set -l added_this_round

        for module in $remaining
            set -l deps (module-get-dependencies $module)
            set -l all_satisfied true

            for dep in $deps
                if not contains $dep $result
                    set all_satisfied false
                    break
                end
            end

            if test "$all_satisfied" = "true"
                set -a result $module
                set -a added_this_round $module
            end
        end

        # Remove added modules from remaining
        for module in $added_this_round
            set -l idx (contains -i $module $remaining)
            set -e remaining[$idx]
        end

        # Check if we made progress
        if test (count $added_this_round) -eq 0
            echo "Error: Circular dependency detected in modules: $remaining" >&2
            return 1
        end
    end

    # Sort by priority within dependency levels
    # For now, just output in dependency order
    for module in $result
        echo $module
    end
end

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
