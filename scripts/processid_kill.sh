#!/bin/sh

# Kills all matching processes
#
# Usage: sh processid_kill.sh process1 process2 process3 ...
#
for PIDS in $(ps l -C $@ | awk '{print $3}' | tail -n +2); do
    for PID in $(echo $PIDS); do
        kill $PID
    done
done

# TODO: ignore case. For example, if user input is 'Vlc', ignore case and find process 'vlc' instead.
# This can be done with grep
