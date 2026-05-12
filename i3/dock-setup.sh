#!/bin/bash
# Auto-detect dock and configure monitors.
# Called by udev rule on display hotplug or manually via i3 keybind.
#
# Work: HDMI QHD above, DSI-1 laptop centered below
# Dock: P3421W ultrawide (DP-1-2, primary) + P2422HE vertical (DP-1-1, right) + DSI-1 laptop (below)
# Undocked: laptop only (DSI-1)

# Debounce: udev fires multiple DRM events per hotplug
LOCKFILE="/tmp/dock-setup.lock"
exec 9>"$LOCKFILE"
flock -n 9 || exit 0

sleep 1  # let display settle after hotplug

connected=$(xrandr | grep " connected" | awk '{print $1}')

has_output() {
    echo "$connected" | grep -q "^$1$"
}

# Work HDMI monitor EDID (2560x1440 QHD). Unique fingerprint — matches only this display.
WORK_HDMI_EDID="bddd7ca3f93d7033383570f3e2231d92"
hdmi_edid=$(md5sum /sys/class/drm/card*-HDMI-A-1/edid 2>/dev/null | awk '{print $1}' | head -1)

if has_output "HDMI-1" && [ "$hdmi_edid" = "$WORK_HDMI_EDID" ] && ! has_output "DP-1-1" && ! has_output "DP-1-2"; then
    # --- Work: HDMI QHD above (centered), laptop (rotated right) below ---
    # HDMI 2560 wide, DSI 1280 wide → DSI x-offset = (2560-1280)/2 = 640 to center under HDMI.
    xrandr --output DP-1-1 --off --output DP-1-2 --off --output DP-1-3 --off
    xrandr --output HDMI-1 --mode 2560x1440 --pos 0x0 --rotate normal
    xrandr --output DSI-1 --mode 800x1280 --rotate right --pos 640x1440 --primary
    theme=work
    notify-send "Display" "Work: HDMI QHD above + laptop centered below (Win11 theme)" 2>/dev/null

elif has_output "DP-1-1" && has_output "DP-1-2"; then
    # --- Dock: P3421W ultrawide (DP-1-2, primary) + P2422HE vertical (DP-1-1, right) + laptop (below) ---
    xrandr --output HDMI-1 --off --output DP-1-3 --off
    xrandr --output DP-1-2 --mode 3440x1440 --pos 0x199 --rotate normal --primary
    xrandr --output DP-1-1 --mode 1920x1080 --rotate left --pos 3440x0
    xrandr --output DSI-1 --mode 800x1280 --rotate left --pos 997x1639
    theme=home
    notify-send "Display" "Dock: P3421W ultrawide + P2422HE vertical" 2>/dev/null

else
    # --- Undocked: Laptop only ---
    xrandr --output DP-1-1 --off
    xrandr --output DP-1-2 --off
    xrandr --output DP-1-3 --off
    xrandr --output HDMI-1 --off
    xrandr --output DSI-1 --mode 800x1280 --rotate right --pos 0x0 --primary
    theme=home
    notify-send "Display" "Undocked: Laptop only" 2>/dev/null
fi

# Apply theme (wallpaper + polybar + alacritty) — also restarts polybar
~/dotfiles/themes/apply-theme.sh "$theme" &disown
