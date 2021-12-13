#!/usr/bin/env bash

# Install Zsh (Z Shell) and setup plugins


install_zsh() {
	if command -v dnf >/dev/null; then
		sudo dnf install -y zsh
	elif command -v apt >/dev/null; then
		sudo apt install -y zsh
	fi
}

# If command `zsh` is not found, then run function to install Zsh
if ! command -v zsh >/dev/null; then
	install_zsh
fi


# Add history settings
cat >> ~/.zshrc <<-"EOF"


	# History settings

	# Cause all terminals to share the same history 'session', and save timestamps.
	setopt SHARE_HISTORY

	## Ignore lines that begin with a space, and ignore duplicate entries
	setopt HIST_IGNORE_SPACE
	setopt HIST_IGNORE_DUPS

	## Increase history size
	HISTFILE=~/.zhistory
	HISTSIZE=999999999
	SAVEHIST=$HISTSIZE

	EOF

