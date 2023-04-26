#!/usr/bin/env bash

# Install Gogh color scheme manager for terminal emulators
# Source: https://github.com/Gogh-Co/Gogh

# Utility functions
is_ubuntu() { cat /etc/os-release | grep -q "NAME=\"Ubuntu\""; }


if is_ubuntu; then
	# Install pre-requisites
	! command -v dconf >/dev/null && sudo apt install dconf-cli uuid-runtime

	bash -c "$(wget -qO- https://git.io/vQgMr)"
else
	bash -c "$(curl -sLo- https://git.io/vQgMr)"
fi

