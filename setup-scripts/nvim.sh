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
		if is_ubuntu; then
			local arch tarball url
			arch=$(uname -m)
			case "$arch" in
				x86_64)  tarball=nvim-linux-x86_64.tar.gz ;;
				aarch64) tarball=nvim-linux-arm64.tar.gz ;;
				*) error "Unsupported architecture: $arch" ;;
			esac
			url="https://github.com/neovim/neovim/releases/latest/download/$tarball"
			info "Downloading $url"
			curl -fL --progress-bar -o "/tmp/$tarball" "$url"
			info "Extracting to /opt"
			sudo rm -rf /opt/nvim-linux-x86_64 /opt/nvim-linux-arm64
			sudo tar -C /opt -xzf "/tmp/$tarball"
			rm -f "/tmp/$tarball"
			sudo ln -sf "/opt/${tarball%.tar.gz}/bin/nvim" /usr/local/bin/nvim
		else
			brew install neovim
		fi
	fi
	sudo ln -sf "$(which nvim)" /usr/local/bin/vim

	git config --global core.editor vim
}
install_neovim


# Link Neovim configuration for user
# Note: Ensure that you are in the root directory of this project/repo to ensure that `pwd` evaluates properly
mkdir -p ~/.config
ln -sfn "$(pwd)/.config/nvim" ~/.config/nvim

# Link init.vim to home directory for easy access
ln -sf "$(pwd)/.config/nvim/init.vim" ~/.nvimrc

