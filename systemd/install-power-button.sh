#!/bin/bash
set -euo pipefail

SRC="$(cd "$(dirname "$0")" && pwd)/logind.conf.d/power-button.conf"
DST="/etc/systemd/logind.conf.d/power-button.conf"

if [ ! -s "$SRC" ]; then
    echo "source missing or empty: $SRC" >&2
    exit 1
fi

if [ "$(id -u)" -ne 0 ]; then
    echo "needs root. rerun with sudo:"
    echo "  sudo $0"
    exit 1
fi

install -Dm644 "$SRC" "$DST"
echo "installed → $DST"
cat "$DST"

echo
echo "restart logind to apply (WARNING: may end session):"
echo "  systemctl restart systemd-logind"
echo
echo "verify:"
echo "  busctl get-property org.freedesktop.login1 /org/freedesktop/login1 org.freedesktop.login1.Manager HandlePowerKeyLongPress"
