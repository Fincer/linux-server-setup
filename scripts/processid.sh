#!/bin/sh

# Usage example: sh processid.sh kate dolphin gnome-terminal
# Loop through each input value
#
for PID in $@; do
    PROCESSPRNT=$(ps l -C $PID | awk '{print $3}' | tail -n +2)
    
    if [[ $(echo $PROCESSPRNT | wc -w) -ne 0 ]]; then
        echo -e "\n'$PID': All process IDs (PID) are:\n\n$PROCESSPRNT\n"
        echo -e "Total: $(echo $PROCESSPRNT | wc -w)\n"
    else
        echo -e "\n'$PID': No process found running.\n"
    fi
done

####
#DEPRECATED

# Array of processes
#BIN_PATTERN=(
#dolphin
#gigole
#)

#for PID in ${BIN_PATTERN[*]}; do

#DEPRECATED
####
