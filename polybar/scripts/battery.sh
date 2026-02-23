#!/usr/bin/env bash
# Detailed battery metrics for polybar

BAT="/sys/class/power_supply/BAT0"

[[ ! -d "$BAT" ]] && exit 0

status=$(cat "$BAT/status")
capacity=$(cat "$BAT/capacity")
energy_now=$(cat "$BAT/energy_now")
energy_full=$(cat "$BAT/energy_full")
energy_full_design=$(cat "$BAT/energy_full_design")
power_now=$(cat "$BAT/power_now")

# Convert microwatt-hours / microwatts to human units
watts=$(awk "BEGIN {printf \"%.1f\", $power_now / 1000000}")
health=$(awk "BEGIN {printf \"%.0f\", ($energy_full / $energy_full_design) * 100}")

# Time calculation
if [[ "$power_now" -gt 0 ]]; then
    case "$status" in
        Charging)
            remaining=$((energy_full - energy_now))
            secs=$(awk "BEGIN {printf \"%.0f\", ($remaining / $power_now) * 3600}")
            ;;
        Discharging)
            secs=$(awk "BEGIN {printf \"%.0f\", ($energy_now / $power_now) * 3600}")
            ;;
        *)
            secs=0
            ;;
    esac
    hours=$((secs / 3600))
    mins=$(( (secs % 3600) / 60 ))
    time_str="${hours}h${mins}m"
else
    time_str=""
fi

# Colors from neon theme
C_LIME="#00ff88"
C_ORANGE="#ff6d00"
C_RED="#ff3d3d"
C_FG="#d4dce6"
C_CYAN="#00e5ff"
C_COMMENT="#4a5568"

# Pick color based on state and capacity
case "$status" in
    Charging)
        color="$C_LIME"
        ;;
    Full|"Not charging")
        color="$C_LIME"
        ;;
    Discharging)
        if [[ "$capacity" -le 10 ]]; then color="$C_RED"
        elif [[ "$capacity" -le 25 ]]; then color="$C_ORANGE"
        else color="$C_FG"
        fi
        ;;
    *)
        color="$C_FG"
        ;;
esac

# Build icon based on capacity
if [[ "$capacity" -le 10 ]]; then icon="󰁺"
elif [[ "$capacity" -le 25 ]]; then icon="󰁼"
elif [[ "$capacity" -le 50 ]]; then icon="󰁾"
elif [[ "$capacity" -le 75 ]]; then icon="󰂀"
else icon="󰁹"
fi

# Build output per state
case "$status" in
    Charging)
        icon="󰂄"
        label="${capacity}%  ${watts}W"
        [[ -n "$time_str" ]] && label="${label}  ${time_str}"
        ;;
    Discharging)
        label="${capacity}%  ${watts}W"
        [[ -n "$time_str" ]] && label="${label}  ${time_str}"
        ;;
    Full|"Not charging")
        icon="󰁹"
        label="full"
        ;;
    *)
        label="${capacity}%"
        ;;
esac

# Append health warning if battery is degraded (< 80%)
if [[ "$health" -lt 80 ]]; then
    label="${label}  %{F${C_RED}}hlth ${health}%%{F-}"
fi

# Output with polybar color formatting
echo "%{F${color}}${icon}%{F-} %{F${color}}${label}%{F-}"
