# SSH Agent configuration
# Use stable socket symlink for container compatibility

# Only set if the stable socket exists
if test -S "$HOME/.ssh/agent.sock"
    set -gx SSH_AUTH_SOCK "$HOME/.ssh/agent.sock"
end
