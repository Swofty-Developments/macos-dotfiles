#!/bin/bash

source "$HOME/.config/icons.sh"

PERCENTAGE=$(pmset -g batt | grep -Eo "\d+%" | head -1 | tr -d '%')
CHARGING=$(pmset -g batt | grep -c "AC Power")

if [[ -z "$PERCENTAGE" ]]; then
  sketchybar --set $NAME drawing=off
  exit 0
fi

# Pick battery icon based on level
INDEX=$(( PERCENTAGE / 10 ))
if [[ $INDEX -gt 10 ]]; then INDEX=10; fi

if [[ "$CHARGING" -gt 0 ]]; then
  ICON=${ICONS_BATTERY_CHARGING[$INDEX]}
else
  ICON=${ICONS_BATTERY[$INDEX]}
fi

sketchybar --set $NAME icon="$ICON" label="${PERCENTAGE}%"
