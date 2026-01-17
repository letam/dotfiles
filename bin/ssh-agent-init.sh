#!/bin/bash
[ -f /tmp/ssh-agent.env ] && source /tmp/ssh-agent.env || { ssh-agent > /tmp/ssh-agent.env; source /tmp/ssh-agent.env; }
