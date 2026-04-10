#!/bin/bash
# Auto-detect dock and configure monitors.
# Called by udev rule on display hotplug or manually via i3 keybind.
#
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

if has_output "DP-1-1" && has_output "DP-1-2"; then
    # --- Dock: P3421W ultrawide (DP-1-2, primary) + P2422HE vertical (DP-1-1, right) + laptop (below) ---
    xrandr --output HDMI-1 --off --output DP-1-3 --off
    xrandr --output DP-1-2 --mode 3440x1440 --pos 0x199 --rotate normal --primary
    xrandr --output DP-1-1 --mode 1920x1080 --rotate left --pos 3440x0
    xrandr --output DSI-1 --mode 800x1280 --rotate left --pos 997x1639
    notify-send "Display" "Dock: P3421W ultrawide + P2422HE vertical" 2>/dev/null

else
    # --- Undocked: Laptop only ---
    xrandr --output DP-1-1 --off
    xrandr --output DP-1-2 --off
    xrandr --output DP-1-3 --off
    xrandr --output HDMI-1 --off
    xrandr --output DSI-1 --mode 800x1280 --rotate right --pos 0x0 --primary
    notify-send "Display" "Undocked: Laptop only" 2>/dev/null
fi

# Restore wallpaper after display change
nitrogen --restore 2>/dev/null &

# Restart polybar (centralized in launch.sh, which also restarts tray applets)
~/.config/polybar/launch.sh &disown
