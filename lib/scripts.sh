#!/usr/bin/env bash

source "$BASE_DIR"/lib/logging.sh
source "$BASE_DIR"/lib/ansi.sh

run_scripts() {
    local -n list=$1

    for script in "${list[@]}"; do
        color magenta "$script..."
        if ! bash "$script" ; then
            ERRO "'$script' failed"
            return 1
        fi
    done

    return 0
}
