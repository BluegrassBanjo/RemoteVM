#!/usr/bin/env bash
set -euo pipefail

ISO="OS.iso"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ISO_DIR="$ROOT_DIR/iso"
ISO_PATH="$ISO_DIR/$ISO"
IMAGE_PATH="$ROOT_DIR/images/tails.qcow2"
LOG_PATH="$ROOT_DIR/images/tails-vm.log"
PID_PATH="$ROOT_DIR/images/tails-vm.pid"
NOVNC_PID_PATH="$ROOT_DIR/images/novnc.pid"
NOVNC_LOG_PATH="$ROOT_DIR/images/novnc.log"
NOVNC_PORT="6080"
VNC_HOST="127.0.0.1"
VNC_PORT="5900"

ensure_kvm_access() {
  if [ -e /dev/kvm ]; then
    if [ ! -w /dev/kvm ]; then
      echo "Adjusting permissions for /dev/kvm"
      sudo chmod 666 /dev/kvm 2>/dev/null || true
      sudo chown root:codespace /dev/kvm 2>/dev/null || true
    fi
    if [ -w /dev/kvm ]; then
      return 0
    fi
  fi
  return 1
}

if [ ! -f "$ISO_PATH" ]; then
  echo "Tails ISO not found at $ISO_PATH" >&2
  echo "Run ./iso_download.sh first." >&2
  exit 1
fi

if [ ! -f "$IMAGE_PATH" ]; then
  echo "Creating virtual disk at $IMAGE_PATH"
  qemu-img create -f qcow2 "$IMAGE_PATH" 30G
fi

ACCEL="tcg"
CPU_FLAG="max"
if ensure_kvm_access; then
  ACCEL="kvm"
  CPU_FLAG="host"
fi

if [ -f "$PID_PATH" ]; then
  OLD_PID="$(cat "$PID_PATH")"
  if [ -n "$OLD_PID" ] && kill -0 "$OLD_PID" 2>/dev/null; then
    echo "A Tails VM is already running with PID $OLD_PID"
    if [ -f "$NOVNC_PID_PATH" ]; then
      NOVNC_PID="$(cat "$NOVNC_PID_PATH")"
      if [ -n "$NOVNC_PID" ] && kill -0 "$NOVNC_PID" 2>/dev/null; then
        echo "noVNC is already running on http://$VNC_HOST:$NOVNC_PORT/vnc.html"
      fi
    fi
    exit 0
  fi
  rm -f "$PID_PATH"
fi

CMD=(
  qemu-system-x86_64
  -machine type=q35,accel="$ACCEL"
  -cpu "$CPU_FLAG"
  -m 4096
  -smp 2
  -cdrom "$ISO_PATH"
  -drive file="$IMAGE_PATH",format=qcow2,if=virtio
  -boot order=d
  -display none
  -vnc "$VNC_HOST:0"
  -serial mon:stdio
  -monitor none
)

nohup "${CMD[@]}" >"$LOG_PATH" 2>&1 &
echo $! > "$PID_PATH"

if ! command -v websockify >/dev/null 2>&1; then
  echo "websockify is not installed" >&2
  exit 1
fi

if [ -f "$NOVNC_PID_PATH" ]; then
  NOVNC_PID="$(cat "$NOVNC_PID_PATH")"
  if [ -n "$NOVNC_PID" ] && kill -0 "$NOVNC_PID" 2>/dev/null; then
    echo "noVNC already running on http://$VNC_HOST:$NOVNC_PORT/vnc.html"
    exit 0
  fi
  rm -f "$NOVNC_PID_PATH"
fi

nohup websockify --web /usr/share/novnc "$NOVNC_PORT" "$VNC_HOST:$VNC_PORT" >"$NOVNC_LOG_PATH" 2>&1 &
echo $! > "$NOVNC_PID_PATH"

echo "Started Tails VM with PID $(cat "$PID_PATH")"
echo "noVNC available at http://$VNC_HOST:$NOVNC_PORT/vnc.html"
echo "Logs: $LOG_PATH"
echo "noVNC log: $NOVNC_LOG_PATH"
