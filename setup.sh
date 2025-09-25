#!/bin/bash

SCRIPT_NAME="hdmi-audio-switch.sh"
SERVICE_NAME="hdmi-audio-switcher.service"

BIN_DIR="$HOME/.local/bin"
SYSTEMD_USER_DIR="$HOME/.config/systemd/user"

if [[ ! -f "$SCRIPT_NAME" ]] || [[ ! -f "$SERVICE_NAME" ]]; then
    echo "you are not in same directory as the sh file and the .service file, get it together." >&2
    exit 1
fi

mkdir -p "$BIN_DIR"
mkdir -p "$SYSTEMD_USER_DIR"
install -m 755 "$SCRIPT_NAME" "$BIN_DIR/"
install -m 644 "$SERVICE_NAME" "$SYSTEMD_USER_DIR/"
systemctl --user daemon-reload
systemctl --user enable --now "$SERVICE_NAME"

echo "hdmi passthrough should now work, test it!"
