#!/usr/bin/env bash

# Install Neovim


# Utility functions
is_mac() { [[ $(uname -s) = 'Darwin' ]]; }
is_ubuntu() { [[ -f /etc/os-release && $(head -1 /etc/os-release) = 'NAME="Ubuntu"' ]]; }


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

