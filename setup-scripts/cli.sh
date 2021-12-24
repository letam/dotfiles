#!/usr/bin/env bash


# Utility functions
is_mac() { [[ $(uname -s) = 'Darwin' ]]; }
is_ubuntu() { [[ -f /etc/os-release && $(head -1 /etc/os-release) = 'NAME="Ubuntu"' ]]; }


# Install FZF general-purpose command-line fuzzy finder (https://github.com/junegunn/fzf)
install_fzf() {
	git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
	~/.fzf/install
}
[ ! -d ~/.fzf ] && install_fzf


# Install Homebrew package manager (https://brew.sh/)
install_brew() {
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}
if is_mac && ! command -v brew >/dev/null; then
	install_brew
fi


# Install enhanced line search tool (https://github.com/BurntSushi/ripgrep)
install_ripgrep() {
	if is_mac; then
		brew install ripgrep
	elif is_ubuntu; then
		sudo apt install ripgrep
	fi
}
if ! command -v rg >/dev/null; then
	install_ripgrep
fi


# Install bat - cat clone with syntax highlighting and git integration (https://github.com/sharkdp/bat)
 # Check out integration with other tools: https://github.com/sharkdp/bat#integration-with-other-tools
install_bat() {
	if is_mac; then
		brew install bat
	elif is_ubuntu; then
		sudo apt install bat
	fi
}
! command -v bat >/dev/null && install_bat
