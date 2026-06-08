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

# Work QHD monitor (2560x1440). Identified by EDID fingerprint on whichever
# connector carries it. Now enumerates on DP-1 (USB-C/DP alt-mode); was HDMI-1.
# EDID differs per connector, so list every known fingerprint for this panel.
WORK_EDIDS=("cb76dbc92a7c85320f9970e90d320fc8" "bddd7ca3f93d7033383570f3e2231d92")
work_output=""
for node in /sys/class/drm/card*-DP-1 /sys/class/drm/card*-HDMI-A-1; do
    [ -e "$node/edid" ] || continue
    node_edid=$(md5sum "$node/edid" 2>/dev/null | awk '{print $1}')
    for e in "${WORK_EDIDS[@]}"; do
        if [ "$node_edid" = "$e" ]; then
            case "$node" in
                *-DP-1)     work_output="DP-1" ;;
                *-HDMI-A-1) work_output="HDMI-1" ;;
            esac
            break 2
        fi
    done
done

if [ -n "$work_output" ] && ! has_output "DP-1-1" && ! has_output "DP-1-2"; then
    # --- Work: QHD above (centered), laptop (rotated right) below ---
    # External 2560 wide, DSI 1280 wide → DSI x-offset = (2560-1280)/2 = 640 to center.
    xrandr --output DP-1-1 --off --output DP-1-2 --off --output DP-1-3 --off --output HDMI-1 --off --output DP-1 --off
    xrandr --output "$work_output" --mode 2560x1440 --pos 0x0 --rotate normal
    xrandr --output DSI-1 --mode 800x1280 --rotate right --pos 640x1440 --primary
    theme=work
    notify-send "Display" "Work: QHD above + laptop centered below (Win11 theme)" 2>/dev/null

elif has_output "DP-1-1" && has_output "DP-1-2"; then
    # --- Dock: P3421W ultrawide (DP-1-2, primary) + P2422HE vertical (DP-1-1, right) + laptop (below) ---
    xrandr --output HDMI-1 --off --output DP-1-3 --off
    xrandr --output DP-1-2 --mode 3440x1440 --pos 0x199 --rotate normal --primary
    xrandr --output DP-1-1 --mode 1920x1080 --rotate left --pos 3440x0
    xrandr --output DSI-1 --mode 800x1280 --rotate right --pos 997x1639
    theme=home
    notify-send "Display" "Dock: P3421W ultrawide + P2422HE vertical" 2>/dev/null

elif has_output "DP-1-2"; then
    # --- Dock (ultrawide only): P3421W (DP-1-2, primary) + laptop centered below ---
    # Reached when DP-1-2 is up but DP-1-1 (vertical) is not connected.
    # DSI displayed 1280 wide (800x1280 rotated right) → x=(3440-1280)/2=1080.
    xrandr --output DP-1-1 --off --output DP-1-3 --off --output HDMI-1 --off
    xrandr --output DP-1-2 --mode 3440x1440 --pos 0x0 --rotate normal --primary
    xrandr --output DSI-1 --mode 800x1280 --rotate right --pos 1080x1440
    theme=home
    notify-send "Display" "Dock: P3421W ultrawide + laptop below" 2>/dev/null

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
