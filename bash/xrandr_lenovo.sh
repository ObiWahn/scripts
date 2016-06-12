#!/bin/bash

output="$(xrandr  | grep "*" | awk '{ print $1 }')"
echo "Debug: $output"

case $output in
    2560x1440)
        xrandr --output eDP1 --mode 1920x1080
    ;;
    1920x1080)
        xrandr --output eDP1 --mode 2560x1440
    ;;
    *)
        #default is the native resultion
        xrandr --output eDP1 --mode 1920x1080
    ;;
esac
