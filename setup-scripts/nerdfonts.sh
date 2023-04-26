#!/usr/bin/env bash

# Install some nerdfonts on Ubuntu Linux OS
# Source: https://github.com/ryanoasis/nerd-fonts


mkdir -p ~/.local/share/fonts

cd ~/.local/share/fonts


# Ubuntu Mono
curl -fLo "Ubuntu Mono Nerd Font Complete.ttf" https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/UbuntuMono/Regular/complete/Ubuntu%20Mono%20Nerd%20Font%20Complete.ttf


# MesloLG (based on Apple's Menlo)
curl -fLo "Meslo LG S Regular Nerd Font Complete.ttf" https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/Meslo/S/Regular/complete/Meslo%20LG%20S%20Regular%20Nerd%20Font%20Complete.ttf
curl -fLo "Meslo LG M Regular Nerd Font Complete.ttf" https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/Meslo/M/Regular/complete/Meslo%20LG%20M%20Regular%20Nerd%20Font%20Complete.ttf


# Caskaydia Cove (based on Windows' Cascadia Code)
curl -fLo "Caskaydia Cove Nerd Font Complete Regular.otf" https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/CascadiaCode/Regular/complete/Caskaydia%20Cove%20Nerd%20Font%20Complete%20Regular.otf


# Droid Sans Mono for Powerline
curl -fLo "Droid Sans Mono for Powerline Nerd Font Complete.otf" https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/DroidSansMono/complete/Droid%20Sans%20Mono%20Nerd%20Font%20Complete.otf

