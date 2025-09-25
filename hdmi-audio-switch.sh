#!/bin/bash

set -euo pipefail

CARD_NAME="alsa_card.pci-0000_00_1f.3"
ANALOG_PROFILE="output:analog-stereo+input:analog-stereo"
HDMI_PROFILE="output:hdmi-stereo"
DRM_CARD="card1"  # X280 uses card1 for HDMI

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" >&2
}

log "Waiting for PipeWire..."
while ! pactl info &>/dev/null; do
    sleep 0.5
done

any_hdmi_connected() {
    local drm_path="/sys/class/drm"
    for port in "$drm_path"/${DRM_CARD}-HDMI-A-*; do
        [[ ! -e "$port" ]] && continue
        if [[ -f "$port/status" ]]; then
            local status
            status=$(cat "$port/status" 2>/dev/null | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')
            if [[ "$status" == "connected" ]]; then
                log "HDMI port $(basename "$port") is connected"
                return 0
            fi
        fi
    done
    return 1
}

apply_profile() {
    if any_hdmi_connected; then
        log "Switching to HDMI audio profile: $HDMI_PROFILE"
        if pactl set-card-profile "$CARD_NAME" "$HDMI_PROFILE" 2>/dev/null; then
            log "Successfully switched to HDMI audio."
        else
            log "WARNING: HDMI profile not available."
        fi
    else
        log "Switching to analog audio profile: $ANALOG_PROFILE"
        if pactl set-card-profile "$CARD_NAME" "$ANALOG_PROFILE" 2>/dev/null; then
            log "Successfully switched to analog audio."
        else
            log "WARNING: Analog profile not available."
        fi
    fi
}

log "Applying initial audio profile..."
apply_profile

log "Starting udev monitor for HDMI hotplug..."
udevadm monitor --udev -s drm | while read -r line; do
    if [[ "$line" == *"$DRM_CARD"* ]]; then
        log "DRM event detected for $DRM_CARD. Re-evaluating HDMI state..."
        sleep 0.5
        apply_profile
    fi
done
