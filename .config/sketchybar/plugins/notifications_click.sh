#!/bin/bash

source "$HOME/.config/colors.sh"
source "$HOME/.config/icons.sh"

FONT="CaskaydiaCove Nerd Font"
WIDTH=260
POPUP_BG=0xee1d2021
POPUP_BORDER=0x40fbf1c7

# ── Derive prefix from item name (notifications_m1 -> nfm1) ─────────
case "$NAME" in
  *_m1) PFX="nfm1" ;;
  *_m2) PFX="nfm2" ;;
  *)    PFX="nf0"   ;;
esac

# ── Toggle off if already open ───────────────────────────────────────
DRAWING=$(sketchybar --query $NAME 2>/dev/null | jq -r '.popup.drawing // "off"')

if [[ "$DRAWING" == "on" ]]; then
  # Animate out: fade + slide up
  sketchybar --animate tanh 10 --set $NAME popup.background.color=0x001d2021 \
                                            popup.background.border_color=0x00fbf1c7 \
                                            popup.y_offset=-4
  sleep 0.2
  sketchybar --set $NAME popup.drawing=off
  sketchybar --remove "/$PFX\./" 2>/dev/null
  exit 0
fi

# Clean stale items
sketchybar --remove "/$PFX\./" 2>/dev/null

# ── App registry: "DisplayName|lsappinfo name|BundleID|Icon|Color" ───
APP_DEFS=(
  "Slack|Slack|com.tinyspeck.slackmacgap|󰍩|$COLOR_MAGENTA_BRIGHT"
  "Discord|Discord|com.hnc.Discord|󰙯|$COLOR_BLUE_BRIGHT"
  "Messages|Messages|com.apple.MobileSMS|󰍩|$COLOR_GREEN_BRIGHT"
  "Mail|Mail|com.apple.mail|󰇮|$COLOR_CYAN"
  "Teams|Microsoft Teams|com.microsoft.teams2|󰊻|$COLOR_MAGENTA"
  "Telegram|Telegram|org.telegram.desktop|󰍩|$COLOR_CYAN_BRIGHT"
  "Outlook|Microsoft Outlook|com.microsoft.Outlook|󰇮|$COLOR_BLUE_BRIGHT"
)

# ── Gather badge counts ─────────────────────────────────────────────
FOUND_NAMES=()
FOUND_BUNDLES=()
FOUND_ICONS=()
FOUND_COLORS=()
FOUND_BADGES=()

for entry in "${APP_DEFS[@]}"; do
  IFS='|' read -r display_name lsname bundle icon color <<< "$entry"
  BADGE=$(lsappinfo -all info -only StatusLabel "$lsname" 2>/dev/null \
    | sed -nr 's/.*"label"="(.+)".*/\1/p')
  if [[ -n "$BADGE" && "$BADGE" != "0" && "$BADGE" != "" ]]; then
    FOUND_NAMES+=("$display_name")
    FOUND_BUNDLES+=("$bundle")
    FOUND_ICONS+=("$icon")
    FOUND_COLORS+=("$color")
    FOUND_BADGES+=("$BADGE")
  fi
done

COUNT=${#FOUND_NAMES[@]}

# ── Build popup items ────────────────────────────────────────────────
ARGS=()

# Top spacer
ARGS+=(--add item $PFX.tp popup.$NAME
       --set $PFX.tp
         icon.drawing=off label=" "
         "label.font=$FONT:Regular:6.0" label.color=0x00000000
         background.drawing=off width=$WIDTH)

# Header
ARGS+=(--add item $PFX.hdr popup.$NAME
       --set $PFX.hdr
         icon="󰂞"
         "icon.color=$COLOR_RED_BRIGHT"
         "icon.font=$FONT:Bold:16.0"
         icon.padding_left=14 icon.padding_right=8
         label="Notifications"
         "label.color=$COLOR_FOREGROUND"
         "label.font=$FONT:Bold:13.0"
         label.padding_right=14
         background.drawing=off width=$WIDTH)

# Header separator
ARGS+=(--add item $PFX.hs popup.$NAME
       --set $PFX.hs
         icon.drawing=off label=" "
         "label.font=$FONT:Regular:6.0" label.color=0x00000000
         background.color=0x25fbf1c7 background.height=1
         background.drawing=on
         padding_left=12 padding_right=12 width=$WIDTH)

if [[ $COUNT -gt 0 ]]; then
  for i in $(seq 0 $(($COUNT - 1))); do
    name="${FOUND_NAMES[$i]}"
    bundle="${FOUND_BUNDLES[$i]}"
    icon="${FOUND_ICONS[$i]}"
    color="${FOUND_COLORS[$i]}"
    badge="${FOUND_BADGES[$i]}"

    # Thin divider between rows
    if [[ $i -gt 0 ]]; then
      ARGS+=(--add item "$PFX.d.$i" popup.$NAME
             --set "$PFX.d.$i"
               icon.drawing=off label=" "
               "label.font=$FONT:Regular:2.0" label.color=0x00000000
               background.color=0x15fbf1c7 background.height=1
               background.drawing=on
               padding_left=36 padding_right=14 width=$WIDTH)
    fi

    # App row: icon  AppName ........... badge
    PADDED=$(printf "%-16s%4s" "$name" "$badge")

    CLOSE_CMD="sketchybar --animate tanh 10 --set $NAME popup.background.color=0x001d2021 popup.background.border_color=0x00fbf1c7 popup.y_offset=-4; sleep 0.2; sketchybar --set $NAME popup.drawing=off; sketchybar --remove '/$PFX\\./' 2>/dev/null"

    ARGS+=(--add item "$PFX.r.$i" popup.$NAME
           --set "$PFX.r.$i"
             icon="$icon"
             "icon.color=$color"
             "icon.font=$FONT:Bold:15.0"
             icon.padding_left=14 icon.padding_right=8
             label="$PADDED"
             "label.color=$COLOR_WHITE_BRIGHT"
             "label.font=$FONT:Regular:12.0"
             label.padding_right=14
             background.color=0x00000000 background.height=28
             background.corner_radius=6 background.drawing=on
             width=$WIDTH
             click_script="open -b $bundle; $CLOSE_CMD")
  done
else
  # Empty state
  ARGS+=(--add item $PFX.nil popup.$NAME
         --set $PFX.nil
           icon="󰸞"
           "icon.color=$COLOR_GREEN"
           "icon.font=$FONT:Regular:18.0"
           icon.padding_left=14 icon.padding_right=8
           label="All caught up"
           "label.color=$COLOR_BLACK_BRIGHT"
           "label.font=$FONT:Regular:12.0"
           label.padding_right=14
           background.drawing=off width=$WIDTH)
fi

# Bottom spacer
ARGS+=(--add item $PFX.bp popup.$NAME
       --set $PFX.bp
         icon.drawing=off label=" "
         "label.font=$FONT:Regular:6.0" label.color=0x00000000
         background.drawing=off width=$WIDTH)

# ── Show popup with animation ────────────────────────────────────────
# Start with transparent bg + offset up, then animate in
sketchybar --set $NAME popup.background.color=0x001d2021               \
                       popup.background.border_color=0x00fbf1c7        \
                       popup.y_offset=-4

# Create items + show popup
sketchybar "${ARGS[@]}" --set $NAME popup.drawing=on

# Animate in: slide down + fade in
sketchybar --animate tanh 15 --set $NAME popup.background.color=$POPUP_BG   \
                                         popup.background.border_color=$POPUP_BORDER \
                                         popup.y_offset=6
