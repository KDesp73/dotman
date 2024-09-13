#!/usr/bin/env bash

delete() {
    local -n files=$1

    for file in "${files[@]}"; do
        rm -rf "./dotman/$file"
    done
}

to_remove=(
    "get.sh"
    "README.md"
    ".changelog"
    "CHANGELOG.md"
    "todo.txt"
    ".gitignore"
    ".git"
)

git clone --depth=1 https://github.com/KDesp73/dotman
delete to_remove
mv ./dotman/* .
mv ./LICENSE ./lib
rm -rf dotman
