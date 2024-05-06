#!/bin/bash

set -e

apt_get_update() {
    if [ "$(find /var/lib/apt/lists/* | wc -l)" = "0" ]; then
        echo "Running apt-get update..."
        apt-get update -y
    fi
}

# Checks if packages are installed and installs them if not
check_packages() {
    if ! dpkg -s "$@" > /dev/null 2>&1; then
        apt_get_update
        apt-get -y install --no-install-recommends "$@"
    fi
}

apt_get_cleanup() {
    rm -rf /var/lib/apt/lists/*
    rm -r /var/lib/apt/lists
}

check_packages clang clang-format clang-tidy
apt_get_cleanup
