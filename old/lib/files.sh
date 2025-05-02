#!/usr/bin/env bash

source "$BASE_DIR"/lib/logging.sh

file_exists() {
    local file=$1

    if [ -z "$file" ]; then
        ERRO "File path cannot be empty" >&2
        return 1
    fi

    if [ -e "$file" ]; then
        return 0
    else
        return 1
    fi
}
