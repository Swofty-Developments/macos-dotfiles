#!/bin/bash
# Move window to workspace and follow, based on which monitor is focused
# Usage: move_to_workspace.sh <number>

NUM=$1
FOCUSED_MONITOR=$(/opt/homebrew/bin/aerospace list-monitors --focused --format '%{monitor-id}')

if [[ "$FOCUSED_MONITOR" == "2" ]]; then
  WS=$((NUM + 10))
else
  WS=$NUM
fi

/opt/homebrew/bin/aerospace move-node-to-workspace "$WS"
/opt/homebrew/bin/aerospace workspace "$WS"
