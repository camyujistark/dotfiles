#!/bin/bash
# Based off: https://github.com/MaxGyver83/dotfiles/blob/972d7d2379e4eacfdabadd5d895500a4c1dbce0f/scripts/bin/start-kmonad-for-all-keyboards.fish

KB_SEARCH="bluetooth"
BLUETOOTH_KB_EVENT_ID="$(grep -B 9 -A 4 12001 /proc/bus/input/devices | grep "${KB_SEARCH}" -A 4 | grep -oE 'event[0-9]+')"
EVENT_PATH="/dev/input/${BLUETOOTH_KB_EVENT_ID}"
PATH_TO_FILE="~/.config/kmonad/keyboard.kbd"
KEYCHRON_KBD="/dev/input/by-id/usb-Keychron_Keychron_K2-event-kbd"

# TODO: Need to get the corrrect path if plugged in
sed -i 's:'"${EVENT_PATH}"':'"${KEYCHRON_KBD}"':g' "${PATH_TO_FILE}"


