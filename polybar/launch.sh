#!/usr/bin/env bash

# Lock to prevent concurrent launches (race between udev/dock-setup and i3 exec_always)
LOCKFILE="/tmp/polybar-launch.lock"
exec 9>"$LOCKFILE"
flock -n 9 || exit 0

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -u $UID -x polybar >/dev/null; do sleep 0.2; done

# Launch polybar on all monitors
for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    MONITOR=$m polybar --reload main &
done

# Wait for polybar tray to be ready, then restart tray applets
(
    sleep 2

    # Kill stale tray applets so they re-dock into the new tray
    killall -q nm-applet xfce4-power-manager pamac-tray clipit

    sleep 1
    nm-applet &disown 2>/dev/null
    xfce4-power-manager &disown 2>/dev/null
    pamac-tray &disown 2>/dev/null
    clipit &disown 2>/dev/null
) &disown

echo "Polybar launched..."
