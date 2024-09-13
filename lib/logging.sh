#!/usr/bin/env bash

LOG () {
    echo "[$1] $2"
}
INFO () {
    LOG "INFO" "$1"
}
ERRO () {
    LOG "ERRO" "$1"
}
WARN () {
    LOG "WARN" "$1"
}
DEBU () {
    LOG "DEBU" "$1"
}

echo_installed() {
    INFO "$1 installed successfully"
}

echo_failed() {
    ERRO "Failed to install $1"
}

echo_already_installed() {
    INFO "$1 is already installed"
}
