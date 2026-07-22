#!/bin/bash

# Interval 4 minutes = 240 seconds
INTERVAL=240

move_mouse() {
    MOUSE_COORD=$(cliclick p)
    X_COORD=$(echo $MOUSE_COORD | cut -d',' -f1)
    Y_COORD=$(echo $MOUSE_COORD | cut -d',' -f2)

    # Move mouse 1 pixel to the right then back
    cliclick m:$((X_COORD+1)),$Y_COORD
    cliclick m:$X_COORD,$Y_COORD
}

caffeinate -sid &
while true;
do
    move_mouse
    sleep $INTERVAL
done

