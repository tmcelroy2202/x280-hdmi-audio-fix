# HDMI Audio Auto-Switcher for Lenovo X280 (and similar Intel laptops)

This tool automatically switches your audio output between laptop speakers and HDMI when you plug in or unplug an HDMI cable

It's designed for my lenovo thinkpad x280 where:
- HDMI ports are exposed on card1 (not card0)
- The Intel audio controller is alsa_card.pci-0000_00_1f.3
- HDMI audio requires switching PipeWire/PulseAudio profiles

## Installation

Open up a terminal and paste in these commands: 

```bash
git clone https://github.com/tmcelroy2202/x280-hdmi-audio-fix.git
cd x280-hdmi-audio-fix
chmod +x install.sh
./install.sh
```

This will:
- Copy the script to ~/.local/bin/
- Install the systemd user service
- Enable and start the service automatically

everything runs under your user account, so it does not need root.

- When HDMI is plugged in → switches to `output:hdmi-stereo` profile  
  (enables PCM and passthrough audio over HDMI)
- When HDMI is unplugged → switches back to `output:analog-stereo+input:analog-stereo`  
  (restores laptop speakers and microphone)

The switch happens immediately upon cable detection via `udev`.

## Debugging

See real-time logs:
```bash
journalctl --user -u hdmi-audio-switcher.service -f
```

Manually check HDMI status:
```bash
cat /sys/class/drm/card1-HDMI-A-*/status
```

List available audio profiles:
```bash
pactl list cards | grep -A30 "Profiles:"
```

if you have a problem please include all of these in the github issue you make

---

## Uninstall

To remove:

```bash
systemctl --user disable --now hdmi-audio-switcher.service
rm -f ~/.local/bin/hdmi-audio-switch.sh
rm -f ~/.config/systemd/user/hdmi-audio-switcher.service
systemctl --user daemon-reload
```


## Notes

- Works with PipeWire + WirePlumber
- Tested on Lenovo ThinkPad X280 with Intel UHD Graphics 620
- may work on other laptops — adjust 'DRM_CARD' and 'CARD_NAME' in the script if needed

