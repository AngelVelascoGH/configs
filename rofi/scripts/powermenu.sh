#!/bin/bash

# Current Theme
dir="$HOME/.config/rofi/"

# Options
shutdown='⏻ Shutdown'
reboot=' Reboot'
lock=' Lock'

# Rofi CMD
rofi_cmd="rofi -dmenu -i -p Power"
run_rofi() {
  printf "%s\n%s\n%s\n" "$lock" "$reboot" "$shutdown" | $rofi_cmd
}

# Execute Command
run_cmd() {
  case "$1" in
  "$lock")
    pidof hyprlock || hyprlock
    ;;
  "$reboot")
    systemctl reboot
    ;;
  "$shutdown")
    systemctl poweroff
    ;;
  esac
}

selection="$(run_rofi)"
[ -n "$selection" ] && run_cmd "$selection"
