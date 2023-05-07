#!/usr/bin/env bash


# Install Python coding-related dev tools
#   Includes:
#     - LSP Server (https://github.com/python-lsp/python-lsp-server)
#     - Formatting tools
#     - Typing tools


install() {
	pipx install 'python-lsp-server'
	pipx install --include-deps pylsp-rope
	pipx install --include-deps python-lsp-ruff
	pipx install --include-deps python-lsp-black
	pipx install --include-deps pylsp-mypy

	pipx install isort
	pipx install djhtml
	pipx install djlint
}


uninstall() {
	pipx uninstall 'python-lsp-server'
	pipx uninstall pylsp-rope
	pipx uninstall python-lsp-ruff
	pipx uninstall python-lsp-black
	pipx uninstall pylsp-mypy

	pipx uninstall isort
	pipx uninstall djhtml
	pipx uninstall djlint
}


install
