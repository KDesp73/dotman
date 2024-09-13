#!/usr/bin/bash

source "$BASE_DIR"/lib/logging.sh
source "$BASE_DIR"/lib/files.sh

declare -A links

# Creates a symlink
# link <src> <dest>
link(){
    local src=$1
    local dest=$2

    if [ -e "$dest"/"$src" ]; then
        return 1
    fi

    ln -s "$SCRIPT_DIR/$src" "$dest"/"$src"
    return 0
}

linker() {
    local -n hashmap=$1
    local prefix=$2

    for key in "${!hashmap[@]}"; do
        color green "Linking $key..."

        if ! file_exists "$prefix$key" ; then
            ERRO "File '$prefix$key' does not exist" 
            return 1
        fi

        if ! link "$prefix"/"$key" "${hashmap[$key]}"; then
            ERRO "Link for ${hashmap[$key]}/$key already exists"
            return 1
        fi
    done
    return 0
}
