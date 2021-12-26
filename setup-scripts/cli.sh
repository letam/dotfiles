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


# Install fd - More human-friendly find tool (https://github.com/sharkdp/fd)
install_fd() {
	if is_mac; then
		brew install fd
	elif is_ubuntu; then
		sudo apt install fd-find
		mkdir -p ~/.local/bin
		ln -s $(which fdfind) ~/.local/bin/fd
		# TODO: Ensure that '$HOME/.local/bin' is in $PATH
	fi
	set_fd_as_fzf_default_command() {
		cat >> ~/.zshrc <<"EOF"

# Setting fd as the default source for fzf
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
EOF
	}
	set_fd_as_fzf_default_command
}
if ! command -v fd >/dev/null; then
	install_fd
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


# Install the silver searcher (ag) - A code-searching tool similar to ack, but faster (https://github.com/ggreer/the_silver_searcher)
install_ag() {
	if is_mac; then
		brew install the_silver_searcher
	elif is_ubuntu; then
		sudo apt install silversearcher-ag
	fi
}
! command -v ag >/dev/null && install_ag


# Install delta - Syntax-highlighting pager for git, diff, and grep output (https://github.com/dandavison/delta)
install_delta() {
	if command -v brew >/dev/null; then
		brew install git-delta
	elif command -v dnf >/dev/null; then
		dnf install git-delta
	else
		echo "Error: Unable to install 'delta' on this machine."
	fi

	update_gitconfig_for_delta() {
		cat >> ~/.gitconfig <<"EOF"

; https://github.com/dandavison/delta
[core]
	pager = delta

[interactive]
	diffFilter = delta --color-only

[delta]
	navigate = true
	; side-by-side = true
	; line-numbers-left-format = ""
	; line-numbers-right-format = "│ "

[merge]
	conflictstyle = diff3

[diff]
	colorMoved = default
EOF
	}
	if command -v delta >/dev/null && \
			! grep -q -E '\tpager = delta' ~/.gitconfig; then
		update_gitconfig_for_delta
	fi
}
! command -v delta >/dev/null && install_delta
