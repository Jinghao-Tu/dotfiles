#!/bin/sh
swaylock -f -i "$HOME/Pictures/wallpaper/mhw-1.jpeg"
sleep 5
while pgrep -x "swaylock" >/dev/null; do
    niri msg action power-off-monitors
    sleep 30
done

