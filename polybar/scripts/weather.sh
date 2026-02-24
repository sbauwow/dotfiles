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

weather=$(curl -sf "wttr.in/Liberty+Hill,Texas?format=%c+%t&u" 2>/dev/null | sed 's/+//g' | tr -d '\n')
if [ -n "$weather" ]; then
    # Map Unicode weather emojis to Nerd Font weather icons
    # Strip variation selectors (U+FE0F) first, then replace emojis
    NF_SUNNY=$(printf '\xee\x8c\x8d')       # U+E30D nf-weather-day_sunny
    NF_PARTCLOUD=$(printf '\xee\x8c\x82')    # U+E302 nf-weather-day_cloudy
    NF_CLOUDHI=$(printf '\xee\x8c\x92')      # U+E312 nf-weather-day_cloudy_high
    NF_CLOUDY=$(printf '\xee\x8c\xbd')       # U+E33D nf-weather-cloudy
    NF_DAYRAIN=$(printf '\xee\x8c\x88')      # U+E308 nf-weather-day_rain
    NF_RAIN=$(printf '\xee\x8c\x98')         # U+E318 nf-weather-rain
    NF_STORM=$(printf '\xee\x8c\x9d')        # U+E31D nf-weather-thunderstorm
    NF_SNOW=$(printf '\xee\x8c\x9a')         # U+E31A nf-weather-snow
    NF_FOG=$(printf '\xee\x8c\x85')          # U+E305 nf-weather-day_fog
    NF_TORNADO=$(printf '\xee\x8c\xa1')      # U+E321 nf-weather-tornado
    NF_WIND=$(printf '\xee\x8d\x8b')         # U+E34B nf-weather-strong_wind

    weather=$(echo "$weather" | sed $'s/\xef\xb8\x8f//g' | sed \
        -e "s/☀/${NF_SUNNY}/g" \
        -e "s/🌤/${NF_PARTCLOUD}/g" \
        -e "s/⛅/${NF_PARTCLOUD}/g" \
        -e "s/🌥/${NF_CLOUDHI}/g" \
        -e "s/☁/${NF_CLOUDY}/g" \
        -e "s/🌦/${NF_DAYRAIN}/g" \
        -e "s/🌧/${NF_RAIN}/g" \
        -e "s/⛈/${NF_STORM}/g" \
        -e "s/🌩/${NF_STORM}/g" \
        -e "s/🌨/${NF_SNOW}/g" \
        -e "s/❄/${NF_SNOW}/g" \
        -e "s/🌫/${NF_FOG}/g" \
        -e "s/🌪/${NF_TORNADO}/g" \
        -e "s/💨/${NF_WIND}/g" \
        -e "s/🌈/${NF_SUNNY}/g" \
    )
    echo "$weather" > "$CACHE"
    echo "$weather"
fi
