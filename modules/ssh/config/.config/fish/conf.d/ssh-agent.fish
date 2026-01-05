# SSH Agent configuration
# Use stable socket symlink for agent persistence across shells

set -l stable_socket "$HOME/.ssh/agent.sock"

# Check if stable socket exists and is a working socket
if test -S "$stable_socket"
    # Test if the agent behind the socket is actually responding
    SSH_AUTH_SOCK="$stable_socket" ssh-add -l &>/dev/null
    set -l agent_status $status

    # status 0 = keys listed, 1 = no identities (but connected), 2 = can't connect
    if test $agent_status -ne 2
        set -gx SSH_AUTH_SOCK "$stable_socket"
    end
end
