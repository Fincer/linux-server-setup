#!/bin/bash

######################################################
# THIS SCRIPT DOWNLOADS AND COMPILES PROGRAM 'xcmenu' IN A DEBIAN SYSTEM
#
# THIS SCRIPT PRESENTS A METHOD OF TAKING A SCREENSHOT ON A LINUX DESKTOP
# IN A SIMILAR WAY THAN ON MICROSOFT WINDOWS.

###############
# This is a useful method for capturing screenshots on a X11 desktop
# The main idea is to replicate Microsoft Windows behavior of taking screenshots
# without any additional cumbersome client programs which are traditionally used on Linux desktops.
#
# Source code and build instructions (mainly for Arch Linux) of the command 'xclipshow' are available here:
# https://github.com/Fincer/linux-patches-and-scripts/tree/master/xclipshow
#
# The code is originally presented in
# https://unix.stackexchange.com/questions/163081/application-that-allows-to-show-clipboard-contents-and-its-mime-type/163115#163115 
#
###############
#
# 1. Run this script with 'bash compile-xcmenu.sh'
# 2. Verify xcmenu installation by running 'dpkg --get-selections |grep xcmenu'
# 3. You need imagemagick. Install it by running 'sudo apt-get install imagemagick'
# 4. Copy the following command...

# import -window root -screen /tmp/screen.png | xcmenu -bi image/png < /tmp/screen.png

# ... and map a new shortcut key for it (such as printscreen key) on your preferred desktop environment.

# 5. Compile 'xclipshow' by following the instructions given above and in this script below. 
# Additionally, You need 'cmake' and 'qt5-default' packages to compile the source code (not sure if other Qt5 packages are also required).
#
# 6. Map another shortcut key (such as Alt+V) for the chosen paint program (kolourpaint in this case).
# Use the following command syntax for pasting shortcut:

# bash -c "if [[ $(xclipshow |grep -c image/png) -eq 1 ]]; then kolourpaint /tmp/screen.png; fi"

###############

# Personally, I have mapped print screen key to capture & save a screenshot, and Alt+V to open it into Kolourpaint on KDE 5 desktop.
# Additionally, I have implemented a GUI nofitication for screenshots. Each time screenshot is saved in /tmp, the desktop reminds me about that.

######################################################
# INSTRUCTIONS FOR COMPILING 'xcmenu' FROM SOURCE IN A DEBIAN SYSTEM
######################################################
# Install necessary dependencies for the program

sudo apt-get install zlib1g libxcb1 zlib1g-dev libxcb1-dev dh-make git make

######################################################
# Go to $HOME, create subfolder 'xcmenu'
# Clone source files from GitHub to $HOME/xcmenu/xcmenu-0.1.0 subfolder
# Access xcmenu-0.1.0 subfolder

cd && mkdir xcmenu
cd xcmenu && git clone git://github.com/dindon-sournois/xcmenu.git xcmenu-0.1.0
cd xcmenu-0.1.0

######################################################
# Prepare compiling environment by generating 'debian' folder + contents

dh_make --createorig -s -y

######################################################
# Set build & runtime dependencies + build rule overrides

# Build time dependencies
sed -i 's/Build-Depends: debhelper (>=9)/Build-Depends: debhelper (>=9), make, zlib1g-dev, libxcb1-dev/g' debian/control

# Runtime dependencies
sed -i 's/Depends: ${shlibs:Depends}, ${misc:Depends}/Depends: gcc, zlib1g, libxcb1/g' debian/control

# Program description
sed -i 's/<insert up to 60 chars description>/lightweight clipboard manager for X/g' debian/control
sed -i 's/ <insert long description, indented with spaces>/ ./g' debian/control

# A build rule override
echo 'override_dh_usrlocal:' | tee -a debian/rules

######################################################
# Compile source files into a deb package without signatures

dpkg-buildpackage -rfakeroot -b -us -uc

######################################################
# Install compiled .deb package

sudo dpkg -i ../xcmenu*.deb

######################################################
# Remove build dependencies from the system as they are no longer needed

sudo apt-get purge --remove zlib1g-dev libxcb1-dev
