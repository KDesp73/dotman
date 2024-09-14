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
            INSTALLATION_COMMAND="apt-get install -y"
            ;;
        fedora|centos|rhel)
            INSTALLATION_COMMAND="yum install -y"
            ;;
        arch)
            INSTALLATION_COMMAND="pacman -S --noconfirm"
            ;;
        manjaro)
            INSTALLATION_COMMAND="pamac install --no-confirm --no-upgrade"
            ;;
        gentoo)
            INSTALLATION_COMMAND="emerge --ask"
            ;;
        nixos)
            INSTALLATION_COMMAND="echo \"Warning:\nUsing nix-env permanently modifies a local profile of installed packages. 
                                        This must be updated and maintained by the user in the same way as with a traditional package manager, 
                                        foregoing many of the benefits that make Nix uniquely powerful.\nUsing nix-shell or a NixOS configuration is recommended instead. \"; nix-env -iA"
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
            UNINSTALLATION_COMMAND="apt-get remove -y"
            ;;
        fedora|centos|rhel)
            UNINSTALLATION_COMMAND="yum remove -y"
            ;;
        arch)
            UNINSTALLATION_COMMAND="pacman -Rs --noconfirm"
            ;;
        manjaro)
            UNINSTALLATION_COMMAND="pamac remove --no-confirm"
            ;;
        gentoo)
            UNINSTALLATION_COMMAND="emerge --unmerge --ask"
            ;;
        nixos)
            INSTALLATION_COMMAND="echo \"Warning:\nUsing nix-env permanently modifies a local profile of installed packages. 
                                        This must be updated and maintained by the user in the same way as with a traditional package manager, 
                                        foregoing many of the benefits that make Nix uniquely powerful.\nUsing nix-shell or a NixOS configuration is recommended instead. \"; nix-env --uninstall"
        *)
            UNINSTALLATION_COMMAND="unknown"
            ;;
    esac
    echo "$UNINSTALLATION_COMMAND"
}
