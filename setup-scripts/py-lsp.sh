#!/usr/bin/env bash


# Install Python LSP Server (https://github.com/python-lsp/python-lsp-server)
#

install() {
	pipx install 'python-lsp-server'
	pipx install --include-deps pylsp-rope
	pipx install --include-deps python-lsp-ruff
	pipx install --include-deps python-lsp-black
	pipx install --include-deps pylsp-mypy
}


uninstall() {
	pipx uninstall 'python-lsp-server'
	pipx uninstall pylsp-rope
	pipx uninstall python-lsp-ruff
	pipx uninstall python-lsp-black
	pipx uninstall pylsp-mypy
}


install
