#!/bin/bash

source "$HOME/.config/colors.sh"
source "$HOME/.config/icons.sh"

STATE="/tmp/sketchybar_notif_state"
DISMISS_PID="/tmp/sketchybar_notif_dismiss"
FONT="CaskaydiaCove Nerd Font"
BW=220

# ── App registry ─────────────────────────────────────────────────────
APPS_LS=("Slack" "Discord" "Messages" "Mail" "Microsoft Teams" "Telegram" "Microsoft Outlook")
APPS_SHORT=("Slack" "Discord" "Messages" "Mail" "Teams" "Telegram" "Outlook")
APPS_ICONS=("󰍩" "󰙯" "󰍩" "󰇮" "󰊻" "󰍩" "󰇮")
APPS_COLORS=("$COLOR_MAGENTA_BRIGHT" "$COLOR_BLUE_BRIGHT" "$COLOR_GREEN_BRIGHT" "$COLOR_CYAN" "$COLOR_MAGENTA" "$COLOR_CYAN_BRIGHT" "$COLOR_BLUE_BRIGHT")

# ── Read badges ──────────────────────────────────────────────────────
BADGE_LABEL=""
NEW=()

for i in "${!APPS_LS[@]}"; do
  BADGE=$(lsappinfo -all info -only StatusLabel "${APPS_LS[$i]}" 2>/dev/null \
    | sed -nr 's/.*"label"="(.+)".*/\1/p')

  CUR=0
  if [[ -n "$BADGE" && "$BADGE" != "" ]]; then
    [[ "$BADGE" =~ ^[0-9]+$ ]] && CUR=$BADGE || CUR=1
  fi

  if [[ $CUR -gt 0 ]]; then
    [[ -n "$BADGE_LABEL" ]] && BADGE_LABEL+="  "
    BADGE_LABEL+="${APPS_ICONS[$i]} $BADGE"

    OLD=$(grep "^${APPS_SHORT[$i]}=" "$STATE" 2>/dev/null | cut -d= -f2)
    OLD=${OLD:-0}
    if [[ $CUR -gt $OLD ]]; then
      DIFF=$((CUR - OLD))
      NEW+=("$i:$DIFF")
    fi
  fi
done

# ── Update badge pills on both monitors ──────────────────────────────
if [[ -n "$BADGE_LABEL" ]]; then
  sketchybar --set notifications_m1 label="$BADGE_LABEL" drawing=on \
             --set notifications_m2 label="$BADGE_LABEL" drawing=on
else
  sketchybar --set notifications_m1 drawing=off \
             --set notifications_m2 drawing=off
fi

# ── Save state ───────────────────────────────────────────────────────
FIRST_RUN=false
[[ ! -f "$STATE" ]] && FIRST_RUN=true

: > "$STATE"
for i in "${!APPS_LS[@]}"; do
  BADGE=$(lsappinfo -all info -only StatusLabel "${APPS_LS[$i]}" 2>/dev/null \
    | sed -nr 's/.*"label"="(.+)".*/\1/p')
  if [[ -n "$BADGE" && "$BADGE" != "" ]]; then
    [[ "$BADGE" =~ ^[0-9]+$ ]] && echo "${APPS_SHORT[$i]}=$BADGE" >> "$STATE" \
                                || echo "${APPS_SHORT[$i]}=1" >> "$STATE"
  fi
done

# ── Banner on new notifications ──────────────────────────────────────
[[ ${#NEW[@]} -eq 0 || "$FIRST_RUN" == "true" ]] && exit 0

# Cancel pending dismiss
[[ -f "$DISMISS_PID" ]] && kill "$(cat "$DISMISS_PID")" 2>/dev/null && rm -f "$DISMISS_PID"
sketchybar --remove '/nb\./' 2>/dev/null

# Pick the most notable new notification (highest count)
BEST_I=0
BEST_C=0
for entry in "${NEW[@]}"; do
  idx="${entry%%:*}"
  cnt="${entry##*:}"
  if [[ $cnt -gt $BEST_C ]]; then
    BEST_I=$idx
    BEST_C=$cnt
  fi
done

BICON="${APPS_ICONS[$BEST_I]}"
BCOLOR="${APPS_COLORS[$BEST_I]}"
BNAME="${APPS_SHORT[$BEST_I]}"
[[ $BEST_C -eq 1 ]] && BTEXT="$BNAME" || BTEXT="$BNAME · $BEST_C new"

# Extra line if multiple apps
EXTRA=""
EXTRA_COUNT=$(( ${#NEW[@]} - 1 ))
[[ $EXTRA_COUNT -gt 0 ]] && EXTRA="and $EXTRA_COUNT other app$( [[ $EXTRA_COUNT -gt 1 ]] && echo s)"

ARGS=()
for M in m1 m2; do
  P="nb.${M}"
  PARENT="notifications_${M}"

  ARGS+=(--add item "${P}.main" popup.$PARENT
         --set "${P}.main"
           icon="$BICON"
           "icon.color=$BCOLOR"
           "icon.font=$FONT:Bold:14.0"
           icon.padding_left=14
           icon.padding_right=0
           label="$BTEXT"
           "label.color=$COLOR_FOREGROUND"
           "label.font=$FONT:Regular:12.0"
           label.padding_left=8
           label.padding_right=14
           background.drawing=off
           width=$BW)

  if [[ -n "$EXTRA" ]]; then
    ARGS+=(--add item "${P}.extra" popup.$PARENT
           --set "${P}.extra"
             icon.drawing=off
             label="$EXTRA"
             "label.color=$COLOR_BLACK_BRIGHT"
             "label.font=$FONT:Regular:10.0"
             label.padding_left=14
             label.padding_right=14
             background.drawing=off
             width=$BW)
  fi

  ARGS+=(--set $PARENT popup.y_offset=-30)
done

# Show + animate in
sketchybar "${ARGS[@]}" \
  --set notifications_m1 drawing=on popup.drawing=on \
  --set notifications_m2 drawing=on popup.drawing=on

sketchybar --animate tanh 18 \
  --set notifications_m1 popup.y_offset=8 \
  --set notifications_m2 popup.y_offset=8

# Auto-dismiss after 4s
(
  sleep 10
  sketchybar --animate tanh 14 \
    --set notifications_m1 popup.y_offset=-30 \
    --set notifications_m2 popup.y_offset=-30
  sleep 0.35
  sketchybar --set notifications_m1 popup.drawing=off \
             --set notifications_m2 popup.drawing=off
  sketchybar --remove '/nb\./' 2>/dev/null
  rm -f "$DISMISS_PID"
) &
echo $! > "$DISMISS_PID"
