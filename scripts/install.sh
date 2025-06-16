#!/usr/bin/env bash

# Usage: bash <(curl -s https://raw.githubusercontent.com/KDesp73/dotman/main/scripts/install.sh)

set -euo pipefail

REPO_URL="https://github.com/KDesp73/dotman"
TEMP_DIR="$(mktemp -d)"
BINARY_NAME="dotman"

echo "[*] Cloning dotman repo into temporary directory..."
git clone --depth=1 "$REPO_URL" "$TEMP_DIR"

echo "[*] Building dotman with Zig..."
cd "$TEMP_DIR"
zig build

echo "[*] Moving compiled binary to current directory..."
cp "./zig-out/bin/$BINARY_NAME" "$OLDPWD/$BINARY_NAME"

echo "[*] Cleaning up temporary directory..."
cd "$OLDPWD"
rm -rf "$TEMP_DIR"

echo "[✓] Installed '$BINARY_NAME' to $(pwd)/$BINARY_NAME"
