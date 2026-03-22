#!/bin/bash

source "$HOME/.config/icons.sh"

# Apps to check for notification badges
APPS=("Slack" "Discord" "Messages" "Mail" "Microsoft Teams" "Telegram" "Microsoft Outlook")
ICONS=("󰍩" "󰙯" "󰍩" "󰇮" "󰊻" "󰍩" "󰇮")

LABEL=""
for i in "${!APPS[@]}"; do
  APP="${APPS[$i]}"
  BADGE=$(lsappinfo -all info -only StatusLabel "$APP" 2>/dev/null | sed -nr 's/.*\"label\"=\"(.+)\".*/\1/p')
  if [[ -n "$BADGE" && "$BADGE" != "0" && "$BADGE" != "" ]]; then
    [[ -n "$LABEL" ]] && LABEL+="  "
    LABEL+="${ICONS[$i]} $BADGE"
  fi
done

if [[ -n "$LABEL" ]]; then
  sketchybar --set $NAME label="$LABEL" drawing=on
else
  sketchybar --set $NAME drawing=off
fi
