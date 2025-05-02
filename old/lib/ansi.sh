#!/usr/bin/env bash


RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
RESET='\033[0m'

BOLD='\033[1m'
UNDERLINE='\033[4m'
BLINK='\033[5m'
REVERSE='\033[7m'

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
            echo -e "$color"
            ;;
    esac
}

style(){
    local style=$1
    local message=$2

    case $style in
        bold)
            echo -e "${BOLD}$message${RESET}"
            ;;
        underline)
            echo -e "${UNDERLINE}$message${RESET}"
            ;;
        blink)
            echo -e "${BLINK}$message${RESET}"
            ;;
        reverse)
            echo -e "${REVERSE}$message${RESET}"
            ;;
        *)
            echo -e "$style"
            ;;
    esac
}
