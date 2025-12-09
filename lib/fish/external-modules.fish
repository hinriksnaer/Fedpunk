#!/usr/bin/env fish
# External module management - handles git-based modules

# Source dependencies
set -l lib_dir (dirname (status -f))
source "$lib_dir/module-ref-parser.fish"
source "$lib_dir/ui.fish"

function external-module-cache-dir
    # Get the cache directory for external modules
    echo "$FEDPUNK_USER/cache/external"
end

function external-module-get-cache-path
    # Get the cache path for a specific external module URL
    # Usage: external-module-get-cache-path <url>
    set -l url $argv[1]

    # Extract components from URL
    # https://github.com/org/repo.git -> github.com/org/repo
    # git@github.com:org/repo.git -> github.com/org/repo
    # file:///path/to/repo -> path/to/repo

    set -l cache_base (external-module-cache-dir)

    # Normalize the URL to a path
    set -l normalized_url (string replace -r '^https?://' '' "$url")
    set -l normalized_url (string replace -r '^git@' '' "$normalized_url")
    set -l normalized_url (string replace -r '^file://' '' "$normalized_url")
    set -l normalized_url (string replace ':' '/' "$normalized_url")
    set -l normalized_url (string replace -r '\.git$' '' "$normalized_url")

    echo "$cache_base/$normalized_url"
end

function external-module-fetch
    # Fetch (clone or pull) an external module
    # Usage: external-module-fetch <url>
    set -l url $argv[1]

    set -l cache_path (external-module-get-cache-path "$url")
    set -l cache_dir (dirname "$cache_path")

    # Create cache directory if it doesn't exist
    if not test -d "$cache_dir"
        mkdir -p "$cache_dir"
    end

    if test -d "$cache_path"
        # Already cloned, pull latest
        ui-info "Updating external module: $url"
        pushd "$cache_path" >/dev/null
        git pull --quiet
        or begin
            popd >/dev/null
            ui-error "Failed to update external module: $url"
            return 1
        end
        popd >/dev/null
    else
        # Clone the repository
        ui-info "Fetching external module: $url"
        git clone --quiet "$url" "$cache_path"
        or begin
            ui-error "Failed to clone external module: $url"
            return 1
        end
    end

    # Verify module.yaml exists
    if not test -f "$cache_path/module.yaml"
        ui-error "Invalid external module: module.yaml not found in $url"
        return 1
    end

    echo "$cache_path"
    return 0
end
