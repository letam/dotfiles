#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# Install common CLI tools


# Load utility functions
source ./setup-scripts/utils.sh

detect_os
info "Detected OS: $OS"


# Install essential tools on Ubuntu
if is_ubuntu; then
	for pkg in git curl tmux xclip; do
		if command -v "$pkg" >/dev/null; then
			info "$pkg is already installed"
		else
			info "Installing $pkg…"
			sudo apt install -y "$pkg"
		fi
	done
fi


# Update bash config (~/.bashrc) with letam's shbang bash setup script
if is_ubuntu; then
	if grep -q 'Bash settings' ~/.bashrc; then 
		info 'Bash is already set up with our custom settings'
	else
		info "Settig up Bash with shbang settings"
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/letam/shbang/master/setup/cli/bash)"
	fi
fi


# Install Homebrew package manager (https://brew.sh/)
install_brew() {
	info "Starting Homebrew installation…"

	if command -v brew >/dev/null; then
		info "brew is already installed"
	else
		info "brew not found — installing Homebrew now"
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	fi

	if is_ubuntu; then
		if grep -q 'Load brew' ~/.bashrc; then 
			info "Linuxbrew environment already configured in ~/.profile"
		else
			info "Configuring Linuxbrew environment in ~/.profile"
			{
				echo
				echo '# Load brew'
				echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"'
			} >> "$HOME/.profile"
			eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

			info "Installing build-essential via apt"
			sudo apt install -y build-essential

			info "Installing gcc via brew"
			brew install gcc
		fi
	elif is_mac; then
		if grep -q 'brew shellenv' ~/.zprofile; then 
			info "Homebrew environment already configured in ~/.zprofile"
		else
			info "Configuring Homebrew environment in ~/.zprofile"
			{
				echo
				echo '# Load brew'
				echo 'eval "$(/usr/local/bin/brew shellenv)"'
			} >> "$HOME/.zprofile"
			eval "$(/usr/local/bin/brew shellenv)"
		fi
	fi
	info "Homebrew installation complete."
}
install_brew


# Install FZF general-purpose command-line fuzzy finder (https://github.com/junegunn/fzf)
install_fzf() {
	if command -v fzf >/dev/null; then
		info "fzf is already installed"
	else
		info "Installing fzf via Homebrew…"
		brew install fzf
	fi
	info "Setting up fzf shell integration…"

	# Bash integration
	add_line_if_missing \
		"$HOME/.bashrc" \
		"Set up fzf key bindings and fuzzy completion" \
		'eval "$(fzf --bash)"'

	# Zsh integration
	add_line_if_missing \
		"$HOME/.zshrc" \
		"Set up fzf key bindings and fuzzy completion" \
		'source <(fzf --zsh)'
	
	# # Fish integration
	# add_line_if_missing \
	# 	"$HOME/.config/fish/config.fish" \
	# 	"Set up fzf key bindings" \
	# 	'fzf --fish | source'

}
install_fzf


# Install latest Python interpreter (https://www.python.org/)
install_python() {
	info "Installing Python via Homebrew…"
	brew install python

	if [ ! -d /usr/local/bin ]; then
		info "Creating /usr/local/bin directory…"
		sudo mkdir -p /usr/local/bin
	else
		info "/usr/local/bin already exists"
	fi

	info "Linking python3 to python…"
	sudo ln -sf "$(which python3)" /usr/local/bin/python

	# info/ "Updating pip and setuptools…"
	# python -m pip install -U pip setuptools

	info "Python installation complete."
}
install_python


# Install pipx - Install and Run Python Applications in Isolated Environments (https://pypa.github.io/pipx/)
# 	Note: Currently only used to install ranger-fm
install_pipx() {
	if command -v pipx >/dev/null; then
		info "pipx is already installed"
	else
		info "Installing pipx…"
		brew install pipx
	fi
	pipx ensurepath
}
install_pipx


# Install uv - Python package and project manager (https://github.com/astral-sh/uv)
install_uv() {
	if command -v uv >/dev/null; then
		info "uv is already installed"
	else
		info "Installing uv…"
		# On macOS and Linux.
		curl -LsSf https://astral.sh/uv/install.sh | sh
		source $HOME/.local/bin/env
	fi
}
install_uv


# Install ranger - A VIM-inspired filemanager for the console
install_ranger() {
	if command -v ranger >/dev/null; then
		info "ranger is already installed"
	else
		info "Installing ranger…"
		pipx install ranger-fm
	fi
}
install_ranger


# Install enhanced line search tool (https://github.com/BurntSushi/ripgrep)
install_ripgrep() {
	if command -v rg >/dev/null; then
		info "ripgrep is already installed"
	else
		info "Installing ripgrep…"
		brew install ripgrep
	fi
}
install_ripgrep


# Install fd - More human-friendly find tool (https://github.com/sharkdp/fd)
install_fd() {
	if command -v fd >/dev/null; then
		info "fd is already installed"
	else
		info "Installing fd…"
		if is_ubuntu; then
			sudo apt install fd-find
			mkdir -p ~/.local/bin
			ln -s "$(which fdfind)" ~/.local/bin/fd
			# TODO: Ensure that '$HOME/.local/bin' is in $PATH
		elif is_mac; then
			brew install fd
		fi
	fi

	set_fd_as_fzf_default_command() {
		local rc=$1
		if grep -q 'Setting fd as the default source for fzf' "$rc"; then
			info "fd is already set as the default source for fzf in $rc"
			return
		fi
		info "Setting fd as the default source for fzf in $rc"
		cat >> "$rc" <<"EOF"

# Setting fd as the default source for fzf
export FZF_DEFAULT_COMMAND='fd --type file --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
EOF
	}
	
	for rc in ~/.zshrc ~/.bashrc; do
		if [ -f "$rc" ]; then
			set_fd_as_fzf_default_command "$rc"
		fi
	done
}
install_fd


# Install bat - cat clone with syntax highlighting and git integration (https://github.com/sharkdp/bat)
 # Check out integration with other tools: https://github.com/sharkdp/bat#integration-with-other-tools
install_bat() {
	if is_ubuntu; then
		sudo apt install bat
		sudo ln -s /usr/bin/batcat /usr/local/bin/bat
	elif is_mac; then
		brew install bat
	fi
}
! command -v bat >/dev/null && install_bat


# Install the silver searcher (ag) - A code-searching tool similar to ack, but faster (https://github.com/ggreer/the_silver_searcher)
install_ag() {
	if is_ubuntu; then
		sudo apt install silversearcher-ag
	elif is_mac; then
		brew install the_silver_searcher
	fi
}
! command -v ag >/dev/null && install_ag


# Install icdiff - improved colored diff (https://github.com/jeffkaufman/icdiff)
install_icdiff() {
	if command -v icdiff >/dev/null; then
		info "icdiff is already installed"
	else
		info "Installing icdiff…"
		brew install icdiff
	fi

	# Configure icdiff options
	git config --global icdiff.options '--highlight --line-numbers'
}
install_icdiff


# Install delta - Syntax-highlighting pager for git, diff, and grep output (https://github.com/dandavison/delta)
install_delta() {
	if command -v delta >/dev/null; then
		info "delta is already installed"
	else
		info "Installing delta…"
		if command -v brew >/dev/null; then
			brew install git-delta
		elif command -v dnf >/dev/null; then
			dnf install git-delta
		else
			info "Error: Unable to install 'delta' on this machine."
		fi
	fi

	update_gitconfig_for_delta() {
		cat >> ~/.gitconfig <<"EOF"

; https://github.com/dandavison/delta
[core]
	; pager = delta
	; Better config for git pager based on width of window
	; https://github.com/wfxr/forgit/issues/121#issuecomment-725811214
	pager = "{									\
		COLUMNS=$(tput cols);							\
		if [ $COLUMNS -ge 80 ] && [ -z $FZF_PREVIEW_COLUMNS ]; then		\
			delta --side-by-side -w $COLUMNS;				\
		elif [ $COLUMNS -ge 160 ] && [ ! -z $FZF_PREVIEW_COLUMNS ]; then	\
			delta --side-by-side -w $FZF_PREVIEW_COLUMNS;			\
		else									\
			delta;								\
		fi									\
	}"

[interactive]
	diffFilter = delta --color-only

[delta]
	navigate = true
	; side-by-side = true
	; line-numbers-left-format = ""
	; line-numbers-right-format = "│ "

[merge]
	conflictstyle = diff3

[diff]
	colorMoved = default

EOF
	if command -v delta >/dev/null && ( \
			[[ ! -f ~/.gitconfig ]] || \
			! grep -q -E '\t*\[delta\]' ~/.gitconfig \
			); then
		info "Configuring delta in gitconfig"
		update_gitconfig_for_delta
	fi
	}
}
# NOTE: Do not install delta for git diff since it seems to not work well for light backgrounds
# install_delta

