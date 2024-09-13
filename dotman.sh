#!/usr/bin/bash

export BASE_DIR
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source lib/packages.sh
source lib/links.sh
source lib/scripts.sh
source lib/paths.sh
source lib/execute.sh

pkgs=(
    git
    make
    cmake
    vim
    # more...
)

scripts=(
    # ./scripts/example.sh
    # more...
)

# links[<src>]=<dest>
links[".zshrc"]="$HOME"
links["nvim"]="$CONFIG"
# more...

run () {
    install_packages pkgs
    run_scripts scripts
    linker links #<optional prefix>
}

execute run "$@"
