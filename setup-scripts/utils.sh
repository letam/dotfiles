#!/usr/bin/env bash

# Utility functions


info() { printf "\e[34m[INFO]\e[0m %s\n" "$*"; }
error(){ printf "\e[31m[ERROR]\e[0m %s\n" "$*" >&2; exit 1; }


detect_os() {
	case "$(uname -s)" in
		Linux)
			if command -v apt >/dev/null; then OS=ubuntu
			elif command -v dnf >/dev/null; then OS=fedora
			else error "Unsupported Linux distro"; fi;;
		Darwin) OS=mac;;
		*)	error "Unsupported OS: $(uname -s)";;
	esac
}

is_mac() { [[ $(uname -s) = 'Darwin' ]]; }

is_ubuntu() { [[ -f /etc/os-release && -n $(grep -m1 "NAME=\"Ubuntu\"" /etc/os-release) ]]; }


# helper: append a line to a file if it’s not already present
add_line_if_missing() {
	local file=$1
	local marker=$2	 # comment heading to group lines
	local line=$3		 # the actual invocation

	# ensure parent dir exists
	mkdir -p "$(dirname "$file")"

	# create file if absent
	touch "$file"

	# skip if exact line already exists
	if grep -Fxq "$line" "$file"; then
		info "✔ already in $file"
	else
		{
			printf "\n# %s\n" "$marker"
			printf "%s\n" "$line"
		} >> "$file"
		info "✚ added to $file"
	fi
}

