#!/usr/bin/env bash
#
# Neon Cyber conky launcher. Kills any running conky, waits, relaunches
# the main system monitor and i3 shortcuts overlay from the dotfiles repo.
#
# Wired from i3 via: exec --no-startup-id ~/dotfiles/conky/launch.sh

set -u

DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"

pkill -x conky >/dev/null 2>&1 || true
sleep 0.5

conky -c "$DIR/conky_main.conf" -d >/dev/null 2>&1 &
conky -c "$DIR/conky_shortcuts.conf" -d >/dev/null 2>&1 &

exit 0
