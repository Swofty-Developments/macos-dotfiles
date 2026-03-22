#!/bin/bash

source "$HOME/.config/icons.sh"

# Update icons for all workspaces in one batch
ARGS=()

for sid in 1 2 3 4 5 6 7 8 9 11 12 13 14 15 16 17 18 19; do
  WINDOWS=$(/opt/homebrew/bin/aerospace list-windows --workspace "$sid" --format '%{app-name}' 2>/dev/null)
  LABEL=""

  if [[ -n "$WINDOWS" ]]; then
    while IFS= read -r APP; do
      [[ -z "$APP" ]] && continue
      ICON=$("$HOME/.config/sketchybar/plugins/app_icon.sh" "$APP" "")
      [[ -n "$LABEL" ]] && LABEL+=" "
      LABEL+="$ICON"
    done <<< "$WINDOWS"
  else
    LABEL="_"
  fi

  ARGS+=(--set space.$sid label="$LABEL")
done

sketchybar "${ARGS[@]}"
