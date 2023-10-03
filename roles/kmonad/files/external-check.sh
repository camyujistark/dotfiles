#!/bin/bash

device_name="usb-Keychron_Keychron_K2-event-kbd"

if [[ -e "/dev/input/by-id/${device_name}" ]]; then
    kmonad /home/camstark/.config/kmonad/keyboard.kbd
else
    kmonad /home/camstark/.config/kmonad/laptop.kbd
fi
