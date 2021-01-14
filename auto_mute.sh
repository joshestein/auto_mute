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
    # un-mute originally unmuted sources
    printf "\n Cleaning..."
    toggle_source_mute 0 "$original_mute_statuses"
    exit 0
}

trap cleanup SIGINT SIGTERM

all_muted=false
while true; do
    read -n 1 -t 30

    if [ $? == 0 ]; then
        if [ "$all_muted" = true ]; then
            continue
        else
            toggle_source_mute 1 # mute
            all_muted=true
        fi
    else
        # no input for some time, check sources
        updated_mute_statuses=$(get_mute_statuses)
        for i in $updated_mute_statuses; do
            if [ "$i" == "no" ]; then
                all_muted=false
                break;
            fi
        done
    fi
done
