#!/bin/bash

# Author: Pekka Helenius (~Fincer), 2018
# Collect system statistics at regular intervals

# Check if the following file exists. If not, exit the script.
[[ $(ls /etc/default/sysstat) ]] || exit

# Enable stats
[[ $(cat /etc/default/sysstat | grep "ENABLED=\"true\"") ]] || sudo sed -i 's/ENABLED.*/ENABLED="true"/' /etc/default/sysstat

# How many days we take stats
DAYS=2
DATE_INTERVAL=$(echo $(date +%Y-%m-%d)_$(date +%Y-%m-%d -d "+$DAYS days"))

# Interval of stats in seconds
INTERVAL=20

# Logs dir
SARDIR=$HOME/sar_statistics
SARSTAT_FILE=$SARDIR/sar_stats_$DATE_INTERVAL.file
PIDSTAT_DIR=$SARDIR/pidstats

##############
[[ -d $PIDSTAT_DIR ]] || mkdir -p $PIDSTAT_DIR
DAYS_SEC=$(( DAYS * 60 * 60 * 24))
COUNT=$(( DAYS_SEC / INTERVAL ))
##############

# Ignore HANGUP signal. By setting this, we continue running commands presented below though this script has exited
# Alternatively, use 'nohup' before any command execution. NOTE: 'nohup' doesn't work with functions
trap "" HUP

# Gather data for analysis
# alternatively use 'nohup' as a prefix for this command
sar $INTERVAL $COUNT -o $SARSTAT_FILE &>/dev/null &
disown

##########################################
# How to print out statistics?

# CPU
#	sar -u -f $SARSTAT_FILE

# Memory
#	sar -r -f $SARSTAT_FILE

# Mounted filesystems
#	sar -F MOUNT / -f $SARSTAT_FILE

# Swap space stats
#	sar -S -f $SARSTAT_FILE

# Network devices
#	sar -n DEV -f $SARSTAT_FILE

# Network devices - errors
#	sar -n EDEV -f $SARSTAT_FILE

# Network IPv4 sockets
#	sar -n SOCK -f $SARSTAT_FILE

# Network IPv6 sockets
#	sar -n SOCK6 -f $SARSTAT_FILE

# Network IPv4 traffic statistics
#	sar -n IP -f $SARSTAT_FILE

# Network IPv4 traffic statistics - errors
#	sar -n EIP -f $SARSTAT_FILE

# Network IPv6 traffic statistics
#	sar -n IP6 -f $SARSTAT_FILE

# Network IPv6 traffic statistics - errors
#	sar -n EIP6 -f $SARSTAT_FILE

# Network TCP protocol statistics
#	sar -n TCP -f $SARSTAT_FILE

# Network TCP protocol statistics - errors
#	sar -n ETCP -f $SARSTAT_FILE

# Inode, file etc. stats
#	sar -v -f $SARSTAT_FILE

# Tasks statistics
#	sar -w -f $SARSTAT_FILE

##########################################
# Pidstat

function pidstats() {
	while [[ $DAYS_SEC -ge 0 ]]; do

    	pidstat -d >> $PIDSTAT_DIR/pidstat_stats_io_$DATE_INTERVAL
	#    pidstat -R >> $PIDSTAT_DIR/pidstat_stats_realtime_$DATE_INTERVAL
    	pidstat -r >> $PIDSTAT_DIR/pidstat_stats_pagefaults_$DATE_INTERVAL
    	pidstat -s >> $PIDSTAT_DIR/pidstat_stats_stacks_$DATE_INTERVAL
    	pidstat -u >> $PIDSTAT_DIR/pidstat_stats_cpu-tasks_$DATE_INTERVAL
    	pidstat -v >> $PIDSTAT_DIR/pidstat_stats_kerneltables_$DATE_INTERVAL
        
	# We want to interrupt this loop if previous pidstat commands fail.
	if [[ ! $? == 0 ]]; then
		break 1
	fi

    	DAYS_SEC=$(( DAYS_SEC - INTERVAL ))
    	sleep $INTERVAL

	done

}

pidstats &
echo -e "Collecting statistics with 'sar' and 'pidstat' commands for the following $DAYS days. All commands will stop at $(date '+%H:%M on %Y-%m-%d' -d '+2 days')."
disown
