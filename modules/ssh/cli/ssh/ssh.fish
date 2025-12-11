#!/usr/bin/env fish
# SSH management commands
# Handles key loading, host management, and SSH configuration

# Source CLI dispatch library
if not functions -q cli-dispatch
    source "$FEDPUNK_ROOT/lib/fish/cli-dispatch.fish"
end

function ssh --description "SSH key and configuration management"
    set -l cmd_dir (dirname (status --current-filename))
    cli-dispatch ssh $cmd_dir $argv
end

function load --description "Load SSH keys into agent"
    if contains -- "$argv[1]" --help -h
        printf "Load SSH keys into ssh-agent\n"
        printf "\n"
        printf "Usage: fedpunk ssh load [key]\n"
        printf "\n"
        printf "Arguments:\n"
        printf "  key    Specific key to load (default: all keys)\n"
        printf "\n"
        printf "Examples:\n"
        printf "  fedpunk ssh load            # Load all keys\n"
        printf "  fedpunk ssh load id_ed25519 # Load specific key\n"
        return 0
    end

    set -l SSH_DIR "$HOME/.ssh"
    set -l key_name $argv[1]

    # Check if agent is accessible (handles both local agent and forwarded agent)
    if not ssh-add -l &>/dev/null
        # Agent not accessible or not running
        if test -n "$SSH_AUTH_SOCK"
            # SSH_AUTH_SOCK is set but agent is not responding (possibly forwarded agent issue)
            printf "Warning: SSH_AUTH_SOCK is set but agent is not responding\n"
            printf "Attempting to start local agent...\n"
        end

        # Start local ssh-agent
        eval (ssh-agent -c) >/dev/null
        set -Ux SSH_AGENT_PID $SSH_AGENT_PID
        set -Ux SSH_AUTH_SOCK $SSH_AUTH_SOCK
        printf "Started ssh-agent (PID: %s)\n" $SSH_AGENT_PID
    else
        # Agent is accessible
        if test -n "$SSH_CONNECTION"
            printf "Using forwarded SSH agent\n"
        else
            printf "Using local SSH agent\n"
        end
    end

    if test -n "$key_name"
        # Load specific key
        set -l key_path "$SSH_DIR/$key_name"
        if not test -f "$key_path"
            printf "Error: Key not found: %s\n" "$key_path" >&2
            return 1
        end
        ssh-add "$key_path"
    else
        # Load all keys
        set -l key_files (find "$SSH_DIR" -maxdepth 1 -type f -name "id_*" ! -name "*.pub" 2>/dev/null)

        if test -z "$key_files"
            printf "Error: No SSH keys found in %s\n" "$SSH_DIR" >&2
            return 1
        end

        for key in $key_files
            printf "Loading %s...\n" (basename $key)
            ssh-add "$key" 2>/dev/null
        end
    end

    printf "\n"
    printf "Loaded keys:\n"
    ssh-add -l
end

function list --description "List configured SSH hosts"
    if contains -- "$argv[1]" --help -h
        printf "List configured SSH hosts\n"
        printf "\n"
        printf "Usage: fedpunk ssh list\n"
        return 0
    end

    set -l hosts_file "$HOME/.ssh/config.d/hosts"

    if not test -f "$hosts_file"
        printf "No hosts configured in %s\n" "$hosts_file"
        return 0
    end

    printf "Configured SSH hosts:\n\n"

    # Parse hosts from config
    set -l current_host ""
    while read -l line
        # Match "Host <name>"
        if string match -qr "^Host\s+(\S+)" $line
            set current_host (string match -r "^Host\s+(\S+)" $line | tail -1)
            printf "  %s\n" $current_host
        else if test -n "$current_host"; and string match -qr "^\s+HostName\s+(\S+)" $line
            set target_host (string match -r "^\s+HostName\s+(\S+)" $line | tail -1)
            printf "    → %s\n" $target_host
            set current_host ""
        end
    end < "$hosts_file"
end

function edit --description "Edit SSH hosts configuration"
    if contains -- "$argv[1]" --help -h
        printf "Edit SSH hosts configuration\n"
        printf "\n"
        printf "Usage: fedpunk ssh edit\n"
        printf "\n"
        printf "Opens ~/.ssh/config.d/hosts in your default editor.\n"
        return 0
    end

    set -l hosts_file "$HOME/.ssh/config.d/hosts"
    set -l editor $EDITOR

    if test -z "$editor"
        set editor nvim
    end

    if not command -v $editor >/dev/null
        set editor vi
    end

    $editor "$hosts_file"
end

function test-connection --description "Test SSH connection to a host"
    if contains -- "$argv[1]" --help -h
        printf "Test SSH connection to a configured host\n"
        printf "\n"
        printf "Usage: fedpunk ssh test <host>\n"
        printf "\n"
        printf "Arguments:\n"
        printf "  host    Host name from your SSH config\n"
        printf "\n"
        printf "Examples:\n"
        printf "  fedpunk ssh test myserver\n"
        return 0
    end

    set -l host_name $argv[1]

    if test -z "$host_name"
        printf "Error: Host name required\n" >&2
        printf "Usage: fedpunk ssh test <host>\n" >&2
        return 1
    end

    printf "Testing connection to %s...\n" $host_name
    ssh -v -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no $host_name exit 2>&1 | grep -E "^(debug1: Connecting|debug1: Connection established|debug1: Authentication succeeded)"
end
