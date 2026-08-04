# RemoteVM
A local QEMU-based virtual machine setup for booting Tails from the requested ISO.

## DISCLOSURE
This project was almost entirely written by AI and will probably be abandoned at some point DO NOT PLAN FOR CONSTANT UPDATES/FIXES if it breaks I may not fix it HOWEVER I give you my permission to modify/fix this whatever way you like

This environment uses QEMU software emulation because KVM access is not available inside of Github codespaces.

## Files
iso/tails-amd64-7.10.iso - downloaded Tails installation image
images/tails.qcow2 - virtual disk for the VM
start_tails_vm.sh - starts the VM
stop_tails_vm.sh - stops the VM

## Usage
Make a Github codespace (you theroreticly can run this on a different server but this is easiest)

DURING FIRST START run: iso_download.sh to download the iso which isnt included due to Githubs size limit of 100MB

To start it:

./start_tails_vm.sh

The script starts the VM and also exposes a noVNC viewer under port 6080 (To check the VM is running look for port 5900 as these are 2 systems not 1)

To stop it:

./stop_tails_vm.sh

DO NOT JUST POWER OFF THE VM if you do then Github will still think you are using it untill you turn the tunnel off by this command or you run out of codespace time