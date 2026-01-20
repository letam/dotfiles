#!/bin/bash
# Usage: source this script to set SSH_AUTH_SOCK and SSH_AGENT_PID
#   source ~/code/dotfiles/bin/ssh-agent-init.sh

_start_agent() {
    eval $(ssh-agent -s) >/dev/null
    echo "SSH_AUTH_SOCK=$SSH_AUTH_SOCK; export SSH_AUTH_SOCK;" > /tmp/ssh-agent.env
    echo "SSH_AGENT_PID=$SSH_AGENT_PID; export SSH_AGENT_PID;" >> /tmp/ssh-agent.env
}

if [ -f /tmp/ssh-agent.env ]; then
    source /tmp/ssh-agent.env
    # Check if agent is still running (exit 2 = cannot connect)
    ssh-add -l &>/dev/null
    if [ "$?" -eq 2 ]; then
        _start_agent
    fi
else
    _start_agent
fi

unset -f _start_agent
