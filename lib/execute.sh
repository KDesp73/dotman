#!/usr/bin/env bash

source "$BASE_DIR"/lib/ansi.sh
source "$BASE_DIR"/lib/config.sh

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
    echoi "run          Start the setup process"
    echo ""

    echob "OPTIONS"
    echoi "--help       Prints this message"
    echoi "--version    Prints the framework's version"
    echo ""

    echo "Made by KDesp73 (Konstantinos Despoinidis)"
}

execute() {
    local run=$1
    shift # Shift to remove the first argument (the function to run)

    while [[ $# -gt 0 ]]; do
        key="$1"
        case $key in
            --help)
                help
                shift
                ;;
            --version)
                version
                shift
                ;;
            run)
                $run "$@" # Pass all remaining arguments to the function
                shift
                ;;
            *)
                ERRO "Expected command or flag. Try 'dotman.sh --help'"
                exit 1
                ;;
        esac
        shift
    done
}
