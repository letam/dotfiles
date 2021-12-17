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
config_history() {
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
}
if ! grep -q '# History settings' ~/.zshrc; then
	config_history
fi


# Set directory of zsh-plugins
plugins_dir=.local/share/zsh-plugins
[ ! -d "$plugins_dir" ] && (
	cd ~
	mkdir -p "$plugins_dir"
)


# Install Powerlevel10k Theme
install_powerlevel10k_theme() {
	git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/"$plugins_dir"/powerlevel10k
	script_path='~'/"$plugins_dir"/powerlevel10k/powerlevel10k.zsh-theme
	if ! grep -q "source $script_path" ~/.zshrc; then
		echo "source $script_path" >> ~/.zshrc
	fi
}
[ ! -d ~/"$plugins_dir"/powerlevel10k ] && install_powerlevel10k_theme


# Install git.plugin.zsh from Oh My Zsh framework (https://github.com/ohmyzsh/ohmyzsh)
install_git_plugin_zsh() {

	## Activate auto-completion system
	if ! grep -q 'autoload -Uz compinit' ~/.zshrc; then
		echo -e '\n# Activate auto-completion system' >> ~/.zshrc
		echo 'autoload -Uz compinit' >> ~/.zshrc
		echo 'compinit' >> ~/.zshrc
	fi

	cd ~/"$plugins_dir"
	curl -O https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/git/git.plugin.zsh
	if ! grep -q 'source ~/'"$plugins_dir"'/git.plugin.zsh' ~/.zshrc; then
		echo -e '\n# Load git plugin from Oh My Zsh framework (https://github.com/ohmyzsh/ohmyzsh)' >> ~/.zshrc
		echo '[ -f ~/'"$plugins_dir"'/git.plugin.zsh ] && source ~/'"$plugins_dir"'/git.plugin.zsh' >> ~/.zshrc
	fi
	cd - >/dev/null
}
install_git_plugin_zsh
