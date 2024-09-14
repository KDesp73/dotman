#!/usr/bin/bash

source "$BASE_DIR"/lib/logging.sh
source "$BASE_DIR"/lib/files.sh
source "$BASE_DIR"/lib/utils.sh

declare -A links

# Creates a symlink
# link <src> <dest>
link(){
    local src=$1
    local dest=$2
    local file="$dest/$src"

    if [ -e "$file" ]; then
        if ! read_yes_no "File $file already exists. Remove and link?"; then
            return 1
        fi
        rm -rf "$file"
    fi

    ln -s "$BASE_DIR/$src" "$file"
    return 0
}

linker() {
    local -n hashmap=$1

    local rc=0
    for key in "${!hashmap[@]}"; do
        color green "Linking $key..."

        if ! file_exists "$key" ; then
            ERRO "No such file or directory: $key" 
            rc=1
            continue
        fi

        if ! link "$key" "${hashmap[$key]}"; then
            ERRO "Failed linking to ${hashmap[$key]}/$key"
            rc=1
        fi
    done
    return $rc
}

remove_links() {
    if ! read_yes_no "[WARN] This will remove all symlinks. Are you sure you want to continue?" ; then
        return 1
    fi

    local -n hashmap=$1
    local prefix=$2

    local rc=0
    for key in "${!hashmap[@]}"; do
        color red "Removing link $key..."

        if ! file_exists "$prefix$key" ; then
            ERRO "File '$prefix$key' does not exist" 
            rc=1
            continue
        fi

        rm "${hashmap[$key]}"
    done
    return $rc
}
