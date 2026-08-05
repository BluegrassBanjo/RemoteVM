# RemoteVM

A local QEMU-based virtual machine environment to boot Tails from a selected ISO image.

## Disclosure

Most of this project was generated with AI.

This project might not receive future updates or bug fixes.

If the project does not work, I might not repair it.

You have permission to modify, repair, or redistribute this project.

This environment uses QEMU software emulation. It does not use KVM because GitHub Codespaces does not provide KVM access.

## Files

**iso_download.sh**
Downloads the Tails ISO image and installs the required packages.

**images/tails.qcow2**
Virtual disk image for the virtual machine.

**start_tails_vm.sh**
Starts the virtual machine and the noVNC service.

**stop_tails_vm.sh**
Stops the virtual machine and closes the required services.

## Usage

Create a GitHub Codespace.

This project can run on another Linux server. GitHub Codespaces is the recommended environment.

### First Start

Run this command:

```bash
./iso_download.sh
```

This command downloads the Tails ISO image.

The ISO image is not included in this repository because GitHub limits repository files to 100 MB.

### Start the Virtual Machine

Run this command:

```bash
./start_tails_vm.sh
```

This script starts the virtual machine.

It also starts a noVNC server on port **6080**.

The QEMU VNC server uses port **5900**.

If port **5900** is active, the virtual machine is running.

### Stop the Virtual Machine

Run this command:

```bash
./stop_tails_vm.sh
```

**WARNING:** Do not power off the virtual machine without running this script.

If you power off the virtual machine directly, GitHub Codespaces can continue to report the session as active.

Run `./stop_tails_vm.sh` to close the services correctly.

If you do not stop the services, the Codespace can continue to use your available usage time until the tunnel closes or the Codespace stops.

## System Information

The project uses two programs.

**QEMU**

* Runs the virtual machine.
* Uses port **5900**.

**noVNC**

* Provides browser access to the virtual machine.
* Uses port **6080**.
* Connects to the QEMU VNC server on port **5900**.

## Change the ISO Image

start_tails_vm.sh will request the name of the iso you wish to use.

(you can upload your own into the iso dir and refference that if you want)

You can modify this project as required.
