#!/usr/bin/bash

source "$BASE_DIR"/lib/system.sh
source "$BASE_DIR"/lib/logging.sh

install_package() {
    local distro
    local installation_command
    distro=$(get_distro)
    installation_command=$(get_installation_command "$distro")

    color blue "$installation_command $1"

    if ! command -v "$1"> /dev/null 2>&1; then
        # TODO: remove comment
        # $INSTALLATION_COMMAND "$1"
        echo_installed "$1"
    else 
        echo_already_installed "$1"
    fi
}

is_installed(){
    local pkg=$1

    if ! command -v "$pkg"> /dev/null 2>&1; then
        return 1
    else 
        return 0
    fi
}

install_packages() {
    local -n list=$1

    for pkg in "${list[@]}"; do
        install_package "$pkg"
    done
}

echo_installed(){
    local -n list=$1

    for pkg in "${list[@]}"; do
        if is_installed "$pkg" ; then
            echo "$pkg"
        fi
    done
}

echo_not_installed(){
    local -n list=$1

    for pkg in "${list[@]}"; do
        if ! is_installed "$pkg" ; then
            echo "$pkg"
        fi
    done
}
