#!/usr/bin/bash

export BASE_DIR
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source lib/packages.sh
source lib/links.sh
source lib/scripts.sh
source lib/paths.sh

pkgs=(
    git
    make
    cmake
    vim
    # more...
)

scripts=(
    ./scripts/test.sh
    # more...
)

declare -A links
PREFIX="./dotfiles/"

links[".zshrc"]="$HOME"
links["nvim"]="$CONFIG"
# more...

run_scripts scripts
linker links $PREFIX
