#!/usr/bin/env bash

# Install latest node JavaScript runtime environment (https://www.nodejs.org/)

install_node() {
	brew install node

	# Update npm to latest version
	npm i -g npm
}
! command -v node >/dev/null && install_node

