#!/bin/bash
# Usage: ws.sh <action> <number>
# action: switch | move
A=/opt/homebrew/bin/aerospace
NUM=$2
M=$($A list-monitors --focused | cut -d'|' -f1 | tr -d ' ')
if [ "$M" = "2" ]; then
  WS=$((NUM + 10))
else
  WS=$NUM
fi
if [ "$1" = "move" ]; then
  $A move-node-to-workspace "$WS"
  $A workspace "$WS"
else
  $A workspace "$WS"
fi
