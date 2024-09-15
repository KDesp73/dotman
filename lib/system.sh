#!/usr/bin/env bash


source "$BASE_DIR"/lib/ansi.sh

get_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        distro=$ID
    elif type lsb_release >/dev/null 2>&1; then
        distro=$(lsb_release -i -s)
    elif [ -f /etc/debian_version ]; then
        distro=debian
    elif [ -f /etc/redhat-release ]; then
        distro=rhel
    elif [ -f /etc/system-release ]; then
        distro=$(awk '{print $1}' /etc/system-release)
    else
        distro=unknown
    fi
    echo "$distro"
}

get_installation_command() {
    local distro=$1
    local installation_command=""
    case $distro in
        ubuntu|debian|linuxmint)
            installation_command="sudo apt-get install -y"
            ;;
        fedora|centos|rhel)
            installation_command="sudo yum install -y"
            ;;
        arch)
            installation_command="sudo pacman -S --noconfirm"
            ;;
        manjaro|ManjaroLinux)
            installation_command="pamac install --no-confirm --no-upgrade"
            ;;
        gentoo)
            installation_command="sudo emerge --ask"
            ;;
        nixos)
            installation_command="echo \"Warning:\nUsing nix-env permanently modifies a local profile of installed packages. 
                                        This must be updated and maintained by the user in the same way as with a traditional package manager, 
                                        foregoing many of the benefits that make Nix uniquely powerful.\nUsing nix-shell or a NixOS configuration is recommended instead. \"; nix-env -iA"
            ;;
        *)
            installation_command="unknown"
            ;;
    esac
    echo "$installation_command"
}

get_uninstallation_command() {
    local distro=$1
    local uninstallation_command=""
    case $distro in
        ubuntu|debian|linuxmint)
            uninstallation_command="sudo apt remove -y"
            ;;
        fedora|centos|rhel)
            uninstallation_command="sudo yum remove -y"
            ;;
        arch)
            uninstallation_command="sudo pacman -Rs --noconfirm"
            ;;
        manjaro|ManjaroLinux)
            uninstallation_command="pamac remove --no-confirm"
            ;;
        gentoo)
            uninstallation_command="sudo emerge --unmerge --ask"
            ;;
        nixos)
            uninstallation_command="echo \"Warning:\nUsing nix-env permanently modifies a local profile of installed packages. 
                                        This must be updated and maintained by the user in the same way as with a traditional package manager, 
                                        foregoing many of the benefits that make Nix uniquely powerful.\nUsing nix-shell or a NixOS configuration is recommended instead. \"; nix-env --uninstall"
            ;;
        *)
            uninstallation_command="unknown"
            ;;
    esac
    echo "$uninstallation_command"
}

