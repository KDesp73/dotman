#!/usr/bin/bash

source "$BASE_DIR"/lib/system.sh
source "$BASE_DIR"/lib/logging.sh
source "$BASE_DIR"/lib/utils.sh

install_package() {
    local distro
    local installation_command
    distro=$(get_distro)
    installation_command=$(get_installation_command "$distro")

    color blue "$installation_command $1"

    local rc=0
    if ! command -v "$1"> /dev/null 2>&1; then
        $installation_command "$1"
        command ...
    else 
        rc=1
    fi
    return $rc
}

uninstall_package() {
    local distro
    local uninstallation_command
    distro=$(get_distro)
    uninstallation_command=$(get_uninstallation_command "$distro")

    color yellow "$uninstallation_command $1"

    local rc=0
    if ! command -v "$1"> /dev/null 2>&1; then
        rc=1
    else 
        $uninstallation_command "$1"
    fi
    return $rc
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

    local rc=0
    for pkg in "${list[@]}"; do
        if ! install_package "$pkg" ; then
            ERRO "Failed installing $pkg"
            rc=1
        fi
    done
    return $rc
}

uninstall_packages() {
    if ! read_yes_no "[WARN] This will remove all specified packages. Are you sure you want to continue?" ; then
        return 1
    fi

    local -n list=$1

    local rc=0
    for pkg in "${list[@]}"; do
        if ! uninstall_package "$pkg" ; then
            ERRO "Failed uninstalling $pkg"
            rc=1
        fi
    done
    return $rc
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
