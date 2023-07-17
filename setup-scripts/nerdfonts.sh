#!/usr/bin/env bash

# Install some nerdfonts on Ubuntu Linux OS
# Source: https://github.com/ryanoasis/nerd-fonts


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
