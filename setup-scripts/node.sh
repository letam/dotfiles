#!/usr/bin/env bash

# Install latest node JavaScript runtime environment (https://www.nodejs.org/)

install_node() {
	brew install node
}
! command -v node >/dev/null && install_node

