#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RUNTIME_DIR="$ROOT_DIR/.run"
failed=0

process_matches() {
  local pid="$1"
  local expected="$2"
  local command_line

  kill -0 "$pid" 2>/dev/null || return 1
  command_line="$(ps -p "$pid" -o args= 2>/dev/null || true)"
  [[ "$command_line" == *"$expected"* ]]
}

stop_service() {
  local pid_file="$1"
  local label="$2"
  local expected="$3"

  if [ ! -f "$pid_file" ]; then
    return 0
  fi

  local pid
  pid="$(cat "$pid_file")"
  if ! [[ "$pid" =~ ^[0-9]+$ ]]; then
    echo "Invalid PID in $pid_file; leaving it in place." >&2
    return 1
  fi

  if ! kill -0 "$pid" 2>/dev/null; then
    echo "$label is not running; removing stale PID file."
    rm -f "$pid_file"
    return 0
  fi

  if ! process_matches "$pid" "$expected"; then
    echo "PID $pid does not appear to be $label; leaving $pid_file in place." >&2
    return 1
  fi

  kill -TERM "$pid"
  for _ in {1..10}; do
    if ! process_matches "$pid" "$expected"; then
      rm -f "$pid_file"
      echo "Stopped $label with PID $pid"
      return 0
    fi
    sleep 1
  done

  echo "$label with PID $pid did not stop after SIGTERM; leaving $pid_file in place." >&2
  return 1
}

stop_service "$RUNTIME_DIR/novnc.pid" "noVNC" "websockify" || failed=1
stop_service "$RUNTIME_DIR/x11vnc.pid" "x11vnc" "x11vnc" || failed=1
stop_service "$RUNTIME_DIR/blackbox.pid" "Blackbox" "blackbox" || failed=1
stop_service "$RUNTIME_DIR/xvfb.pid" "Xvfb" "Xvfb" || failed=1

exit "$failed"
