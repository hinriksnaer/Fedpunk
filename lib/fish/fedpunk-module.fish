#!/usr/bin/env fish
# Fedpunk module management command
# Usage: fedpunk module <subcommand> [args]

# Source dependencies
set -l script_dir (dirname (status -f))
source "$script_dir/yaml-parser.fish"

# Global variable to track deployed modules (prevents redeployment in same session)
if not set -q FEDPUNK_DEPLOYED_MODULES
    set -g FEDPUNK_DEPLOYED_MODULES
end

# Resolve and deploy dependencies recursively
function fedpunk-module-resolve-dependencies
    set -l module_name $argv[1]
    set -l module_dir "$FEDPUNK_ROOT/modules/$module_name"
    set -l module_yaml "$module_dir/module.yaml"

    if not test -f "$module_yaml"
        echo "Module not found: $module_name" >&2
        return 1
    end

    # Get dependencies
    set -l dependencies (yaml-get-list "$module_yaml" "module" "dependencies")

    if test -z "$dependencies"
        return 0  # No dependencies
    end

    # Deploy each dependency if not already deployed
    for dep in $dependencies
        # Check if already deployed in this session
        if contains $dep $FEDPUNK_DEPLOYED_MODULES
            echo "  Dependency $dep already deployed, skipping"
            continue
        end

        echo "  Resolving dependency: $dep (required by $module_name)"

        # Recursively deploy dependency (which will resolve its dependencies)
        fedpunk-module-deploy $dep
        or begin
            echo "Failed to deploy dependency: $dep" >&2
            return 1
        end
    end

    return 0
end

function fedpunk-module
    set -l subcommand $argv[1]

    # Set FEDPUNK_ROOT if not set
    if not set -q FEDPUNK_ROOT
        if test -L ~/.local/share/fedpunk
            set -gx FEDPUNK_ROOT (readlink -f ~/.local/share/fedpunk)
        else if test -d ~/.local/share/fedpunk
            set -gx FEDPUNK_ROOT ~/.local/share/fedpunk
        else
            echo "Error: FEDPUNK_ROOT not found" >&2
            return 1
        end
    end

    switch "$subcommand"
        case list
            fedpunk-module-list $argv[2..]
        case info
            fedpunk-module-info $argv[2..]
        case install-packages
            fedpunk-module-install-packages $argv[2..]
        case stow
            fedpunk-module-stow $argv[2..]
        case unstow
            fedpunk-module-unstow $argv[2..]
        case deploy
            fedpunk-module-deploy $argv[2..]
        case run-lifecycle
            fedpunk-module-run-lifecycle $argv[2..]
        case '*'
            echo "Usage: fedpunk module <subcommand> [args]"
            echo ""
            echo "Subcommands:"
            echo "  list                    List all available modules"
            echo "  info <module>           Show module information"
            echo "  install-packages <mod>  Install system packages for module"
            echo "  stow <module>           Deploy module config with stow"
            echo "  unstow <module>         Remove module config symlinks"
            echo "  deploy <module>         Full deployment (packages + lifecycle + stow)"
            echo "  run-lifecycle <mod> <hook>  Run a specific lifecycle hook"
            return 1
    end
end

function fedpunk-module-list
    set -l modules_dir "$FEDPUNK_ROOT/modules"

    if not test -d "$modules_dir"
        echo "No modules directory found at $modules_dir" >&2
        return 1
    end

    echo "Available modules:"
    for module_dir in $modules_dir/*
        if test -d "$module_dir"
            set -l module_name (basename "$module_dir")
            set -l module_yaml "$module_dir/module.yaml"

            if test -f "$module_yaml"
                set -l description (yaml-get-value "$module_yaml" "module" "description")
                if test -n "$description"
                    echo "  $module_name - $description"
                else
                    echo "  $module_name"
                end
            else
                echo "  $module_name (no module.yaml)"
            end
        end
    end
end

function fedpunk-module-info
    set -l module_name $argv[1]

    if test -z "$module_name"
        echo "Usage: fedpunk module info <module>" >&2
        return 1
    end

    set -l module_dir "$FEDPUNK_ROOT/modules/$module_name"
    set -l module_yaml "$module_dir/module.yaml"

    if not test -f "$module_yaml"
        echo "Module not found: $module_name" >&2
        return 1
    end

    echo "Module: $module_name"
    echo "Description: "(yaml-get-value "$module_yaml" "module" "description")
    echo "Priority: "(yaml-get-value "$module_yaml" "module" "priority")

    set -l deps (yaml-get-list "$module_yaml" "module" "dependencies")
    if test -n "$deps"
        echo "Dependencies: $deps"
    else
        echo "Dependencies: none"
    end

    echo ""
    echo "Lifecycle hooks:"
    for hook in install update before after
        set -l scripts (yaml-get-list "$module_yaml" "lifecycle" "$hook")
        if test -n "$scripts"
            echo "  $hook: $scripts"
        end
    end

    echo ""
    echo "Packages:"
    for pkg_mgr in copr dnf cargo npm flatpak
        set -l packages (yaml-get-list "$module_yaml" "packages" "$pkg_mgr")
        if test -n "$packages"
            echo "  $pkg_mgr: $packages"
        end
    end
end

function fedpunk-module-install-packages
    set -l module_name $argv[1]

    if test -z "$module_name"
        echo "Usage: fedpunk module install-packages <module>" >&2
        return 1
    end

    set -l module_dir "$FEDPUNK_ROOT/modules/$module_name"
    set -l module_yaml "$module_dir/module.yaml"

    if not test -f "$module_yaml"
        echo "Module not found: $module_name" >&2
        return 1
    end

    echo "Installing packages for module: $module_name"

    # Install in order: copr -> dnf -> cargo -> npm -> flatpak

    # COPR repos
    set -l copr_repos (yaml-get-list "$module_yaml" "packages" "copr")
    for repo in $copr_repos
        echo "  Enabling COPR repo: $repo"
        sudo dnf copr enable -y $repo
    end

    # DNF packages
    set -l dnf_packages (yaml-get-list "$module_yaml" "packages" "dnf")
    if test -n "$dnf_packages"
        echo "  Installing DNF packages: $dnf_packages"
        sudo dnf install -y $dnf_packages
    end

    # Cargo packages
    set -l cargo_packages (yaml-get-list "$module_yaml" "packages" "cargo")
    for pkg in $cargo_packages
        echo "  Installing cargo package: $pkg"

        # Ensure cargo is in PATH (in case it was just installed)
        if not command -v cargo >/dev/null 2>&1
            if test -f "$HOME/.cargo/bin/cargo"
                set -gx PATH "$HOME/.cargo/bin" $PATH
            else
                echo "Error: cargo not found. Please ensure rust module is installed first." >&2
                continue
            end
        end

        cargo install $pkg
    end

    # NPM packages
    set -l npm_packages (yaml-get-list "$module_yaml" "packages" "npm")
    for pkg in $npm_packages
        echo "  Installing npm package: $pkg"
        sudo npm install -g $pkg
    end

    # Flatpak packages
    set -l flatpak_packages (yaml-get-list "$module_yaml" "packages" "flatpak")
    if test -n "$flatpak_packages"
        # Ensure flatpak is installed
        if not command -v flatpak >/dev/null 2>&1
            echo "  Installing flatpak..."
            sudo dnf install -y flatpak
        end

        # Ensure Flathub repository is added
        if not flatpak remotes | grep -q flathub
            echo "  Adding Flathub repository..."
            flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
        end

        # Install flatpak packages
        for pkg in $flatpak_packages
            echo "  Installing flatpak: $pkg"
            flatpak install -y flathub $pkg
        end
    end

    echo "Package installation complete for $module_name"
end

function fedpunk-module-stow
    set -l module_name $argv[1]

    if test -z "$module_name"
        echo "Usage: fedpunk module stow <module>" >&2
        return 1
    end

    set -l module_dir "$FEDPUNK_ROOT/modules/$module_name"

    if not test -d "$module_dir"
        echo "Module not found: $module_name" >&2
        return 1
    end

    if not test -d "$module_dir/config"
        echo "No config directory for module: $module_name" >&2
        return 0
    end

    echo "Stowing module: $module_name"
    cd "$module_dir"

    # First attempt: try stow with --restow (idempotent if already stowed)
    set -l stow_output (stow --restow -t $HOME config 2>&1)
    set -l stow_status $status

    if test $stow_status -eq 0
        return 0
    end

    # Check if failure was due to conflicts with existing files
    if string match -q "*existing target*" -- $stow_output; or string match -q "*cannot stow*" -- $stow_output
        echo "Existing configuration detected. Using --adopt to preserve existing files..."

        # Use --adopt to take ownership of existing files
        # This will update the stowed files to match what's in $HOME
        stow --adopt -t $HOME config
        set -l adopt_status $status

        if test $adopt_status -eq 0
            echo "Successfully adopted existing configuration"
            return 0
        else
            echo "Failed to adopt existing configuration" >&2
            echo $stow_output >&2
            return 1
        end
    else
        # Other stow error
        echo $stow_output >&2
        return 1
    end
end

function fedpunk-module-unstow
    set -l module_name $argv[1]

    if test -z "$module_name"
        echo "Usage: fedpunk module unstow <module>" >&2
        return 1
    end

    set -l module_dir "$FEDPUNK_ROOT/modules/$module_name"

    if not test -d "$module_dir"
        echo "Module not found: $module_name" >&2
        return 1
    end

    if not test -d "$module_dir/config"
        echo "No config directory for module: $module_name"
        return 0
    end

    echo "Unstowing module: $module_name"
    cd "$module_dir"
    stow -D -t $HOME config
end

function fedpunk-module-run-lifecycle
    set -l module_name $argv[1]
    set -l hook $argv[2]

    if test -z "$module_name" -o -z "$hook"
        echo "Usage: fedpunk module run-lifecycle <module> <hook>" >&2
        return 1
    end

    set -l module_dir "$FEDPUNK_ROOT/modules/$module_name"
    set -l module_yaml "$module_dir/module.yaml"

    if not test -f "$module_yaml"
        echo "Module not found: $module_name" >&2
        return 1
    end

    # Get scripts for this hook
    set -l scripts (yaml-get-list "$module_yaml" "lifecycle" "$hook")

    if test -z "$scripts"
        echo "No $hook lifecycle scripts for $module_name"
        return 0
    end

    # Set up environment
    set -lx MODULE_NAME $module_name
    set -lx MODULE_DIR $module_dir
    set -lx STOW_TARGET $HOME

    # Run each script
    for script in $scripts
        set -l script_path "$module_dir/scripts/$script"

        if not test -f "$script_path"
            echo "Warning: Script not found: $script_path" >&2
            continue
        end

        if not test -x "$script_path"
            chmod +x "$script_path"
        end

        echo "  Running $hook/$script for $module_name..."
        $script_path
        if test $status -ne 0
            echo "Error: $hook/$script failed" >&2
            return 1
        end
    end
end

function fedpunk-module-deploy
    set -l module_name $argv[1]

    if test -z "$module_name"
        echo "Usage: fedpunk module deploy <module>" >&2
        return 1
    end

    # Check if already deployed in this session
    if contains $module_name $FEDPUNK_DEPLOYED_MODULES
        echo "Module $module_name already deployed in this session, skipping"
        return 0
    end

    echo "Deploying module: $module_name"
    echo ""

    # 0. Resolve dependencies first
    echo "==> Checking dependencies"
    fedpunk-module-resolve-dependencies $module_name
    or return 1
    echo ""

    # 1. Install packages
    echo "==> Installing packages"
    fedpunk-module-install-packages $module_name
    or return 1

    # 2. Run before lifecycle
    echo ""
    echo "==> Running before hook"
    fedpunk-module-run-lifecycle $module_name before

    # 3. Run after lifecycle
    echo ""
    echo "==> Running after hook"
    fedpunk-module-run-lifecycle $module_name after

    # 4. Stow config (always last)
    echo ""
    echo "==> Deploying configuration"
    fedpunk-module-stow $module_name
    or return 1

    echo ""
    echo "✓ Module $module_name deployed successfully"

    # Mark as deployed
    set -g FEDPUNK_DEPLOYED_MODULES $FEDPUNK_DEPLOYED_MODULES $module_name

    return 0
end
