#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ISO_DIR="$ROOT_DIR/iso"
ISO_PATH="$ISO_DIR/OS.iso"

# the iso picker
echo "OS options:"
echo "Tails Lunix 7.10: 1" # https://download.tails.net/tails/stable/tails-amd64-7.10/tails-amd64-7.10.iso
echo "Ubuntu 24.04: 2" # https://releases.ubuntu.com/26.04/ubuntu-26.04-desktop-amd64.iso
echo "Void Linux: 3" # https://repo-default.voidlinux.org/live/current/void-live-x86_64-20250202-base.iso
echo "Hannah Montana Linux: 4" # https://sourceforge.net/settings/mirror_choices?projectname=hannah-montana-linux-v26&filename=v26.1.1/hannah-montana-linux-26-1-1.iso&selected=ixpeering
echo "Windows 11: 5" # if you find one then put it here plz
read -p "What OS would you like: " name

case $name in
    1)
        URL="https://download.tails.net/tails/stable/tails-amd64-7.10/tails-amd64-7.10.iso"
        ;;
    2)
        URL="https://releases.ubuntu.com/26.04/ubuntu-26.04-desktop-amd64.iso"
        ;;
    3)
        URL="https://repo-default.voidlinux.org/live/current/void-live-x86_64-20250202-base.iso"
        ;;
    4)
        URL="https://sourceforge.net/settings/mirror_choices?projectname=hannah-montana-linux-v26&filename=v26.1.1/hannah-montana-linux-26-1-1.iso&selected=ixpeering"
        ;;
    *)
        echo "Incorect number (Microslop made Windows not work)"
        ;;
esac

mkdir -p "$ISO_DIR"

if [ -f "$ISO_PATH" ]; then
  echo "ISO already exists at $ISO_PATH"
  exit 0
fi

wget -O "$ISO_PATH" "$URL"
echo "Downloaded Tails ISO to $ISO_PATH"

# some random packages that are needed for running vm
sudo apt update && sudo apt install -y qemu-utils && sudo apt install -f websockify && sudo apt install qemu-system-x86 && sudo apt install novnc
mkdir -p "$ISO_DIR" "$ROOT_DIR/images"
qemu-img create -f qcow2 /workspaces/RemoteVM/images/disk.qcow2 20G # creates the virt disk