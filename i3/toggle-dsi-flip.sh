#!/bin/bash
# Toggle DSI-1 between left and right rotation
CURRENT=$(xrandr --query --verbose | awk '/^DSI-1 connected/ {for (i=1;i<=NF;i++) if ($i ~ /^(normal|left|right|inverted)$/) {print $i; exit}}')

if [ "$CURRENT" = "left" ]; then
    xrandr --output DSI-1 --rotate right
else
    xrandr --output DSI-1 --rotate left
fi
