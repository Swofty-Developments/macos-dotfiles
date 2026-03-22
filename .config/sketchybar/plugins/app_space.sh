#!/bin/bash

source "$HOME/.config/icons.sh"

# Extract space id from item name
SID=$(echo $NAME | sed 's/space\.//')

# Get focused workspace
FOCUSED=$(/opt/homebrew/bin/aerospace list-workspaces --focused 2>/dev/null)

# Just highlight/unhighlight this workspace
if [[ "$SID" == "$FOCUSED" ]]; then
  sketchybar --set $NAME background.drawing=on icon.highlight=on label.highlight=on
else
  sketchybar --set $NAME background.drawing=off icon.highlight=off label.highlight=off
fi
