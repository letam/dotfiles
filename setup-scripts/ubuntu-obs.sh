#!/usr/bin/env bash

# Install guide for OBS Studio on (Ubuntu) Linux
# Reference: https://obsproject.com/wiki/install-instructions#linux


# Prerequisites

# Install OpenGL
sudo apt install mesa-utils

# For virtual camera support, install v4l2loopback-dkms module
sudo apt install v4l2loopback-dkms

# Enable multiverse repo in Ubuntu's software center
sudo add-apt-repository ppa:obsproject/obs-studio
sudo apt update

# Install OBS Studio
sudo apt install obs-studio

