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
    "LICENSE"
    ".changelog"
    "CHANGELOG.md"
    ".gitignore"
    ".git"
)

git clone --depth=1 https://github.com/KDesp73/dotman
delete to_remove
mv ./dotman/* .
rm -rf dotman
