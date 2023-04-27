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
	echo "Installing Neovim..."
	brew install neovim
	sudo ln -s `which nvim` /usr/local/bin/vim
}
# If command `nvim` is not found, then run function to install Neovim
! command -v nvim >/dev/null && install_neovim


# Link Neovim configuration for user
# Note: Ensure that you are in the root directory of this project/repo to ensure that `pwd` evaluates properly
mkdir -p ~/.config/nvim
ln -s $(pwd)/.vimrc ~/.config/nvim/init.vim
ln -s $(pwd)/nvim/lua ~/.config/nvim

# Link vimrc to home directory for easy access
ln -s $(pwd)/.vimrc ~/.vimrc


# Install vim-plug - Vim/Neovim plugin manager (https://github.com/junegunn/vim-plug)
install_plug() {
	sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
		https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
	nvim +PlugInstall  # Install plugins found in ~/.config/nvim/init.vim
}
[[ ! -f ~/.local/share/nvim/site/autoload/plug.vim ]] && install_plug

