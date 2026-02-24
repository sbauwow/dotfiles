#!/bin/bash
# Toggle S/Z key swap
STATE_FILE="/tmp/sz-swap-enabled"

if [ -f "$STATE_FILE" ]; then
    # Restore defaults - get original keycodes from current layout
    setxkbmap -option
    setxkbmap
    rm "$STATE_FILE"
    notify-send "S/Z Swap" "Disabled"
else
    xmodmap ~/.Xmodmap
    touch "$STATE_FILE"
    notify-send "S/Z Swap" "Enabled"
fi
