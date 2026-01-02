#!/usr/bin/env fish
# Fedpunk path detection and user space setup
# Auto-detects installation type and sets up user directories

function fedpunk-setup-paths
    # Detect system installation location
    if not set -q FEDPUNK_SYSTEM
        if test -d /usr/share/fedpunk
            # DNF installation
            set -gx FEDPUNK_SYSTEM /usr/share/fedpunk
        else if test -d ~/.local/share/fedpunk
            # Git clone installation
            set -gx FEDPUNK_SYSTEM ~/.local/share/fedpunk
        else if test -d (dirname (status -f))/../..
            # Running from source (current directory)
            set -gx FEDPUNK_SYSTEM (realpath (dirname (status -f))/../..)
        else
            echo "Error: Fedpunk installation not found" >&2
            return 1
        end
    end

    # User data directory (always ~/.local/share/fedpunk)
    if not set -q FEDPUNK_USER
        set -gx FEDPUNK_USER ~/.local/share/fedpunk
    end

    # Backward compatibility: FEDPUNK_ROOT points to system installation
    set -gx FEDPUNK_ROOT $FEDPUNK_SYSTEM

    return 0
end

function fedpunk-ensure-user-space
    # Auto-create user directories on first run (transparent to user)

    # If user space doesn't exist, create it
    if not test -d "$FEDPUNK_USER"
        echo "→ Setting up fedpunk user space..."
        mkdir -p "$FEDPUNK_USER"/{profiles,cache}

        # Copy example profile as starting point for dev profile
        if test -d "$FEDPUNK_SYSTEM/profiles/example"
            cp -r "$FEDPUNK_SYSTEM/profiles/example" "$FEDPUNK_USER/profiles/dev"
            echo "  ✓ Created dev profile from template"
        else
            # Fallback: create minimal structure
            mkdir -p "$FEDPUNK_USER/profiles/dev"/{modes,plugins,themes}
            echo "  ✓ Created minimal dev profile"
        end

        echo "  User space: $FEDPUNK_USER"
    end

    # Ensure .active-config exists
    if not test -e "$FEDPUNK_USER/.active-config"
        # If DNF install, default to built-in default profile
        if test "$FEDPUNK_SYSTEM" = "/usr/share/fedpunk"
            if test -d "$FEDPUNK_SYSTEM/profiles/default"
                ln -s "$FEDPUNK_SYSTEM/profiles/default" "$FEDPUNK_USER/.active-config"
                echo "  ✓ Set active profile: default (builtin)"
            end
        else
            # Git clone install, use dev profile
            if test -d "$FEDPUNK_USER/profiles/dev"
                ln -s "$FEDPUNK_USER/profiles/dev" "$FEDPUNK_USER/.active-config"
                echo "  ✓ Set active profile: dev"
            end
        end
    end

    # Ensure cache directories exist (for profiles)
    mkdir -p "$FEDPUNK_USER/cache"

    # Ensure config directory exists (XDG standard location)
    if not test -d "$HOME/.config/fedpunk"
        mkdir -p "$HOME/.config/fedpunk"/{profiles,modules}
    end

    return 0
end

# Auto-run path setup on source
fedpunk-setup-paths
