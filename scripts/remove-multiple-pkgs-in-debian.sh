#!/bin/sh

# Package patterns to search
PKG_PATTERN="onboard|ristretto|catfish|notes|libreoffice|transmission|sudoku|mines|scan|mugshot|screenshooter|firefox"

# Removal of the found packages
sudo apt-get purge --remove $(dpkg --get-selections |grep -E $PKG_PATTERN | awk '{print $1}' | tr '\n' ' ')

# Cleanup
sudo apt-get autoremove
