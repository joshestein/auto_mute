#!/usr/bin/env bash

function get_mute_statuses {
    local mute_statuses=$(pactl list sources | grep "Mute: " | cut -d " " -f2)
    echo "$mute_statuses"
}

original_mute_statuses=$(get_mute_statuses)

function toggle_source_mute {
    # toggle_source_mute [0 | 1] <sources>
    # 0 = unmute, 1 = mute
    # if no sources are specified all sources will be queried

    statuses=${2:-$(get_mute_statuses)}
    index=0
    for i in $statuses; do
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
