#!/bin/bash
if pkill -f 'mpv.*somafm.*reggae'; then
    exit 0
fi
mpv --no-video https://somafm.com/reggae.pls &
