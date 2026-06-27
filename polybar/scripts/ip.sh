#!/bin/bash
# Local IP of the interface owning the default route (wifi or wired)

ip=$(ip route get 1.1.1.1 2>/dev/null | grep -oP 'src \K[\d.]+')
[ -n "$ip" ] && echo "$ip"
