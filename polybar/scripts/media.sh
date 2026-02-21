#!/bin/bash
# Display currently playing media via playerctl
player_status=$(playerctl status 2>/dev/null)
if [ "$player_status" = "Playing" ]; then
    artist=$(playerctl metadata artist 2>/dev/null)
    title=$(playerctl metadata title 2>/dev/null)
    if [ -n "$artist" ] && [ -n "$title" ]; then
        echo "  ${artist} - ${title}" | cut -c1-50
    elif [ -n "$title" ]; then
        echo "  ${title}" | cut -c1-40
    fi
elif [ "$player_status" = "Paused" ]; then
    title=$(playerctl metadata title 2>/dev/null)
    if [ -n "$title" ]; then
        echo "  ${title}" | cut -c1-40
    fi
fi
