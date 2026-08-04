#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ISO_DIR="$ROOT_DIR/iso"
ISO_PATH="$ISO_DIR/tails-amd64-7.10.iso"
URL="https://download.tails.net/tails/stable/tails-amd64-7.10/tails-amd64-7.10.iso"

mkdir -p "$ISO_DIR"

if [ -f "$ISO_PATH" ]; then
  echo "ISO already exists at $ISO_PATH"
  exit 0
fi

wget -O "$ISO_PATH" "$URL"
echo "Downloaded Tails ISO to $ISO_PATH"
