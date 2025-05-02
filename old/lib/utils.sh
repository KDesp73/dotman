#!/usr/bin/env bash

read_yes_no() {
    local message=$1
    local response

    while true; do
        read -rp "$message [y/n]: " response
        case $response in
            [yY])
                return 0
                ;;
            [nN])
                return 1
                ;;
            *)
                echo "Invalid response. Please enter 'y' or 'n'."
                ;;
        esac
    done
}

