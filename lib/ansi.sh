#!/usr/bin/env bash


RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
RESET='\033[0m'

# Color function
color() {
    local color=$1
    local message=$2

    case $color in
        red)
            echo -e "${RED}$message${RESET}"
            ;;
        green)
            echo -e "${GREEN}$message${RESET}"
            ;;
        yellow)
            echo -e "${YELLOW}$message${RESET}"
            ;;
        blue)
            echo -e "${BLUE}$message${RESET}"
            ;;
        magenta)
            echo -e "${MAGENTA}$message${RESET}"
            ;;
        cyan)
            echo -e "${CYAN}$message${RESET}"
            ;;
        *)
            echo -e "$message"
            ;;
    esac
}
