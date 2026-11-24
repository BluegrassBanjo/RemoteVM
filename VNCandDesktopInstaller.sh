#!/usr/bin/env bash
set -euo pipefail

XSTARTUP_DIR="$HOME/.vnc"
XSTARTUP_FILE="$XSTARTUP_DIR/xstartup"
BLACKBOX_MENU_FILE="$HOME/.blackbox-menu"
BLACKBOX_RC_FILE="$HOME/.blackboxrc"

if [ "$EUID" -eq 0 ]; then
  APT_GET=(apt-get)
else
  APT_GET=(sudo apt-get)
fi

run_as_root() {
  if [ "$EUID" -eq 0 ]; then
    "$@"
  else
    sudo "$@"
  fi
}

echo "Installing desktop tools and Firefox prerequisites"
"${APT_GET[@]}" update
"${APT_GET[@]}" install -y ca-certificates curl gnupg

run_as_root install -d -m 0755 /etc/apt/keyrings
curl -fsSL https://packages.mozilla.org/apt/repo-signing-key.gpg \
  | gpg --dearmor \
  | run_as_root tee /etc/apt/keyrings/packages.mozilla.org.gpg >/dev/null
printf '%s\n' \
  'deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.gpg] https://packages.mozilla.org/apt mozilla main' \
  | run_as_root tee /etc/apt/sources.list.d/mozilla.list >/dev/null
printf '%s\n' \
  'Package: firefox*' \
  'Pin: origin packages.mozilla.org' \
  'Pin-Priority: 1000' \
  | run_as_root tee /etc/apt/preferences.d/mozilla-firefox >/dev/null

"${APT_GET[@]}" update
"${APT_GET[@]}" install -y blackbox firefox novnc websockify x11vnc xvfb \
  thunar xfce4-settings xfce4-terminal

cat >"$BLACKBOX_MENU_FILE" <<'EOF'
[begin] (Blackbox)
[exec] (Firefox) {firefox}
[exec] (Terminal) {xfce4-terminal}
[exec] (File Manager) {thunar}
[exec] (Settings) {xfce4-settings-manager}
[separator]
[restart] (Restart)
[exit] (Exit)
[end]
EOF

touch "$BLACKBOX_RC_FILE"
sed -i '/^[[:space:]]*session\.menuFile:/d' "$BLACKBOX_RC_FILE"
printf 'session.menuFile: %s\n' "$BLACKBOX_MENU_FILE" >>"$BLACKBOX_RC_FILE"

if [ ! -e "$XSTARTUP_FILE" ]; then
  install -d -m 700 "$XSTARTUP_DIR"
  cat >"$XSTARTUP_FILE" <<'EOF'
#!/usr/bin/env bash
set -e
exec blackbox
EOF
  chmod 700 "$XSTARTUP_FILE"
  echo "Created Blackbox session config at $XSTARTUP_FILE"
else
  echo "Preserving existing desktop session config at $XSTARTUP_FILE"
fi

echo "Configured the Blackbox right-click menu at $BLACKBOX_MENU_FILE"
echo "Installation complete. Run ./StartStream.sh to launch the desktop."
