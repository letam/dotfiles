#!/usr/bin/env bash

# Install Neovim


# Utility functions
is_mac() { [[ $(uname -s) = 'Darwin' ]]; }
is_ubuntu() { cat /etc/os-release | grep -q "NAME=\"Ubuntu\""; }


# Function to install Neovim on system
install_neovim() {
	echo "Installing Neovim..."
	if is_mac; then
		echo "Detected macOS."
		cd /opt
		sudo curl -LO https://github.com/neovim/neovim/releases/download/nightly/nvim-macos.tar.gz
		[[ ! $? -eq 0 ]] && exit 1
		sudo tar xzf nvim-macos.tar.gz
		sudo ln -s /opt/nvim-osx64/bin/nvim /usr/local/bin/nvim
		cd -
	elif is_ubuntu; then
		echo "Detected Ubuntu OS."
		sudo apt install neovim
		[[ ! $? -eq 0 ]] && exit 1
	else
		echo "Your OS is not supported. Please update the script as needed."
		exit 1
	fi
}

# If command `nvim` is not found, then run function to install Neovim
if ! command -v nvim >/dev/null; then
	install_neovim
fi


# Link Neovim configuration for user
# Note: Ensure that you are in the root directory of this project/repo to ensure that `pwd` evaluates properly
mkdir -p ~/.config/nvim
ln -s $(pwd)/.vimrc ~/.config/nvim/init.vim


# Function to install vim-plug plugin manager for Neovim (https://github.com/junegunn/vim-plug)
install_plug() {
	sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
		https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
}
if [[ ! -f ~/.local/share/nvim/site/autoload/plug.vim ]]; then
	install_plug
fi

