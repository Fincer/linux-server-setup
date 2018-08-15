#!/bin/bash

# XFCE4: IMPROVE WINDOW BORDER MOUSE SNAP BY INCREASING EDGE SIZE
# APPLIES TO STYLE 'Numix' (Whisker menu -> Settings -> Appearance -> Style)
#
# This topic has been discussed here: https://github.com/numixproject/numix-gtk-theme/issues/100
#
# The main issue in Xfce4 desktop usage is window border/edge size which is 1 px by default
# This makes it very annoying and difficult to grab a window edge with mouse cursor
# This modification should be applied to source files but can be done by
# modifying installed style files, too (which this script does) 

# These modifications are proposed here:
# https://github.com/MaxKh/numix-gtk-theme/commit/6057a2d907a2e3014ae9e268e1aed8dc819a55c8

##################################################################

sudo echo -e "\
/* XPM */\n \
static char * bottom_active_xpm[] = {\n \
\"8 5 3 1\",\n \
\" \tc None\",\n \
\".\tc #444444\",\n \
\"#\tc #484848\",\n \
\"........\",\n \
\"........\",\n \
\"........\",\n \
\"........\",\n \
\"########\"};" \
>> sudo tee /usr/share/themes/Numix/xfwm4/bottom-active.xpm

##################################################################

sudo echo -e "\
/* XPM */\n \
static char * bottom_inactive_xpm[] = {\n \
\"8 5 3 1\",\n \
\" \tc None\",\n \
\".\tc #444444\",\n \
\"#\tc #393939\",\n \
\"........\",\n \
\"........\",\n \
\"........\",\n \
\"........\",\n \
\"########\"};" \
>> sudo tee /usr/share/themes/Numix/xfwm4/bottom-inactive.xpm

##################################################################

sudo echo -e "\
/* XPM */\n \
static char * bottom_left_active_xpm[] = {\n \
\"24 5 3 1\",\n \
\" \tc None\",\n \
\".\tc #444444\",\n \
\"#\tc #484848\",\n \
\"#.......................\",\n \
\"#.......................\",\n \
\"#.......................\",\n \
\"#.......................\",\n \
\"########################\"};" \
>> sudo tee /usr/share/themes/Numix/xfwm4/bottom-left-active.xpm

##################################################################

sudo echo -e "\
/* XPM */\n \
static char * bottom_left_inactive_xpm[] = {\n \
\"24 5 3 1\",\n \
\" \tc None\",\n \
\".\tc #444444\",\n \
\"#\tc #393939\",\n \
\"#.......................\",\n \
\"#.......................\",\n \
\"#.......................\",\n \
\"#.......................\",\n \
\"########################\"};" \
>> /usr/share/themes/Numix/xfwm4/bottom-left-inactive.xpm

##################################################################

sudo echo -e "\
/* XPM */\n \
static char * bottom_right_active_xpm[] = {\n \
\"24 5 3 1\",\n \
\" \tc None\",\n \
\".\tc #444444\",\n \
\"#\tc #484848\",\n \
\".......................#\",\n \
\".......................#\",\n \
\".......................#\",\n \
\".......................#\",\n \
\"########################\"};" \
>> /usr/share/themes/Numix/xfwm4/bottom-right-active.xpm

##################################################################

sudo echo -e "\
/* XPM */\n \
static char * bottom_right_inactive_xpm[] = {\n \
\"24 5 3 1\",\n \
\" \tc None\",\n \
\".\tc #444444\",\n \
\"#\tc #393939\",\n \
\".......................#\",\n \
\".......................#\",\n \
\".......................#\",\n \
\".......................#\",\n \
\"########################\"};" \
>> /usr/share/themes/Numix/xfwm4/bottom-right-inactive.xpm

##################################################################
