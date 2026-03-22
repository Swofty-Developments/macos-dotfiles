#!/bin/bash
# Move all windows from current workspace to the same-numbered workspace on the other monitor
# Usage: move_ws_to_monitor.sh <left|right>
A=/opt/homebrew/bin/aerospace
DIRECTION=$1

CURRENT_WS=$($A list-workspaces --focused)

# Determine target workspace
if [ "$CURRENT_WS" -le 9 ]; then
  TARGET_WS=$((CURRENT_WS + 10))
else
  TARGET_WS=$((CURRENT_WS - 10))
fi

# Move all windows in current workspace to target
WINDOW_IDS=$($A list-windows --workspace "$CURRENT_WS" --format '%{window-id}')
if [ -n "$WINDOW_IDS" ]; then
  while IFS= read -r WID; do
    [ -n "$WID" ] && $A move-node-to-workspace "$TARGET_WS" --window-id "$WID"
  done <<< "$WINDOW_IDS"
  $A workspace "$TARGET_WS"
fi
