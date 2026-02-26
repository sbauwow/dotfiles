#!/bin/bash
# Auto-detect dock setup and configure monitors.
# Called by udev rule on display hotplug or manually via i3 keybind.
#
# Dock 1 (ultrawide): DP-1-1 (3440x1440) + DP-1-3 vertical (1920x1080 rotated right)
# Dock 2 (dual 1080p): DP-1-2 (1920x1080) + DP-1-3 vertical (1920x1080 rotated left)
# HDMI (4K vertical): HDMI-1 (3840x2160 rotated right) + DSI-1 laptop
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

if has_output "DP-1-1" && has_output "HDMI-1"; then
    # --- Dock 1 + HDMI: Ultrawide + 4K vertical ---
    xrandr --output DP-1-2 --off
    xrandr --output HDMI-1 --mode 3840x2160 --rotate right --pos 0x0
    xrandr --output DP-1-1 --mode 3440x1440 --pos 2160x0 --primary
    xrandr --output DP-1-3 --mode 1920x1080 --rotate right --pos 5600x0
    xrandr --output DSI-1 --mode 800x1280 --rotate right --pos 2160x1440
    notify-send "Display" "Dock 1 + HDMI: Ultrawide + 4K vertical" 2>/dev/null

elif has_output "DP-1-1"; then
    # --- Dock 1: Ultrawide ---
    # DP-1-3 vertical (left) | DP-1-1 ultrawide (center) | DSI-1 laptop (below center-right)
    xrandr --output HDMI-1 --off --output DP-1-2 --off
    xrandr --output DP-1-1 --mode 3440x1440 --pos 1080x0 --primary
    xrandr --output DP-1-3 --mode 1920x1080 --rotate right --pos 0x0
    xrandr --output DSI-1 --mode 800x1280 --rotate right --pos 1080x1440
    notify-send "Display" "Dock 1: Ultrawide setup" 2>/dev/null

elif has_output "DP-1-2"; then
    # --- Dock 2: Dual 1080p ---
    # DSI-1 laptop (left) | DP-1-2 horizontal (center) | DP-1-3 vertical (right)
    xrandr --output HDMI-1 --off --output DP-1-1 --off
    xrandr --output DP-1-2 --mode 1920x1080 --pos 1280x547 --primary
    xrandr --output DP-1-3 --mode 1920x1080 --rotate left --pos 3200x0
    xrandr --output DSI-1 --mode 800x1280 --rotate right --pos 0x755
    notify-send "Display" "Dock 2: Dual 1080p setup" 2>/dev/null

elif has_output "HDMI-1"; then
    # --- HDMI only: 4K vertical + laptop ---
    # HDMI-1 vertical (left) | DSI-1 laptop (right)
    xrandr --output DP-1-1 --off --output DP-1-2 --off --output DP-1-3 --off
    xrandr --output HDMI-1 --mode 3840x2160 --rotate right --pos 0x0 --primary
    xrandr --output DSI-1 --mode 800x1280 --rotate right --pos 2160x0
    notify-send "Display" "HDMI: 4K vertical + laptop" 2>/dev/null

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
