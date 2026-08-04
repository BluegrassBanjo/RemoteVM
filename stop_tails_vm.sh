#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PID_FILE="$ROOT_DIR/images/tails-vm.pid"
NOVNC_PID_FILE="$ROOT_DIR/images/novnc.pid"

stop_pid_file() {
  local pid_file="$1"
  local label="$2"

  if [ -f "$pid_file" ]; then
    PID="$(cat "$pid_file")"
    if [ -n "$PID" ] && kill -0 "$PID" 2>/dev/null; then
      kill "$PID"
      echo "Stopped $label with PID $PID"
    else
      echo "No running $label found for PID $PID"
    fi
    rm -f "$pid_file"
  fi
}

stop_pid_file "$PID_FILE" "Tails VM"
stop_pid_file "$NOVNC_PID_FILE" "noVNC"
