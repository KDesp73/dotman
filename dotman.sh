#!/usr/bin/bash

export BASE_DIR
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source lib/packages.sh

pkgs=(
    git
    make
    cmake
    vim
    # more...
)

install_packages pkgs

