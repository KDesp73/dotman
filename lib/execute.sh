#!/usr/bin/env bash

source "$BASE_DIR"/lib/ansi.sh
source "$BASE_DIR"/lib/config.sh
source "$BASE_DIR"/lib/packages.sh
source "$BASE_DIR"/lib/links.sh
source "$BASE_DIR"/lib/scripts.sh

echob(){
    style bold "$1"
}
echoi(){
    echo "  $1"
}

version() {
    echo "dotman v$VERSION"
}

help() {
    echob "USAGE"
    echoi "dotman.sh <command> <options>"
    echo ""

    echob "COMMANDS"
    echoi "run             Start the setup process"
    echoi "install         Only install the packages"
    echoi "scripts         Only run the scripts"
    echoi "link            Only create the symlinks"
    echoi "clean           Remove symlinks"
    echoi "cleanall        Remove everything managed by dotman"
    echoi "remove          Remove dotman from your dotfiles"
    echoi "update          Get the latest dotman version" 
    echo ""

    echob "OPTIONS"
    echoi "-h --help       Prints this message"
    echoi "-v --version    Prints the framework's version"
    echo ""

    echo "Made by KDesp73 (Konstantinos Despoinidis)"
}

remove(){
    rm -rf lib
    rm dotman.sh
}

update(){
    cp dotman.sh dotman.sh.old
    cp lib/paths.sh paths.sh.old

    remove
    bash <(curl -s https://raw.githubusercontent.com/KDesp73/dotman/main/get.sh)

    mv dotman.sh.old dotman.sh
    mv paths.sh.old lib/paths.sh
}

# Handles the commands and the flags of the cli
execute() {
    local packages=$1
    shift
    local scpts=$1
    shift
    local lks=$1
    shift

    while [[ $# -gt 0 ]]; do
        key="$1"
        case $key in
            -h|--help)
                help
                shift
                ;;
            -v|--version)
                version
                shift
                ;;
            run)
                install_packages "$packages"
                run_scripts "$scpts"
                linker "$lks"
                shift
                ;;
            install)
                install_packages "$packages"
                shift
                ;;
            link)
                linker "$lks"
                shift
                ;;
            clean)
                remove_links "$lks"
                shift
                ;;
            cleanall)
                remove_links "$lks"
                uninstall_packages "$packages"
                shift
                ;;
            scripts)
                run_scripts "$scpts"
                shift
                ;;
            update)
                update
                INFO "dotman updated"
                shift
                ;;
            remove)
                remove
                INFO "dotman removed"
                shift
                ;;
            *)
                ERRO "Invalid argument '$key'. Try 'dotman.sh --help'"
                exit 1
                ;;
        esac
        shift
    done
}
