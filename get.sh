#!/usr/bin/env bash

delete() {
    local -n files=$1

    for file in "${files[@]}"; do
        rm -r "./dotman/$file"
    done
}

to_remove=(
    get.sh
    README.md
    CHANGELOG.md
    .gitignore
    .git
    dotman
)

git clone --depth=1 https://github.com/KDesp73/dotman
delete to_remove
