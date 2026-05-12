#!/bin/bash
# Toggle DSI-1 between left and right rotation, then remap the touchscreen
# so taps land where you tap them. `xinput map-to-output` recomputes the
# matrix from DSI-1's current orientation, so it also covers normal/inverted
# if you set those manually with xrandr.
CURRENT=$(xrandr --query --verbose | awk '/^DSI-1 connected/ {for (i=1;i<=NF;i++) if ($i ~ /^(normal|left|right|inverted)$/) {print $i; exit}}')

if [ "$CURRENT" = "left" ]; then
    xrandr --output DSI-1 --rotate right
else
    xrandr --output DSI-1 --rotate left
fi

xinput map-to-output "ELAN Touchscreen" DSI-1
