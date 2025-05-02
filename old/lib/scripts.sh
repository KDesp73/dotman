#!/usr/bin/env bash

source "$BASE_DIR"/lib/logging.sh
source "$BASE_DIR"/lib/ansi.sh

run_all(){
    local dir="$1"
    if [ -d "$dir" ]; then
        for script in "$dir"/*; do
            if [ -f "$script" ]; then
                color magenta "$script..."
                bash "$script"
            fi
        done
    else
        ERRO "$dir is not a directory"
    fi
}

run_scripts() {
    local -n list=$1

    local rc=0
    for script in "${list[@]}"; do
        if [ "$script" == "@" ]; then
            run_all "scripts"
            continue
        fi
        color magenta "$script..."
        if [ -f "$script" ]; then
            if ! bash "$script" ; then
                ERRO "'$script' failed"
                rc=1
            fi
        fi
    done

    return $rc
}
