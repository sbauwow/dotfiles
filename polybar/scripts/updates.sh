#!/bin/bash
# Check for Arch Linux updates (cached for 30 minutes)
CACHE="/tmp/polybar-updates"
CACHE_AGE=1800

if [ -f "$CACHE" ]; then
    age=$(( $(date +%s) - $(stat -c %Y "$CACHE") ))
    if [ "$age" -lt "$CACHE_AGE" ]; then
        cat "$CACHE"
        exit 0
    fi
fi

count=$(checkupdates 2>/dev/null | wc -l)
if [ "$count" -gt 0 ]; then
    echo " $count" > "$CACHE"
    echo " $count"
else
    echo "" > "$CACHE"
fi
