#!/bin/bash
# Switch to workspace based on which monitor is focused
# Usage: switch_workspace.sh <number>

NUM=$1
FOCUSED_MONITOR=$(/opt/homebrew/bin/aerospace list-monitors --focused --format '%{monitor-id}')

if [[ "$FOCUSED_MONITOR" == "2" ]]; then
  /opt/homebrew/bin/aerospace workspace "$((NUM + 10))"
else
  /opt/homebrew/bin/aerospace workspace "$NUM"
fi
