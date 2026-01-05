#!/usr/bin/env bash

# Install Neovim

source ./setup-scripts/utils.sh


# Ensure cmake is installed to compile certain plugins (i.e. 'nvim-telescope/telescope-fzf-native.nvim')
if is_mac; then
	brew install cmake
elif is_ubuntu; then
	sudo snap install --classic cmake
fi


# Function to install Neovim on system
install_neovim() {
	if command -v nvim >/dev/null; then
		echo "Neovim is already installed"
	else
		echo "Installing Neovim..."
		brew install neovim
	fi
	sudo ln -s `which nvim` /usr/local/bin/vim

	git config --global core.editor vim
}
install_neovim


# Link Neovim configuration for user
# Note: Ensure that you are in the root directory of this project/repo to ensure that `pwd` evaluates properly
mkdir ~/.config
ln -s $(pwd)/.config/nvim ~/.config

# Link init.vim to home directory for easy access
ln -s $(pwd)/.config/nvim/init.vim ~/.nvimrc

