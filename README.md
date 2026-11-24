# RemoteVM

A lightweight Blackbox desktop streamed through noVNC in GitHub Codespaces.

## Disclosure

Most of this project was generated with AI.

This project might not receive future updates or bug fixes.

If the project does not work, I might not repair it.

You have permission to modify, repair, or redistribute this project.

The desktop runs directly in the Codespace using Xvfb; it does not launch a nested virtual machine.

## Files

**VNCandDesktopInstaller.sh**
Installs Xvfb, Blackbox, Firefox, a terminal, Thunar file manager, the XFCE settings manager, x11vnc, noVNC, and websockify. It also creates a Blackbox right-click menu for launching the apps.

**StartStream.sh**
Starts the virtual display, Blackbox, VNC server, and noVNC.

**StopStream.sh**
Gracefully stops the desktop and streaming services.

## Usage

Create a GitHub Codespace.

This project can run on another Linux server. GitHub Codespaces is the recommended environment.

### First Start 
(99% chance you wont need to do this)
Run this command:

```bash
./VNCandDesktopInstaller.sh
```

### Start the Desktop

Run this command:

```bash
./StartStream.sh
```

Open forwarded port **6080** in Codespaces to access the desktop. noVNC connects to the local VNC server on port **5900**.

### Stop the Desktop

Run this command:

```bash
./StopStream.sh
```

This sends SIGTERM to noVNC, x11vnc, Blackbox, and Xvfb and waits for each process to exit.

From there just run a normal shutdown command in the codespace terminal