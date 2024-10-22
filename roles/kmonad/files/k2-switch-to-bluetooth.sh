#!/bin/bash
# Based off: https://github.com/MaxGyver83/dotfiles/blob/972d7d2379e4eacfdabadd5d895500a4c1dbce0f/scripts/bin/start-kmonad-for-all-keyboards.fish

HOME="/home/camstark"

BT_KB_SEARCH="Keychron K2"
BT_KB_EVENT_ID="$(grep -B 9 -A 4 12001 /proc/bus/input/devices | grep "${BT_KB_SEARCH}" -A 4 | grep -oE 'event[0-9]+')"
BT_INPUT_PATH="/dev/input/${BT_KB_EVENT_ID}"

KB_KMONAD_PATH="${HOME}/.config/kmonad/keyboard.kbd"
KEYCHRON_INPUT_PATH="/dev/input/by-id/usb-Keychron_Keychron_K2-event-kbd"

LATOP_KMONAD_PATH="${HOME}/.config/kmonad/laptop.kbd"

if [[ "${BT_KB_EVENT_ID}" ]]; then
  # If eventID exists then switch to new bt input path
  sed -r -i 's%"/dev/input/event[[:digit:]]+"%'"\"${BT_INPUT_PATH}\""'%g' "${KB_KMONAD_PATH}"

  # If /dev/input/ exists then update to new bt input path
  sed -i 's%"/dev/input/"%'"\"${BT_INPUT_PATH}\""'%g' "${KB_KMONAD_PATH}"

  sudo kmonad "${KB_KMONAD_PATH}" &

elif [[ -e "${KEYCHRON_INPUT_PATH}" ]]; then

  # If bt input exists then switch to new bt input path
  sed -i 's:'"${BT_INPUT_PATH}"':'"${KEYCHRON_INPUT_PATH}"':g' "${KB_KMONAD_PATH}"

  # If /dev/input/ exists then update to new bt input path
  sed -i 's%"/dev/input/"%'"\"${KEYCHRON_INPUT_PATH}\""'%g' "${KB_KMONAD_PATH}"

  sudo kmonad "${KB_KMONAD_PATH}" &
else 

  sudo kmonad "${LATOP_KMONAD_PATH}"&
fi
