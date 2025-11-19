# SSH Agent
if test -z "$SSH_AUTH_SOCK"
    eval (ssh-agent -c) > /dev/null
    set -gx SSH_AGENT_PID (pgrep -u $USER ssh-agent)
end
