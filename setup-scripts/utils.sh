#!/usr/bin/env bash

# Utility functions


is_mac() { [[ $(uname -s) = 'Darwin' ]]; }

is_ubuntu() { cat /etc/os-release | grep -q "NAME=\"Ubuntu\""; }

