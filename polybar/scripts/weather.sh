#!/bin/bash
# Fetch weather from wttr.in (cached for 10 minutes)
CACHE="/tmp/polybar-weather"
CACHE_AGE=600

if [ -f "$CACHE" ]; then
    age=$(( $(date +%s) - $(stat -c %Y "$CACHE") ))
    if [ "$age" -lt "$CACHE_AGE" ]; then
        cat "$CACHE"
        exit 0
    fi
fi

weather=$(curl -sf "wttr.in/?format=%c+%t" 2>/dev/null | sed 's/+//g' | tr -d '\n')
if [ -n "$weather" ]; then
    echo "$weather" > "$CACHE"
    echo "$weather"
fi
