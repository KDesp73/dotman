#!/usr/bin/env bash


source "$BASE_DIR"/lib/ansi.sh

get_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
    elif type lsb_release >/dev/null 2>&1; then
        DISTRO=$(lsb_release -i -s)
    elif [ -f /etc/debian_version ]; then
        DISTRO=debian
    elif [ -f /etc/redhat-release ]; then
        DISTRO=rhel
    elif [ -f /etc/system-release ]; then
        DISTRO=$(awk '{print $1}' /etc/system-release)
    else
        DISTRO=unknown
    fi
    echo "$DISTRO"
}

get_installation_command() {
    local DISTRO=$1
    case $DISTRO in
        ubuntu|debian|linuxmint)
            INSTALLATION_COMMAND="sudo apt-get install -y"
            ;;
        fedora|centos|rhel)
            INSTALLATION_COMMAND="sudo yum install -y"
            ;;
        arch)
            INSTALLATION_COMMAND="sudo pacman -S --noconfirm"
            ;;
        manjaro|ManjaroLinux)
            INSTALLATION_COMMAND="pamac install --no-confirm --no-upgrade"
            ;;
        gentoo)
            INSTALLATION_COMMAND="sudo emerge --ask"
            ;;
        *)
            INSTALLATION_COMMAND="unknown"
            ;;
    esac
    echo "$INSTALLATION_COMMAND"
}

get_uninstallation_command() {
    local DISTRO=$1
    case $DISTRO in
        ubuntu|debian|linuxmint)
            UNINSTALLATION_COMMAND="sudo apt remove -y"
            ;;
        fedora|centos|rhel)
            UNINSTALLATION_COMMAND="sudo yum remove -y"
            ;;
        arch)
            UNINSTALLATION_COMMAND="sudo pacman -Rs --noconfirm"
            ;;
        manjaro)
            UNINSTALLATION_COMMAND="pamac remove --no-confirm"
            ;;
        gentoo)
            UNINSTALLATION_COMMAND="sudo emerge --unmerge --ask"
            ;;
        *)
            UNINSTALLATION_COMMAND="unknown"
            ;;
    esac
    echo "$UNINSTALLATION_COMMAND"
}

