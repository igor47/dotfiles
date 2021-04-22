#!/bin/bash

battery_status=`cat /sys/class/power_supply/BAT0/status`
if [[ ${battery_status} == "Charging" ]]
then
  exit 0
fi

battery_level=`cat /sys/class/power_supply/BAT0/capacity`

if [ "$battery_level" -le 5 ]
then
  notify-send "Battery critical. Battery level is ${battery_level}%! Suspending..."
  sleep 5
  systemctl suspend
elif [ "$battery_level" -le 8 ]
then
  notify-send "Battery low. Battery level is ${battery_level}%!"
fi
