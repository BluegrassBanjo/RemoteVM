#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ISO_DIR="$ROOT_DIR/iso"

# the iso picker
echo "OS options:"
echo "Tails Lunix 7.10: 1" # https://mirrors.edge.kernel.org/tails/stable/tails-amd64-7.10.1/tails-amd64-7.10.1.iso
echo "Ubuntu 24.04: 2 !!!BROKEN!!!" # https://releases.ubuntu.com/26.04/ubuntu-26.04-desktop-amd64.iso
echo "Void Linux: 3" # https://repo-default.voidlinux.org/live/current/void-live-x86_64-20250202-base.iso
echo "Hannah Montana Linux: 4 !!!BROKEN!!!" # https://sourceforge.net/settings/mirror_choices?projectname=hannah-montana-linux-v26&filename=v26.1.1/hannah-montana-linux-26-1-1.iso&selected=ixpeering
echo "Lubuntu Linux: 5" # https://cdimage.ubuntu.com/lubuntu/releases/26.04/release/lubuntu-26.04-desktop-amd64.iso
echo "Windows 11: 6 !!!BROKEN!!!" # if you find one then put it here plz
read -p "What OS would you like: " name

case $name in
    1)
        URL="https://mirrors.edge.kernel.org/tails/stable/tails-amd64-7.10.1/tails-amd64-7.10.1.iso"
        OSNAME="tails-amd64-7.10.iso"
        ;;
    2)
        URL="https://releases.ubuntu.com/26.04/ubuntu-26.04-desktop-amd64.iso"
        OSNAME="ubuntu-26.04-desktop-amd64.iso" # it gives a SIGTERM while booting :(
        ;;
    3)
        URL="https://repo-default.voidlinux.org/live/current/void-live-x86_64-20250202-base.iso"
        OSNAME="void-live-x86_64-20250202-base.iso"
        ;;
    4)
        URL="https://sourceforge.net/settings/mirror_choices?projectname=hannah-montana-linux-v26&filename=v26.1.1/hannah-montana-linux-26-1-1.iso&selected=ixpeering"
        OSNAME="hannah-montana-linux-26-1-1.iso" # the download link is bad, its just here because im too lazy to change it
        ;;
    5)
        URL="https://cdimage.ubuntu.com/lubuntu/releases/26.04/release/lubuntu-26.04-desktop-amd64.iso"
        OSNAME="lubuntu-26.04-desktop-amd64.iso"
        ;;
    6)
        URL="PLACEHOLDER"
        OSNAME="PLACEHOLDER" # microslop decieded to make the download link change
        echo "Win11 is broken rn"
        exit 1
        ;;
    *)
        echo "Incorrect number"
        exit 1
        ;;
esac

ISO_PATH="$ISO_DIR/$OSNAME"
mkdir -p "$ISO_DIR"

if [ -f "$ISO_PATH" ]; then
  echo "ISO already exists at $ISO_PATH"
  exit 0
fi

wget -O "$ISO_PATH" "$URL"
echo "Downloaded ISO to $ISO_PATH"
echo "Installing required packages"

# some random packages that are needed for running vm
sudo apt update && sudo apt install -y qemu-utils && sudo apt install -f websockify && sudo apt install -y qemu-system-x86 && sudo apt install -y novnc
mkdir -p "$ISO_DIR" "$ROOT_DIR/images"
qemu-img create -f qcow2 /workspaces/RemoteVM/images/disk.qcow2 30G # creates the virt disk