#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUNTIME_DIR="$ROOT_DIR/.run"
DISPLAY_NUM=":1"
VNC_HOST="127.0.0.1"
VNC_PORT="5900"
NOVNC_PORT="6080"
XSTARTUP_FILE="$HOME/.vnc/xstartup"

require_command() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "$1 is not installed. Run ./VNCandDesktopInstaller.sh first." >&2
    exit 1
  fi
}

for command_name in Xvfb blackbox x11vnc websockify; do
  require_command "$command_name"
done

if [ ! -f "$XSTARTUP_FILE" ]; then
  echo "Desktop session config is missing: $XSTARTUP_FILE" >&2
  echo "Run ./VNCandDesktopInstaller.sh first." >&2
  exit 1
fi

mkdir -p "$RUNTIME_DIR"

process_matches() {
  local pid="$1"
  local expected="$2"
  local command_line

  kill -0 "$pid" 2>/dev/null || return 1
  command_line="$(ps -p "$pid" -o args= 2>/dev/null || true)"
  [[ "$command_line" == *"$expected"* ]]
}

start_service() {
  local pid_file="$1"
  local log_file="$2"
  local label="$3"
  local expected="$4"
  shift 4

  if [ -f "$pid_file" ]; then
    local old_pid
    old_pid="$(cat "$pid_file")"
    if [[ "$old_pid" =~ ^[0-9]+$ ]] && process_matches "$old_pid" "$expected"; then
      echo "$label is already running with PID $old_pid"
      return
    fi
    rm -f "$pid_file"
  fi

  nohup "$@" >"$log_file" 2>&1 &
  local pid=$!
  echo "$pid" >"$pid_file"
  sleep 1

  if ! process_matches "$pid" "$expected"; then
    echo "Failed to start $label. See $log_file" >&2
    rm -f "$pid_file"
    return 1
  fi
  echo "Started $label with PID $pid"
}

start_service "$RUNTIME_DIR/xvfb.pid" "$RUNTIME_DIR/xvfb.log" "Xvfb" "Xvfb" \
  Xvfb "$DISPLAY_NUM" -screen 0 1280x800x24 -nolisten tcp -ac
start_service "$RUNTIME_DIR/blackbox.pid" "$RUNTIME_DIR/blackbox.log" "Blackbox" "blackbox" \
  env DISPLAY="$DISPLAY_NUM" bash "$XSTARTUP_FILE"
start_service "$RUNTIME_DIR/x11vnc.pid" "$RUNTIME_DIR/x11vnc.log" "x11vnc" "x11vnc" \
  x11vnc -display "$DISPLAY_NUM" -localhost -forever -nopw -rfbport "$VNC_PORT"
start_service "$RUNTIME_DIR/novnc.pid" "$RUNTIME_DIR/novnc.log" "noVNC" "websockify" \
  websockify --web /usr/share/novnc "$NOVNC_PORT" "$VNC_HOST:$VNC_PORT"

echo "Desktop available through noVNC on port $NOVNC_PORT."
echo "Open http://localhost:$NOVNC_PORT/vnc.html"
