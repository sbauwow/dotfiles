#!/usr/bin/env bash

# Lock to prevent concurrent launches (race between udev/dock-setup and i3 exec_always)
LOCKFILE="/tmp/polybar-launch.lock"
exec 9>"$LOCKFILE"
flock -n 9 || exit 0

WATCHDOG_PID="/tmp/polybar-watchdog.pid"
TRAY_APPLETS=(nm-applet xfce4-power-manager)

kill_applets() {
    killall -q "${TRAY_APPLETS[@]}"
}

restart_dunst() {
    killall -q dunst
    (dunst 9>&- &disown) 2>/dev/null
}

launch_bars() {
    killall -q polybar
    while pgrep -u $UID -x polybar >/dev/null; do sleep 0.2; done

    # Merge pywal-derived polybar palette if present (overrides static block in ~/.Xresources)
    if [ -f "$HOME/.cache/wal/colors-polybar.Xresources" ]; then
        xrdb -merge "$HOME/.cache/wal/colors-polybar.Xresources"
        # Reload i3 so set_from_resource $pb_* picks up the new palette.
        # Guarded — this script also runs under herbstluftwm where i3 isn't present.
        if command -v i3-msg >/dev/null && i3-msg -t get_version >/dev/null 2>&1; then
            i3-msg reload >/dev/null 2>&1 || true
        fi
    fi

    for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
        # Close lock fd in the polybar child so it doesn't keep the launch lock held
        MONITOR=$m polybar --reload main 9>&- &disown
        sleep 0.5
    done
}

wait_for_tray() {
    for i in $(seq 1 20); do
        xdotool search --name "polybar-main_" >/dev/null 2>&1 && return
        sleep 0.3
    done
}

launch_applets() {
    for app in "${TRAY_APPLETS[@]}"; do
        "$app" &disown 2>/dev/null
    done
}

# Kill previous watchdog
if [ -f "$WATCHDOG_PID" ]; then
    kill "$(cat "$WATCHDOG_PID")" 2>/dev/null
    rm -f "$WATCHDOG_PID"
fi

kill_applets
launch_bars

# Release lock now that all bars are spawned
exec 9>&-

wait_for_tray
sleep 1
launch_applets
restart_dunst

# Watchdog: restart everything if polybar dies
(
    echo $$ > "$WATCHDOG_PID"
    while true; do
        sleep 10
        if ! pgrep -u $UID -x polybar >/dev/null; then
            kill_applets
            sleep 1
            launch_bars
            wait_for_tray
            sleep 1
            launch_applets
        fi
    done
) &disown

echo "Polybar launched..."
