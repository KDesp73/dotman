#!/usr/bin/env bash

# bash <(curl -s https://raw.githubusercontent.com/KDesp73/dotman/main/scripts/install.sh)

git clone https://github.com/KDesp73/dotman --depth=1
cd dotman || exit 1
zig build
mv ./zig-out/bin/dotman ../temp.dotman
rm -rf dotman
mv temp.dotman dotman
