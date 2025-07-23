#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Install some nerdfonts
# Source: https://github.com/ryanoasis/nerd-fonts


# Load utility functions
source ./setup-scripts/utils.sh


if is_ubuntu; then
	mkdir -p ~/.local/share/fonts

	cd ~/.local/share/fonts


	# Ubuntu Mono
	curl -fLo "Ubuntu Mono Nerd Font-Regular.ttf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/UbuntuMono/Regular/UbuntuMonoNerdFont-Regular.ttf


	# MesloLG (based on Apple's Menlo)
	curl -fLo "Meslo LG S Nerd Font-Regular.ttf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Meslo/S/Regular/MesloLGSNerdFont-Regular.ttf
	curl -fLo "Meslo LG M Nerd Font-Regular.ttf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Meslo/M/Regular/MesloLGMNerdFont-Regular.ttf


	# Caskaydia Cove (based on Windows' Cascadia Code)
	curl -fLo "Caskaydia Cove Nerd Font-Regular.ttf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/CascadiaCode/Regular/CaskaydiaCoveNerdFont-Regular.ttf


	# Droid Sans Mono for Powerline
	curl -fLo "Droid Sans Mono Nerd Font-Regular.otf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/DroidSansMono/DroidSansMNerdFont-Regular.otf

else

	fonts=(
		font-0xproto-nerd-font
		font-fantasque-sans-mono-nerd-font
		font-fira-code-nerd-font
		font-geist-mono-nerd-font
		font-jetbrains-mono-nerd-font
		font-meslo-lg-nerd-font
		font-mononoki-nerd-font
		font-ubuntu-sans-nerd-font
	)

	for font in "${fonts[@]}"; do
		brew install --cask "$font"
	done
fi
