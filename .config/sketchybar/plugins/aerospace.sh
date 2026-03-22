#!/bin/bash

# Highlight active workspace
FOCUSED=$(/opt/homebrew/bin/aerospace list-workspaces --focused)

if [ "$1" = "$FOCUSED" ]; then
  sketchybar --set $NAME label.highlight=on background.drawing=on
else
  # Check if workspace has windows
  WINDOWS=$(/opt/homebrew/bin/aerospace list-windows --workspace "$1" 2>/dev/null | wc -l)
  if [ "$WINDOWS" -gt 0 ]; then
    sketchybar --set $NAME label.highlight=off background.drawing=on background.color=0xff45475a
  else
    sketchybar --set $NAME label.highlight=off background.drawing=off
  fi
fi
