#!/usr/bin/env bash

# Utility functions


is_mac() { [[ $(uname -s) = 'Darwin' ]]; }

is_ubuntu() { [[ -f /etc/os-release && -n $(grep -m1 "NAME=\"Ubuntu\"" /etc/os-release) ]]; }

