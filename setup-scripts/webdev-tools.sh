#!/usr/bin/env bash

# Install webdev tools


# Install Prettier daemon for formatting frontend code files (JavaScript, CSS, HTML, etc.)
brew install fsouza/prettierd/prettierd

# Install TypeScript & JavaScript Language Server for intellisense, etc.
brew install typescript-language-server

# Install Rome tools : formatter, linter, bundler, and more for JavaScript, TypeScript, JSON, HTML, Markdown, and CSS.
npm install -g rome
