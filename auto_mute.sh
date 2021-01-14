#!/usr/bin/env bash

mute_statuses=$(pactl list sources | grep "Mute: " | cut -d " " -f2)

function toggle_source_mute {
    index=0
    for i in $mute_statuses; do
        if [ "$i" == "no" ]; then
            pacmd set-source-mute $index $1
        fi
        index=$((index+1))
    done
}

function cleanup {
    toggle_source_mute 0 # un-mute
}

trap cleanup SIGINT SIGTERM

header=0
stdbuf -o0 showkey -a 2>/dev/null | while read line; do
    if [[ $header -lt 4 ]]; then
        header=$((header + 1))
    else
        toggle_source_mute 1 # mute
    fi
done
