#!/bin/bash

o_remove_spaces(){
    local var="$1"
    var="${var#"${var%%[![:space:]]*}"}"   # remove leading whitespace characters
    var="${var%"${var##*[![:space:]]}"}"   # remove trailing whitespace characters
    echo "$var"
}
o_touchpad_call_xinput(){
    local touchpad=$(xinput --list --short | grep -m1 "SynPS/2 Synaptics TouchPad" | cut -f2 | cut -d= -f2)

    echo "status: '$(o_remove_spaces $1)' '$(o_remove_spaces $2)'"

    if [[ $1 == "enabled" ]]; then
        xinput set-prop $touchpad "Device Enabled" "$2"
    elif [[ $1 == "tapping" ]]; then
        xinput set-prop $touchpad "Synaptics Tap Action" 0 0 0 0 "$2" 0 0
    else
        echo "enabled $1"
        o_touchpad_call_xinput "enabled" "$1"
        echo "tapping $2"
        o_touchpad_call_xinput "tapping" "$2"
    fi

    ##elif [[ $status == "1 1" ]]; then
    ##    xinput set-prop $touchpad "Device Enabled" 1
    ##    xinput set-prop $touchpad "Synaptics Tap Action" 0 0 0 0 1 0 0
    ##    #gsettings set org.gnome.settings-daemon.peripherals.touchpad touchpad-enabled true
    ##    #gsettings set org.gnome.settings-daemon.peripherals.touchpad tap-to-click true

    ##elif [[ $status == "1 0" ]]; then
    ##    xinput set-prop $touchpad "Device Enabled" 1
    ##    xinput set-prop $touchpad "Synaptics Tap Action" 0 0 0 0 0 0 0
    ##    #gsettings set org.gnome.settings-daemon.peripherals.touchpad touchpad-enabled true
    ##    #gsettings set org.gnome.settings-daemon.peripherals.touchpad tap-to-click false

    ##elif [[ $status == "0 0" ]]; then
    ##    xinput set-prop $touchpad "Device Enabled" 0
    ##    #gsettings set org.gnome.settings-daemon.peripherals.touchpad touchpad-enabled false
    ##fi
}

o_touchpad_server(){
    local pipe=~/.touchpad_server

    trap "rm -f $pipe" EXIT
	if [[ ! -p $pipe ]]; then
    	mkfifo $pipe
	fi

	while read line <$pipe; do
        o_touchpad_call_xinput $line
	done
	echo "Touchpad Server exiting"
}

o_touchpad_get_status(){
    local touchpad=$(xinput --list --short | grep -m1 "SynPS/2 Synaptics TouchPad" | cut -f2 | cut -d= -f2)
    local props="$(xinput list-props $touchpad)"
    enabled="$(grep "Device Enabled" <<< "$props" | awk -F: '{ print $2 }')"
    tapping="$(grep "Synaptics Tap Action" <<< "$props" | awk -F: '{ print $2 }' | awk -F, '{ print $5 }')"
    echo "$(o_remove_spaces $enabled) $(o_remove_spaces $tapping)"
}


 o_touchpad_client(){
    local pipe=~/.touchpad_server
    local touchpad_enabled="touchpad and tapping enabled"  # status 1
    local tapping_disabled="tapping disabled"              # status 2
    local touchpad_disabled="touchpad disabled"            # status 3
    echo "client input: $@"

    if [[ "$1" == toggle ]]; then
        status="$(o_touchpad_get_status)"
        echo "status in system: '$status'"
        if [[ "$status" == "1 1" ]]; then
            echo "disable tapping"
            echo "1 0" > $pipe
            notify-send -t 2000 -i input-touchpad "touchpad:on tapping:off"
        elif [[ "$status" == "1 0" ]]; then
            echo "disable touchpad"
            echo "0 0" > $pipe
            notify-send -t 2000 -i input-touchpad "touchpad:off"
        elif [[ "$status" == "0 0" ]]; then
            echo "enable touchpad"
            echo "1 1" > $pipe
            notify-send -t 2000 -i input-touchpad "touchpad:on tapping:on"
        else
            echo "default case"
            echo "1 1" > $pipe
            notify-send -t 2000 -i input-touchpad "touchpad:on tapping:on"
        fi
        status="$(o_touchpad_get_status)"
        echo "status in system: '$status'"
    else
        echo $@ > $pipe
    fi
}

if [[ -z "$1" ]]; then
    echo "running server"
    o_touchpad_server
else
    echo "calling client"
    o_touchpad_client "$@"
fi
