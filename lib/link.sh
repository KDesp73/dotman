#!/usr/bin/bash

source "$BASE_DIR"/lib/logging.sh

# Creates a symlink
# link <src> <dest>
link(){
    local src=$1
    local dest=$2

    if [ -e "$src/$dest" ]; then
        ERRO "$dest already exists"
    else
        ln -s "$SCRIPT_DIR/$dest" "$src/$dest"
        INFO "Linked $dest"
    fi
}

