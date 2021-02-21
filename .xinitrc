#!/bin/sh

# /etc/X11/xinit/xinitrc
#
# global xinitrc file, used by all X sessions started by xinit (startx)

# invoke global X session script
xrandr --output LVDS --panning 1920x1080 --scale 1.406x1.406 --output HDMI-0 --mode 1920x1080 --pos 1920x0
. /etc/X11/Xsession

