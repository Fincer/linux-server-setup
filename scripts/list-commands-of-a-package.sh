#!/bin/bash

# SCRIPT DESCRIPTION:
# This bash script lists all commands/executables included in a package defined in PACKAGES array below.

###################################################
# System packages to look for commands in:
PACKAGES=(coreutils findutils util-linux)

# Debian-specific command syntax for listing files belonging to a package
# This syntax does not apply in other Linux distributions using other than dpkg solutions.
LIST_COMMAND='dpkg -L'

###################################################

# Loop through each package listed in PACKAGES bash array above
# For each package, use another loop to go through each file listed in pathes defined by file mimetype
#
for pkg in ${PACKAGES[*]}; do
	for file in $($LIST_COMMAND $pkg); do

		WHATBIN=$(file --mime-type $file | grep x\-sharedlib | awk -F ":" '{print $1}' | sed '/\.so/d' | awk -F '/' '{print $(NF)}')

		# whatis command gets confused with an empty input. Avoid these situations.
		if [[ ! -z $WHATBIN ]]; then
			whatis $WHATBIN | sed 's/([0-9a-zA-Z])//'
		fi

	done
done | sort

###################################################
## DEPRECATED
## All bin folders listed in PATH global variable.
## Remove quotation marks with sed
## Replace : with |\ for grep command
## Add each directory path into the exdirs array
## Start from array index 0 (dirnum) and increase the number in the loop with 'let dirnum++' command
##
#dirnum=0
#for exdir in $(export -p | grep 'declare -x PATH' | awk -F '=' '{print $2}' | sed 's/"//g' | tr ':' '|\'); do
#	exdirs[$dirnum]=$exdir
#	let dirnum++
#done
## DEPRECATED

## DEPRECATED
#	for cmd in $($LIST_COMMAND $pkg | grep -E "${exdirs[*]}" | awk -F '/' '{print $(NF)}'); do
#		whatis $cmd | sed 's/([0-9a-zA-Z])//'
#	done | sort 
## DEPRECATED