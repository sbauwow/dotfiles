#!/bin/bash
if pkill -f 'mpv.*chillsky'; then
    exit 0
fi
mpv --no-video https://protostar.shoutca.st/tunein/chill.pls &
