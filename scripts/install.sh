#!/usr/bin/env bash

# Usage: bash <(curl -s https://raw.githubusercontent.com/KDesp73/dotman/main/scripts/install.sh)

set -euo pipefail

REPO_URL="https://github.com/KDesp73/dotman"
TEMP_DIR="$(mktemp -d)"
INSTALL_NAME="dotman"

echo "[*] Cloning repository..."
git clone --depth=1 "$REPO_URL" "$TEMP_DIR"

echo "[*] Building with Zig..."
cd "$TEMP_DIR"
zig build

echo "[*] Moving binary to current directory..."
mv ./zig-out/bin/"$INSTALL_NAME" "../.$INSTALL_NAME.tmp"

echo "[*] Cleaning up..."
cd ..
rm -rf "$TEMP_DIR"

mv ".$INSTALL_NAME.tmp" "$INSTALL_NAME"

echo "[✓] Installed '$INSTALL_NAME' successfully."
