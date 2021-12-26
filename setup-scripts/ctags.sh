#!/usr/bin/env bash


# Install ctags - creates a index (or tag) file of language objects found in source files for programming languages.
# This index makes it easy for text editors (such as Vim) and other tools to locate the indexed items.
 # Source: https://github.com/universal-ctags/ctags

# Utility functions
is_mac() { [[ $(uname -s) = 'Darwin' ]]; }
is_ubuntu() { [[ -f /etc/os-release && $(head -1 /etc/os-release) = 'NAME="Ubuntu"' ]]; }

install_ctags() {
	if is_mac; then
		brew install --HEAD universal-ctags/universal-ctags/universal-ctags
		sudo ln -s /opt/homebrew/bin/ctags /usr/local/bin
	else
		echo "Not implemented for this OS"
	fi
}
! command -v ctags >/dev/null && install_ctags