#!/usr/bin/env bash

# Usage: bash <(curl -s https://raw.githubusercontent.com/KDesp73/dotman/main/scripts/install.sh)

set -euo pipefail

REPO_URL="https://github.com/KDesp73/dotman"
TMP_DIR="$(mktemp -d)"
BINARY_NAME="dotman"

echo "[*] Cloning repo..."
git clone --depth=1 "$REPO_URL" "$TMP_DIR"

echo "[*] Building..."
cd "$TMP_DIR"
zig build

echo "[*] Copying binary to $(pwd -P)/.."
cp "./zig-out/bin/$BINARY_NAME" "$OLDPWD/$BINARY_NAME"

echo "[*] Cleaning up..."
rm -rf "$TMP_DIR"

echo "[✓] Installed '$BINARY_NAME' to $(realpath "$OLDPWD/$BINARY_NAME")"
