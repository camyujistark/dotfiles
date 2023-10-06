#!/bin/bash
# Based off: https://github.com/MaxGyver83/dotfiles/blob/972d7d2379e4eacfdabadd5d895500a4c1dbce0f/scripts/bin/start-kmonad-for-all-keyboards.fish

HOME="/home/camstark"

BT_KB_SEARCH="Keychron K2"
BT_KB_EVENT_ID="$(grep -B 9 -A 4 12001 /proc/bus/input/devices | grep "${BT_KB_SEARCH}" -A 4 | grep -oE 'event[0-9]+')"
BT_EVENT_PATH="/dev/input/${BT_KB_EVENT_ID}"

KB_KMONAD_PATH="${HOME}/.config/kmonad/keyboard.kbd"
KEYCHRON_KBD_ID="/dev/input/by-id/usb-Keychron_Keychron_K2-event-kbd"

LATOP_KMONAD_PATH="${HOME}/.config/kmonad/laptop.kbd"
TEMP_CURRENT="/tmp/kmonad-connection"

if [[ -e "${BT_EVENT_PATH}" ]]; then
  # Switch out event id
  sed -r -i 's%/dev/input/event[[:digit:]]+%'"${BT_EVENT_PATH}"'%g' "${KB_KMONAD_PATH}"
  sed -i 's:'"${KEYCHRON_KBD_ID}"':'"${BT_EVENT_PATH}"':g' "${KB_KMONAD_PATH}"

  sudo kmonad "${KB_KMONAD_PATH}"

elif [[ -e "${KEYCHRON_KBD_ID}" ]]; then
  # Switch out event id
  #
  sed -r -i 's%/dev/input/event[[:digit:]]+%'"${KEYCHRON_KBD_ID}"'%g' "${KB_KMONAD_PATH}"

  sudo kmonad "${KB_KMONAD_PATH}"
else 

  sudo kmonad "${LATOP_KMONAD_PATH}"
fi
