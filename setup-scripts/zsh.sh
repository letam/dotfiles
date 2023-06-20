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


# Enable interactive comments
config_interactive_comments() {
	cat >> ~/.zshrc <<-"EOF"

	# Enable Interactive Comments (Able to end commands with history-searchable comments)
	setopt interactive_comments

	EOF
}
config_interactive_comments


# Add history settings
config_history() {
	cat >> ~/.zshrc <<-"EOF"

	# History settings
		# Reference: https://github.com/mattjj/my-oh-my-zsh/blob/master/history.zsh
		# Reference: https://github.com/ohmyzsh/ohmyzsh/blob/master/lib/history.zsh

	HISTFILE=~/.zhistory

	## Increase history size
	HISTSIZE=999999999
	SAVEHIST=$HISTSIZE

	setopt SHARE_HISTORY          # share history between all sessions
	setopt EXTENDED_HISTORY       # write the history file with timestamps in the ":start:elapsed;command" format
	setopt INC_APPEND_HISTORY     # write to the history file immediately, not when the shell exits

	setopt HIST_IGNORE_DUPS       # ignore duplicated commands in history list
	setopt HIST_IGNORE_SPACE      # ignore commands that start with space
	setopt HIST_EXPIRE_DUPS_FIRST # delete duplicate entries first when HISTFILE size exceeds HISTSIZE
	setopt HIST_REDUCE_BLANKS     # remove superfluous blanks before recording entry

	setopt HIST_FIND_NO_DUPS      # do not display a line previously found
	setopt HIST_VERIFY            # show command with history expansion to user before execution

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


# Install Powerlevel10k Theme (https://github.com/romkatv/powerlevel10k)
install_powerlevel10k_theme() {
	git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/"$plugins_dir"/powerlevel10k
	script_path='~'/"$plugins_dir"/powerlevel10k/powerlevel10k.zsh-theme
	if ! grep -q "source $script_path" ~/.zshrc; then
		echo "source $script_path" >> ~/.zshrc
	fi
}
# [ ! -d ~/"$plugins_dir"/powerlevel10k ] && install_powerlevel10k_theme


# Install Starship theme (https://starship.rs/)
install_starship_theme() {
	# detect if brew installed
	if command -v brew >/dev/null; then
		brew install starship
	else
		curl -sS https://starship.rs/install.sh | sh
	fi
	if ! grep -q 'eval "$(starship init zsh)"' ~/.zshrc; then
		echo >> ~/.zshrc
		echo '# Activate Starship theme' >> ~/.zshrc
		echo 'eval "$(starship init zsh)"' >> ~/.zshrc
	fi
}
! command -v starship >/dev/null && install_starship_theme


# Install zsh-autosuggestions for Fish-like autosuggestions (https://github.com/zsh-users/zsh-autosuggestions)
 # It suggests commands as you type based on history and completions.
install_zsh_autosuggestions() {
	git clone https://github.com/zsh-users/zsh-autosuggestions ~/"$plugins_dir"/zsh-autosuggestions
	if ! grep -q 'source ~/'"$plugins_dir"'/zsh-autosuggestions/zsh-autosuggestions.zsh' ~/.zshrc; then
		echo -e '\n# Load zsh-autosuggestions (https://github.com/zsh-users/zsh-autosuggestions)' >> ~/.zshrc
		echo 'source ~/'"$plugins_dir"'/zsh-autosuggestions/zsh-autosuggestions.zsh' >> ~/.zshrc
	fi
}
[ ! -d ~/"$plugins_dir"/zsh-autosuggestions ] && install_zsh_autosuggestions


# Install zsh-syntax-highlighting for Fish-like command line syntax highlighting support (https://github.com/zsh-users/zsh-syntax-highlighting)
install_zsh_syntax_highlighting() {
	cd ~/"$plugins_dir"
	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git
	if ! grep -q 'source ~/'"$plugins_dir"'/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh' ~/.zshrc; then
		echo -e '\n# Load zsh-syntax-highlighting (https://github.com/zsh-users/zsh-syntax-highlighting)' >> ${ZDOTDIR:-$HOME}/.zshrc
		echo 'source ~/'"$plugins_dir"'/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh' >> ${ZDOTDIR:-$HOME}/.zshrc
	fi
	cd -
}
[ ! -d ~/"$plugins_dir"/zsh-syntax-highlighting ] && install_zsh_syntax_highlighting


# Install zsh-history-substring-search for Fish-like history search feature, where you can type in any part of any command from history and then cycle through the matches by pressing the UP and DOWN arrows (https://github.com/zsh-users/zsh-history-substring-search)
install_zsh_history_substring_search() {
	cd ~/"$plugins_dir"
	git clone https://github.com/zsh-users/zsh-history-substring-search.git
	if ! grep -q 'source ~/'"$plugins_dir"'/zsh-history-substring-search/zsh-history-substring-search.zsh' ~/.zshrc; then
		echo -e '\n# Load zsh-history-substring-search (https://github.com/zsh-users/zsh-history-substring-search)' >> ~/.zshrc
		echo 'source ~/'"$plugins_dir"'/zsh-history-substring-search/zsh-history-substring-search.zsh' >> ~/.zshrc
		echo '  # Bind keyboard shortcuts for zsh-history-substring-search:' >> ~/.zshrc
		cat >> ~/.zshrc <<-"EOF"
		bindkey '^[[A' history-substring-search-up
		bindkey '^[[B' history-substring-search-down
		bindkey -M vicmd 'k' history-substring-search-up
		bindkey -M vicmd 'j' history-substring-search-down
		EOF
	fi
	cd -
}
[ ! -d ~/"$plugins_dir"/zsh-history-substring-search ] && install_zsh_history_substring_search


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


# Install interactive tool for git "forgit" (https://github.com/wfxr/forgit)
install_forgit_git_plugin_zsh() {
	curl -sSL git.io/forgit > ~/"$plugins_dir"/forgit.plugin.bash
	if ! grep -q 'source ~/'"$plugins_dir"'/forgit.plugin.bash' ~/.zshrc; then
		echo -e '\n# Load forgit interactive git tool (https://github.com/wfxr/forgit)' >> ~/.zshrc
		echo '[ -f ~/'"$plugins_dir"'/forgit.plugin.bash ] && source ~/'"$plugins_dir"'/forgit.plugin.bash' >> ~/.zshrc
	fi
}
install_forgit_git_plugin_zsh
