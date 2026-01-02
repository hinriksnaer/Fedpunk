#!/usr/bin/env fish
# External module management - handles git-based modules

# Source dependencies
set -l lib_dir (dirname (status -f))
source "$lib_dir/module-ref-parser.fish"
source "$lib_dir/ui.fish"

function external-module-storage-dir
    # Get the storage directory for external modules
    echo "$HOME/.config/fedpunk/modules"
end

function external-module-get-storage-path
    # Get the storage path for a specific external module URL
    # Usage: external-module-get-storage-path <url>
    # Priority-based resolution handles name collisions: profile -> .config/modules -> native
    set -l url $argv[1]

    # Extract repo name from URL (handles https://, git@, file:// formats)
    # https://github.com/org/repo.git -> repo
    # git@github.com:org/repo.git -> repo
    # file:///path/to/repo -> repo

    set -l storage_base (external-module-storage-dir)

    # Remove .git suffix, then extract last path component
    # Regex handles both / (HTTPS/file) and : (SSH) as separators
    set -l repo_name (string replace -r '\.git$' '' "$url")
    set -l repo_name (string replace -r '^.*[/:]' '' "$repo_name")

    echo "$storage_base/$repo_name"
end

function external-module-fetch
    # Fetch (clone or pull) an external module
    # Usage: external-module-fetch <url>
    set -l url $argv[1]

    set -l storage_path (external-module-get-storage-path "$url")
    set -l storage_dir (dirname "$storage_path")

    # Create storage directory if it doesn't exist
    if not test -d "$storage_dir"
        mkdir -p "$storage_dir"
    end

    if test -d "$storage_path"
        # Already cloned, pull latest
        ui-info "Updating external module: $url" >&2
        pushd "$storage_path" >/dev/null
        git pull --quiet
        or begin
            popd >/dev/null
            ui-error "Failed to update external module: $url"
            return 1
        end
        popd >/dev/null
    else
        # Clone the repository
        ui-info "Fetching external module: $url" >&2
        git clone --quiet "$url" "$storage_path"
        or begin
            ui-error "Failed to clone external module: $url"
            return 1
        end
    end

    # Verify module.yaml exists
    if not test -f "$storage_path/module.yaml"
        ui-error "Invalid external module: module.yaml not found in $url"
        return 1
    end

    echo "$storage_path"
    return 0
end
