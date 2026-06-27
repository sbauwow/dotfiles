#!/bin/bash
pidfile=/tmp/vaporwave-mpv.pid

if [ -s "$pidfile" ] && kill -0 "$(cat "$pidfile")" 2>/dev/null; then
    kill "$(cat "$pidfile")"
    rm -f "$pidfile"
    exit 0
fi

mpv --no-terminal --force-window=no --no-video https://somafm.com/vaporwaves.pls >/tmp/vaporwave-mpv.log 2>&1 &
echo "$!" > "$pidfile"
