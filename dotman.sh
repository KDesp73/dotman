#!/usr/bin/bash

export BASE_DIR
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source lib/paths.sh
source lib/links.sh
source lib/execute.sh

##################################################
#                                                #  
#  [dotman.sh] - v0.0.3                          #  
#                                                #  
#        The declarative dotfiles manager        #  
#                                                #  
#                                                #  
#                               Made by KDesp73  #  
#                                                #  
##################################################

##################################################
#                                                #  
#  Structure:                                    #  
#                                                #  
#  dotfiles/                                     #  
#          |--lib/ # The library files           #  
#          |                                     #  
#          |--scripts/ # Your custom scripts     #  
#          |                                     #  
#          |--dotman.sh # The entry point        #  
#          |                                     #  
#          |--<all your dotfiles>                #  
#                                                #  
##################################################

# VVV Edit below VVV

pkgs=(
    git
    make
    cmake
    vim
    # more...
)

scripts=(@)

# links[<src>]=<dest>
links[".zshrc"]="$HOME"
links["nvim"]="$CONFIG"
# more...

execute pkgs scripts links "$@"


